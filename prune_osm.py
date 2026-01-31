import sqlite3
import json
import sys
import os

# CONFIGURATION
SOURCE_DB = r"E:\osm\osm_data.db"
TARGET_DB = r"E:\osm\osm_pruned.db"
BATCH_SIZE = 50000

if os.path.exists(TARGET_DB):
    os.remove(TARGET_DB)

src_conn = sqlite3.connect(SOURCE_DB)
src_cursor = src_conn.cursor()

tgt_conn = sqlite3.connect(TARGET_DB)
tgt_cursor = tgt_conn.cursor()

# CREATE SCHEMA
print("Creating pruned schema...")
tgt_cursor.execute('''
    CREATE TABLE osm_features (
        id BIGINT,
        type TEXT, -- 'node', 'way', 'relation'
        name TEXT,
        category TEXT, -- amenity, shop, highway, etc.
        lat REAL,
        lon REAL,
        tags JSONB,
        PRIMARY KEY (id, type)
    )
''')
tgt_conn.commit()

def extract_nodes():
    print("\n>>> Extracting Tagged Nodes...")
    # Get total count first for progress reporting
    src_cursor.execute("SELECT count(*) FROM nodes WHERE tags IS NOT NULL")
    total = src_cursor.fetchone()[0]
    
    src_cursor.execute("SELECT id, lat, lon, tags FROM nodes WHERE tags IS NOT NULL")
    
    count = 0
    while True:
        rows = src_cursor.fetchmany(BATCH_SIZE)
        if not rows:
            break
            
        batch = []
        for r_id, lat, lon, tags_json in rows:
            tags = json.loads(tags_json)
            name = tags.get('name')
            # Determine category (priority to amenity, then shop, then landmark)
            category = tags.get('amenity') or tags.get('shop') or tags.get('place') or tags.get('tourism') or 'other'
            
            batch.append((r_id, 'node', name, category, lat, lon, tags_json))
            
        tgt_cursor.executemany(
            "INSERT INTO osm_features (id, type, name, category, lat, lon, tags) VALUES (?, ?, ?, ?, ?, ?, ?)",
            batch
        )
        count += len(batch)
        sys.stdout.write(f"\rProgress: {count}/{total} ({(count/total)*100:.1f}%)")
        sys.stdout.flush()
    
    tgt_conn.commit()
    print(f"\n[DONE] Extracted {count} nodes.")

def extract_ways():
    print("\n>>> Extracting Tagged Ways (Resolving coordinates)...")
    src_cursor.execute("SELECT count(*) FROM ways WHERE tags IS NOT NULL")
    total = src_cursor.fetchone()[0]

    # Optimized Query: Joins ways with their first node to get a location
    # Note: SQLite 'json_extract' can be slow over 8M rows, so we do it in smaller steps
    # We fetch IDs and Tags, and resolve refs manually or via a join
    
    # Efficient strategy: Use a cursor with a join
    src_cursor.execute('''
        SELECT 
            w.id, 
            n.lat, 
            n.lon, 
            w.tags 
        FROM ways w
        LEFT JOIN nodes n ON n.id = CAST(json_extract(w.refs, '$[0]') AS BIGINT)
        WHERE w.tags IS NOT NULL
    ''')
    
    count = 0
    while True:
        rows = src_cursor.fetchmany(BATCH_SIZE)
        if not rows:
            break
            
        batch = []
        for r_id, lat, lon, tags_json in rows:
            tags = json.loads(tags_json)
            name = tags.get('name')
            category = tags.get('highway') or tags.get('building') or tags.get('landuse') or 'other'
            
            batch.append((r_id, 'way', name, category, lat, lon, tags_json))
            
        tgt_cursor.executemany(
            "INSERT INTO osm_features (id, type, name, category, lat, lon, tags) VALUES (?, ?, ?, ?, ?, ?, ?)",
            batch
        )
        count += len(batch)
        sys.stdout.write(f"\rProgress: {count}/{total} ({(count/total)*100:.1f}%)")
        sys.stdout.flush()
        
    tgt_conn.commit()
    print(f"\n[DONE] Extracted {count} ways.")

def create_indexes():
    print("\n>>> Creating final search indexes...")
    tgt_cursor.execute("CREATE INDEX idx_osm_name ON osm_features(name) WHERE name IS NOT NULL")
    tgt_cursor.execute("CREATE INDEX idx_osm_category ON osm_features(category)")
    tgt_cursor.execute("CREATE INDEX idx_osm_geo ON osm_features(lat, lon)")
    
    # Optional FTS5 but might be too big for Turso free - keeping simple B-Tree index for now
    tgt_conn.commit()
    print("Optimization complete.")

def main():
    try:
        extract_nodes()
        extract_ways()
        create_indexes()
        
        # Check final size
        final_size = os.path.getsize(TARGET_DB) / (1024*1024)
        print(f"\nSuccess! Pruned DB saved to {TARGET_DB}")
        print(f"Original size: {os.path.getsize(SOURCE_DB)/(1024*1024):.1f} MB")
        print(f"New size: {final_size:.1f} MB")
        
    finally:
        src_conn.close()
        tgt_conn.close()

if __name__ == "__main__":
    main()
