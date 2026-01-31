import sqlite3
import os

db_path = r"E:\osm\osm_pruned.db"

print(f"Optimizing {db_path}...")
try:
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA wal_checkpoint(TRUNCATE);")
    conn.execute("VACUUM;")
    conn.close()
    print("Optimization complete: WAL mode set, checkpointed, and VACUUMed.")
except Exception as e:
    print(f"Error: {e}")
