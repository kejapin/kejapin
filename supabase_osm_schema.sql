-- Supabase Schema for OSM Data
-- This schema mimics the structure created in SQLite but optimized for PostgreSQL/Supabase.
-- Using simple lat/lon for nodes to avoid heavy PostGIS dependency if not enabled, 
-- but includes comments for PostGIS upgrade.

-- 1. NODES Table
CREATE TABLE IF NOT EXISTS public.osm_nodes (
    id BIGINT PRIMARY KEY,
    lat FLOAT8 NOT NULL,
    lon FLOAT8 NOT NULL,
    tags JSONB, -- JSONB allows for indexing and querying keys
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Optional: Enable PostGIS and add geometry column
-- CREATE EXTENSION IF NOT EXISTS postgis;
-- ALTER TABLE public.osm_nodes ADD COLUMN geom GEOGRAPHY(POINT, 4326);
-- UPDATE public.osm_nodes SET geom = ST_SetSRID(ST_MakePoint(lon, lat), 4326);
-- CREATE INDEX osm_nodes_geom_idx ON public.osm_nodes USING GIST (geom);

-- 2. WAYS Table
CREATE TABLE IF NOT EXISTS public.osm_ways (
    id BIGINT PRIMARY KEY,
    refs JSONB, -- Helper array of node IDs
    tags JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. RELATIONS Table
CREATE TABLE IF NOT EXISTS public.osm_relations (
    id BIGINT PRIMARY KEY,
    members JSONB, -- Array of objects: [{"type": "n|w|r", "ref": 123, "role": "outer"}, ...]
    tags JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for Tag Searching
CREATE INDEX IF NOT EXISTS idx_nodes_tags ON public.osm_nodes USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_ways_tags ON public.osm_ways USING GIN (tags);
CREATE INDEX IF NOT EXISTS idx_relations_tags ON public.osm_relations USING GIN (tags);

-- Row Level Security (RLS)
-- Modify these policies based on who should access this data
ALTER TABLE public.osm_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.osm_ways ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.osm_relations ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone
CREATE POLICY "Public Read Access" ON public.osm_nodes FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.osm_ways FOR SELECT USING (true);
CREATE POLICY "Public Read Access" ON public.osm_relations FOR SELECT USING (true);
