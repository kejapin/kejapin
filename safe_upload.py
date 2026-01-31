import sqlite3
import requests
import json
import time
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed

# === CONFIGURATION ===
TURSO_URL = "https://kejapin-kejapin-app.aws-ap-northeast-1.turso.io/v2/pipeline"
TURSO_TOKEN = "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3Njk3NzQ1ODEsImlkIjoiM2EzZTkzYzMtODhiNi00ZWViLThmMmUtOTBjNjJkYjFlMWRkIiwicmlkIjoiZTc5OWRmYmQtODk1Yi00YjZmLWI0NGQtMWIyNjliOWYzZDhiIn0.0UbqZfg2B-mpy51umeMUoFebzmBxBN3apiKiuEW1Q1BjQEaIt5WGtFE1fGI86jfW-M303KLOIrCrRTNArrIODQ"
PRUNED_DB = r"E:\osm\osm_pruned.db"

# SAFE MODE SETTINGS
BATCH_SIZE = 50       # Very small batch to ensure success
MAX_WORKERS = 1       # Single thread to prevent DNS/Rate limits

headers = {
    "Authorization": f"Bearer {TURSO_TOKEN}",
    "Content-Type": "application/json"
}

# Thread-local session storage
thread_local = threading.local()

def get_session():
    if not hasattr(thread_local, "session"):
        thread_local.session = requests.Session()
        thread_local.session.headers.update(headers)
    return thread_local.session

def map_value(v):
    if v is None: return {"type": "null"}
    if isinstance(v, (int, bool)): return {"type": "integer", "value": str(int(v))}
    if isinstance(v, float): return {"type": "float", "value": v}
    return {"type": "text", "value": str(v)}

def get_turso_count():
    payload = {"requests": [{"type": "execute", "stmt": {"sql": "SELECT COUNT(*) FROM osm_features", "args": []}}]}
    try:
        response = requests.post(TURSO_URL, headers=headers, json=payload, timeout=20)
        if response.status_code == 200:
            return int(response.json()['results'][0]['response']['result']['rows'][0][0]['value'])
    except:
        pass
    return 0

def upload_batch(batch_data):
    session = get_session()
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
    
    # Robust Retry Loop
    for attempt in range(20):
        try:
            response = session.post(TURSO_URL, json=payload, timeout=45)
            
            if response.status_code == 200:
                res_content = response.json()
                # Check for logic errors
                if 'results' in res_content:
                    for r in res_content['results']:
                        if r['type'] == 'error':
                            print(f"\n[SQL Error] {r['error']['message']}")
                            return 0
                return len(batch_data)
                
            elif response.status_code == 429:
                wait_time = 5 * (attempt + 1)
                print(f"\n[Rate Limit] Cooling down for {wait_time}s...")
                time.sleep(wait_time)
                
            elif response.status_code >= 500:
                print(f"\n[Server Error {response.status_code}] Retrying...")
                time.sleep(5)
            else:
                print(f"\n[HTTP {response.status_code}] {response.text[:100]}")
                time.sleep(5)
                
        except Exception as e:
            # Network level errors (DNS, Timeout)
            wait_time = 10 * (attempt + 1)
            # Only print error if it persists
            if attempt > 1:
                print(f"\n[Network Error] {e}. Waiting {wait_time}s...")
            time.sleep(wait_time)
            
    return 0 # Failed after many retries

def main():
    print(f"Starting SAFE upload from {PRUNED_DB}")
    
    print("Checking Progress...")
    start_offset = get_turso_count()
    print(f"Rows already uploaded: {start_offset}")
    
    conn = sqlite3.connect(PRUNED_DB)
    cursor = conn.cursor()
    
    cursor.execute("SELECT count(*) FROM osm_features")
    total_rows = cursor.fetchone()[0]
    
    if start_offset >= total_rows:
        print("Upload already done.")
        return

    print(f"Resuming from offset {start_offset}...")
    cursor.execute(f"SELECT id, type, name, category, lat, lon, tags FROM osm_features LIMIT -1 OFFSET {start_offset}")
    
    uploaded_count = start_offset
    start_time = time.time()
    
    # Using 1 worker for safety
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = []
        
        while True:
            rows = cursor.fetchmany(BATCH_SIZE)
            if not rows:
                break
                
            futures.append(executor.submit(upload_batch, rows))
            
            # Keep queue small
            if len(futures) >= 5:
                # Wait for all to finish before sending next batch
                # This effectively makes it 100% synchronous/serial but uses the executor structure
                for f in as_completed(futures):
                    uploaded_count += f.result()
                
                futures = [] # Clear list
                
                # Progress Update
                elapsed = time.time() - start_time
                speed = (uploaded_count - start_offset) / elapsed if elapsed > 0 else 0
                pct = (uploaded_count / total_rows) * 100
                sys.stdout.write(f"\rProgress: {pct:.4f}% | Uploaded: {uploaded_count} | Speed: {speed:.1f} rows/s")
                sys.stdout.flush()

    print("\nComplete!")

if __name__ == "__main__":
    main()
