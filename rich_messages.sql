-- Ensure UUID extension is enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create MESSAGES table if it doesn't exist (matching supabase_schema.sql)
CREATE TABLE IF NOT EXISTS public.messages (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  sender_id uuid REFERENCES public.users(id) NOT NULL,
  recipient_id uuid REFERENCES public.users(id) NOT NULL,
  property_id uuid REFERENCES public.properties(id),
  content text NOT NULL,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Add support for rich messages (Text, Image, Property, Location, Lease, Payment, Schedule)
ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS type TEXT DEFAULT 'text', 
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}'::jsonb;

-- Ensure we have an index on type for filtering
CREATE INDEX IF NOT EXISTS idx_messages_type ON public.messages(type);

-- Enable RLS if not already enabled
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Re-apply policies (Idempotent)
DROP POLICY IF EXISTS "Users can view their own messages" ON public.messages;
CREATE POLICY "Users can view their own messages"
  ON public.messages FOR SELECT
  USING ( auth.uid() = sender_id OR auth.uid() = recipient_id );

DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
CREATE POLICY "Users can send messages"
  ON public.messages FOR INSERT
  WITH CHECK ( auth.uid() = sender_id );
