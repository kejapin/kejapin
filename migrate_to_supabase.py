import sqlite3
import requests
import json
import os
import sys

# === CONFIGURATION ===
SUPABASE_URL = "https://jxdanbsfcjkuvrakvnoa.supabase.co"
# REPLACE WITH YOUR SERVICE ROLE KEY (Project Settings -> API)
# WARNING: Keep this key secret!
SUPABASE_KEY = "YOUR_SERVICE_ROLE_KEY" 

SQLITE_DB = r"E:\osm\osm_data.db"
BATCH_SIZE = 1000 # Number of rows per request

def upload_batch(table_name, data):
    """Uploads a batch of rows to Supabase via PostgREST."""
    url = f"{SUPABASE_URL}/rest/v1/{table_name}"
    headers = {
        "apikey": SUPABASE_KEY,
        "Authorization": f"Bearer {SUPABASE_KEY}",
        "Content-Type": "application/json",
        "Prefer": "resolution=merge-duplicates" # Updates if ID exists
    }
    try:
        response = requests.post(url, headers=headers, data=json.dumps(data))
        if response.status_code not in [200, 201]:
            print(f"\n[ERROR] Failed to upload to {table_name}: {response.status_code}")
            print(f"Response: {response.text[:200]}")
            return False
        return True
    except Exception as e:
        print(f"\n[ERROR] Request failed: {e}")
        return False

def migrate_table(sqlite_cursor, table_name, supabase_table, mapping_func):
    """Generic migration logic for a table."""
    print(f"\n>>> Starting migration: {table_name} -> {supabase_table}")
    
    sqlite_cursor.execute(f"SELECT count(*) FROM {table_name}")
    total_rows = sqlite_cursor.fetchone()[0]
    print(f"Total rows to migrate: {total_rows}")

    sqlite_cursor.execute(f"SELECT * FROM {table_name}")
    
    count = 0
    while True:
        rows = sqlite_cursor.fetchmany(BATCH_SIZE)
        if not rows:
            break
        
        batch_data = [mapping_func(row) for row in rows]
        
        if upload_batch(supabase_table, batch_data):
            count += len(batch_data)
            sys.stdout.write(f"\rProgress: {count}/{total_rows} ({(count/total_rows)*100:.1f}%)")
            sys.stdout.flush()
        else:
            print(f"\n[HALT] Migration failed at row {count}")
            return False
            
    print(f"\n[SUCCESS] Completed {table_name} migration.")
    return True

# --- MAPPING FUNCTIONS ---

def map_node(row):
    # nodes table: (id, lat, lon, tags)
    return {
        "id": row[0],
        "lat": row[1],
        "lon": row[2],
        "tags": json.loads(row[3]) if row[3] else None
    }

def map_way(row):
    # ways table: (id, refs, tags)
    return {
        "id": row[0],
        "refs": json.loads(row[1]) if row[1] else [],
        "tags": json.loads(row[2]) if row[2] else None
    }

def map_relation(row):
    # relations table: (id, members, tags)
    return {
        "id": row[0],
        "members": json.loads(row[1]) if row[1] else [],
        "tags": json.loads(row[2]) if row[2] else None
    }

def main():
    if SUPABASE_KEY == "YOUR_SERVICE_ROLE_KEY":
        print("[ERROR] Please set your SUPABASE_KEY in the script first.")
        return

    if not os.path.exists(SQLITE_DB):
        print(f"[ERROR] SQLite DB not found at {SQLITE_DB}")
        return

    print(f"Opening SQLite database: {SQLITE_DB}")
    conn = sqlite3.connect(SQLITE_DB)
    cursor = conn.cursor()

    try:
        # 1. Migrate Nodes
        if not migrate_table(cursor, "nodes", "osm_nodes", map_node):
            return

        # 2. Migrate Ways
        if not migrate_table(cursor, "ways", "osm_ways", map_way):
            return

        # 3. Migrate Relations
        if not migrate_table(cursor, "relations", "osm_relations", map_relation):
            return

    except KeyboardInterrupt:
        print("\n[INFO] Migration paused by user.")
    finally:
        conn.close()
        print("\nAll done.")

if __name__ == "__main__":
    main()
