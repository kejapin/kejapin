import sqlite3
import requests
import json
import time
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

# === CONFIGURATION ===
TURSO_URL = "https://kejapin-kejapin-app.aws-ap-northeast-1.turso.io/v2/pipeline"
TURSO_TOKEN = "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3Njk3NzQ1ODEsImlkIjoiM2EzZTkzYzMtODhiNi00ZWViLThmMmUtOTBjNjJkYjFlMWRkIiwicmlkIjoiZTc5OWRmYmQtODk1Yi00YjZmLWI0NGQtMWIyNjliOWYzZDhiIn0.0UbqZfg2B-mpy51umeMUoFebzmBxBN3apiKiuEW1Q1BjQEaIt5WGtFE1fGI86jfW-M303KLOIrCrRTNArrIODQ"
PRUNED_DB = r"E:\osm\osm_pruned.db"

# Tweak these for performance
BATCH_SIZE = 100      # REDUCED from 400 to play it safe
MAX_WORKERS = 4       # REDUCED from 8 to avoid rate limits

headers = {
    "Authorization": f"Bearer {TURSO_TOKEN}",
    "Content-Type": "application/json"
}

def map_value(v):
    if v is None: return {"type": "null"}
    if isinstance(v, (int, bool)): return {"type": "integer", "value": str(int(v))}
    if isinstance(v, float): return {"type": "float", "value": v}
    return {"type": "text", "value": str(v)}

def get_turso_count():
    """Checks how many rows already exist on Turso."""
    payload = {"requests": [{"type": "execute", "stmt": {"sql": "SELECT COUNT(*) FROM osm_features", "args": []}}]}
    try:
        response = requests.post(TURSO_URL, headers=headers, json=payload, timeout=10)
        if response.status_code == 200:
            return int(response.json()['results'][0]['response']['result']['rows'][0][0]['value'])
        else:
            print(f"Check count failed: {response.status_code} {response.text}")
    except Exception as e:
        print(f"Check count failed: {e}")
    return 0

def upload_batch(batch_data):
    """Worker function to upload a single batch."""
    statements = []
    for row in batch_data:
        sql = "INSERT OR REPLACE INTO osm_features (id, type, name, category, lat, lon, tags) VALUES (?, ?, ?, ?, ?, ?, ?)"
        args = list(row)
        statements.append({
            "type": "execute",
            "stmt": {
                "sql": sql,
                "args": [map_value(v) for v in args]
            }
        })
    
    payload = {"requests": statements}
    
    # Retry Loop
    for attempt in range(5): # Reduced retries to fail faster if broken
        try:
            response = requests.post(TURSO_URL, headers=headers, json=payload, timeout=30)
            if response.status_code == 200:
                res_json = response.json()
                # Check for SQL errors inside the 200 OK response
                # Turso/libSQL HTTP API returns 200 even if statements fail sometimes, we check results
                if 'results' in res_json:
                     for r in res_json['results']:
                         if r['type'] == 'error':
                             print(f"SQL Error: {r['error']['message']}")
                             return 0
                return len(batch_data)
            elif response.status_code == 429:
                print(f"Rate Limited (429). Waiting {attempt+2}s...")
                time.sleep(attempt + 2)
            else:
                print(f"HTTP Error {response.status_code}: {response.text[:200]}") # Print first 200 chars of error
                time.sleep(2)
        except Exception as e:
            print(f"Network Error: {e}")
            time.sleep(2)
            
    return 0 # Failed after retries

def main():
    print(f"Starting SMART upload from {PRUNED_DB}")
    
    # 1. Check existing count for Resuming
    print("Checking Turso state...")
    start_offset = get_turso_count()
    print(f"Found {start_offset} rows already on Turso.")

    conn = sqlite3.connect(PRUNED_DB)
    cursor = conn.cursor()

    cursor.execute("SELECT count(*) FROM osm_features")
    total_rows = cursor.fetchone()[0]
    print(f"Total rows in local file: {total_rows}")
    
    if start_offset >= total_rows:
        print("Upload appears complete!")
        return

    # 2. Select Data with OFFSET to skip uploaded rows
    print(f"Resuming from row {start_offset}...")
    cursor.execute(f"SELECT id, type, name, category, lat, lon, tags FROM osm_features LIMIT -1 OFFSET {start_offset}")
    
    uploaded_count = start_offset
    start_time = time.time()
    
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = []
        
        while True:
            # Fetch a chunk
            rows = cursor.fetchmany(BATCH_SIZE)
            if not rows:
                break
                
            # Submit batch
            future = executor.submit(upload_batch, rows)
            futures.append(future)
            
            # Manage Memory & Progress
            # We wait if queue gets too big to prevent RAM explosion
            if len(futures) >= MAX_WORKERS * 5:
                # Wait for just the completed ones
                done_futures = []
                for f in futures:
                    if f.done():
                        uploaded_count += f.result()
                        done_futures.append(f)
                
                # Remove done futures
                for f in done_futures:
                    futures.remove(f)
                
                # If nothing is done, wait for at least one
                if not done_futures and len(futures) >= MAX_WORKERS * 5:
                     done_f = next(as_completed(futures))
                     uploaded_count += done_f.result()
                     futures.remove(done_f)

                # REPORTING
                elapsed = time.time() - start_time
                avg_speed = (uploaded_count - start_offset) / elapsed if elapsed > 0 else 0
                
                # Print progress bar style line
                progress = (uploaded_count / total_rows) * 100
                sys.stdout.write(f"\rProgress: {progress:.2f}% | Uploaded: {uploaded_count}/{total_rows} | Speed: {avg_speed:.0f} rows/s  ")
                sys.stdout.flush()
                
    # Wait for remaining
    for f in as_completed(futures):
        uploaded_count += f.result()

    print(f"\nUpload Complete! Final count: {uploaded_count}")
    conn.close()

if __name__ == "__main__":
    main()
