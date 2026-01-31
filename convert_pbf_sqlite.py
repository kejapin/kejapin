import osmium
import sqlite3
import json
import sys
import os

DB_FILE = r"E:\osm\osm_data.db"
PBF_FILE = r"F:\kejapin\kenya-260125.osm.pbf"

if os.path.exists(DB_FILE):
    os.remove(DB_FILE)

conn = sqlite3.connect(DB_FILE)
cursor = conn.cursor()

# Create tables
cursor.execute('''
    CREATE TABLE nodes (
        id INTEGER PRIMARY KEY,
        lat REAL,
        lon REAL,
        tags TEXT
    )
''')
cursor.execute('''
    CREATE TABLE ways (
        id INTEGER PRIMARY KEY,
        refs TEXT,
        tags TEXT
    )
''')
cursor.execute('''
    CREATE TABLE relations (
        id INTEGER PRIMARY KEY,
        members TEXT,
        tags TEXT
    )
''')
conn.commit()

class OSMHandler(osmium.SimpleHandler):
    def __init__(self, cursor):
        super(OSMHandler, self).__init__()
        self.cursor = cursor
        self.nodes = []
        self.ways = []
        self.relations = []
        self.batch_size = 10000
        self.count = 0

    def flush_nodes(self):
        if self.nodes:
            self.cursor.executemany("INSERT INTO nodes (id, lat, lon, tags) VALUES (?, ?, ?, ?)", self.nodes)
            self.nodes = []
            self.conn_commit()

    def flush_ways(self):
        if self.ways:
            self.cursor.executemany("INSERT INTO ways (id, refs, tags) VALUES (?, ?, ?)", self.ways)
            self.ways = []
            self.conn_commit()

    def flush_relations(self):
        if self.relations:
            self.cursor.executemany("INSERT INTO relations (id, members, tags) VALUES (?, ?, ?)", self.relations)
            self.relations = []
            self.conn_commit()

    def conn_commit(self):
        self.count += self.batch_size
        if self.count % 100000 == 0:
            print(f"Processed approx {self.count} elements...")
            conn.commit()

    def node(self, n):
        tags = json.dumps({t.k: t.v for t in n.tags}) if n.tags else None
        self.nodes.append((n.id, n.location.lat, n.location.lon, tags))
        if len(self.nodes) >= self.batch_size:
            self.flush_nodes()

    def way(self, w):
        tags = json.dumps({t.k: t.v for t in w.tags}) if w.tags else None
        refs = json.dumps([n.ref for n in w.nodes])
        self.ways.append((w.id, refs, tags))
        if len(self.ways) >= self.batch_size:
            self.flush_ways()

    def relation(self, r):
        tags = json.dumps({t.k: t.v for t in r.tags}) if r.tags else None
        members = json.dumps([(m.type, m.ref, m.role) for m in r.members])
        self.relations.append((r.id, members, tags))
        if len(self.relations) >= self.batch_size:
            self.flush_relations()

print(f"Converting {PBF_FILE} to {DB_FILE}...")
handler = OSMHandler(cursor)
handler.apply_file(PBF_FILE)

# Flush remaining
handler.flush_nodes()
handler.flush_ways()
handler.flush_relations()

conn.commit()
conn.close()
print("Conversion complete.")
