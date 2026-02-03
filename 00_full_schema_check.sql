-- COMPREHENSIVE SCHEMA SETUP & REPAIR (Idempotent)
-- Run this to ensure all core tables exist before applying feature-specific updates.

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. USERS TABLE (The foundation)
CREATE TABLE IF NOT EXISTS public.users (
  id uuid REFERENCES auth.users NOT NULL PRIMARY KEY,
  email text,
  phone_number text,
  first_name text,
  last_name text,
  role text CHECK (role IN ('TENANT', 'LANDLORD', 'ADMIN', 'AGENT')) DEFAULT 'TENANT',
  profile_picture text,
  is_premium boolean DEFAULT false,
  is_verified boolean DEFAULT false,
  last_login timestamp with time zone,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for users
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. PROPERTIES TABLE
CREATE TABLE IF NOT EXISTS public.properties (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  owner_id uuid REFERENCES public.users(id) NOT NULL,
  title text NOT NULL,
  description text,
  listing_type text DEFAULT 'RENT' CHECK (listing_type IN ('RENT', 'SALE')),
  property_type text NOT NULL CHECK (property_type IN ('BEDSITTER', '1BHK', '2BHK', 'SQ', 'BUNGALOW')),
  price_amount numeric NOT NULL,
  latitude float8 NOT NULL,
  longitude float8 NOT NULL,
  address_line_1 text,
  city text NOT NULL,
  county text NOT NULL,
  amenities text,
  photos text,
  bedrooms int DEFAULT 0,
  bathrooms int DEFAULT 0,
  status text DEFAULT 'AVAILABLE' CHECK (status IN ('AVAILABLE', 'OCCUPIED', 'SOLD')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for properties
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- 4. MESSAGES TABLE (With Rich Content Support)
CREATE TABLE IF NOT EXISTS public.messages (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  sender_id uuid REFERENCES public.users(id) NOT NULL,
  recipient_id uuid REFERENCES public.users(id) NOT NULL,
  property_id uuid REFERENCES public.properties(id),
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Apply Rich Message Columns (using ALTER to be safe if table already existed)
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'text';
ALTER TABLE public.messages ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Index for message types
CREATE INDEX IF NOT EXISTS idx_messages_type ON public.messages(type);

-- Enable RLS for messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- 5. RLS POLICIES (Idempotent Apply)

-- Users
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.users;
CREATE POLICY "Public profiles are viewable by everyone" ON public.users FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Messages
DROP POLICY IF EXISTS "Users can view their own messages" ON public.messages;
CREATE POLICY "Users can view their own messages" ON public.messages FOR SELECT 
USING (auth.uid() = sender_id OR auth.uid() = recipient_id);

DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
CREATE POLICY "Users can send messages" ON public.messages FOR INSERT 
WITH CHECK (auth.uid() = sender_id);

-- Properties
DROP POLICY IF EXISTS "Properties are viewable by everyone" ON public.properties;
CREATE POLICY "Properties are viewable by everyone" ON public.properties FOR SELECT USING (true);
