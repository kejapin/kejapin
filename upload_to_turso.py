import sqlite3
import requests
import json
import sys
import time
import os

# === CONFIGURATION ===
TURSO_URL = "https://kejapin-kejapin-app.aws-ap-northeast-1.turso.io/v2/pipeline"
TURSO_TOKEN = "eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJhIjoicnciLCJpYXQiOjE3Njk3NzQ1ODEsImlkIjoiM2EzZTkzYzMtODhiNi00ZWViLThmMmUtOTBjNjJkYjFlMWRkIiwicmlkIjoiZTc5OWRmYmQtODk1Yi00YjZmLWI0NGQtMWIyNjliOWYzZDhiIn0.0UbqZfg2B-mpy51umeMUoFebzmBxBN3apiKiuEW1Q1BjQEaIt5WGtFE1fGI86jfW-M303KLOIrCrRTNArrIODQ"
PRUNED_DB = r"E:\osm\osm_pruned.db"
# Batch size is important for Turso/HTTP; don't make it too large
BATCH_SIZE = 50 

headers = {
    "Authorization": f"Bearer {TURSO_TOKEN}",
    "Content-Type": "application/json"
}

def map_value(v):
    if v is None: return {"type": "null"}
    if isinstance(v, (int, bool)): return {"type": "integer", "value": str(int(v))}
    if isinstance(v, float): return {"type": "float", "value": v}
    return {"type": "text", "value": str(v)}

def execute_batches(statements, retries=3):
    """Sends a batch of SQL statements to Turso via HTTP Pipeline API with retries."""
    payload = {
        "requests": [
            {
                "type": "execute",
                "stmt": {
                    "sql": sql,
                    "args": [map_value(v) for v in args]
                }
            } for sql, args in statements
        ]
    }
    for i in range(retries):
        try:
            response = requests.post(TURSO_URL, headers=headers, json=payload, timeout=30)
            if response.status_code == 200:
                return True
            print(f"\n[SERVER ERROR] {response.status_code}. Retrying ({i+1}/{retries})...")
        except Exception as e:
            print(f"\n[NETWORK ERROR] {e}. Retrying ({i+1}/{retries})...")
        time.sleep(2)
    return False

def get_turso_count():
    """Checks how many rows already exist on Turso."""
    payload = {"requests": [{"type": "execute", "stmt": {"sql": "SELECT COUNT(*) FROM osm_features", "args": []}}]}
    try:
        response = requests.post(TURSO_URL, headers=headers, json=payload, timeout=10)
        if response.status_code == 200:
            return int(response.json()['results'][0]['response']['result']['rows'][0][0]['value'])
    except:
        pass
    return 0

def main():
    print("Initialising Turso Upload...")
    
    # 1. Setup Table
    setup_sql = [
        ("CREATE TABLE IF NOT EXISTS osm_features (id BIGINT, type TEXT, name TEXT, category TEXT, lat REAL, lon REAL, tags TEXT, PRIMARY KEY (id, type))", []),
        ("CREATE INDEX IF NOT EXISTS idx_osm_name ON osm_features(name)", []),
        ("CREATE INDEX IF NOT EXISTS idx_osm_category ON osm_features(category)", [])
    ]
    if not execute_batches(setup_sql):
        print("[ERROR] Failed to setup tables on Turso.")
        return

    start_offset = get_turso_count()
    if start_offset > 0:
        print(f"Resuming folder upload. Found {start_offset} rows already on Turso.")

    conn = sqlite3.connect(PRUNED_DB)
    cursor = conn.cursor()
    
    cursor.execute("SELECT count(*) FROM osm_features")
    total = cursor.fetchone()[0]
    print(f"Total rows in local DB: {total}")
    
    if start_offset >= total:
        print("Upload already complete!")
        return

    # Using OFFSET to skip already uploaded rows
    cursor.execute(f"SELECT id, type, name, category, lat, lon, tags FROM osm_features LIMIT -1 OFFSET {start_offset}")
    
    batch = []
    count = start_offset
    start_time = time.time()

    while True:
        row = cursor.fetchone()
        if not row:
            if batch: # final flush
                execute_batches(batch)
            break
            
        sql = "INSERT OR REPLACE INTO osm_features (id, type, name, category, lat, lon, tags) VALUES (?, ?, ?, ?, ?, ?, ?)"
        batch.append((sql, list(row)))
        
        if len(batch) >= BATCH_SIZE:
            if not execute_batches(batch):
                print("\nMigration failed during batch upload.")
                break
            count += len(batch)
            elapsed = time.time() - start_time
            rate = count / elapsed if elapsed > 0 else 0
            sys.stdout.write(f"\rUploaded {count}/{total} ({(count/total)*100:.2f}%) | Speed: {rate:.1f} rows/s")
            sys.stdout.flush()
            batch = []

    conn.close()
    print("\nUpload Complete.")

if __name__ == "__main__":
    main()
