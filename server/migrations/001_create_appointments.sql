CREATE TABLE IF NOT EXISTS appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    requester_id UUID NOT NULL REFERENCES auth.users(id),
    recipient_id UUID NOT NULL REFERENCES auth.users(id),
    property_id UUID REFERENCES listings(id),
    
    title TEXT NOT NULL,
    description TEXT,
    
    -- Location details (Meeting Point)
    location_name TEXT,
    location_lat DOUBLE PRECISION,
    location_lng DOUBLE PRECISION,
    
    start_time TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, confirmed, cancelled, rescheduled
    
    -- Reminders tracking
    reminder_sent_4h BOOLEAN DEFAULT FALSE,
    reminder_sent_1h BOOLEAN DEFAULT FALSE,
    
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Index for querying upcoming appointments efficiently
CREATE INDEX idx_appointments_start_time ON appointments(start_time);
CREATE INDEX idx_appointments_reminder_4h ON appointments(reminder_sent_4h) WHERE reminder_sent_4h = FALSE;
CREATE INDEX idx_appointments_reminder_1h ON appointments(reminder_sent_1h) WHERE reminder_sent_1h = FALSE;

-- RLS Policies
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own appointments"
ON appointments FOR SELECT
USING (auth.uid() = requester_id OR auth.uid() = recipient_id);

CREATE POLICY "Users can insert appointments they requested"
ON appointments FOR INSERT
WITH CHECK (auth.uid() = requester_id);

CREATE POLICY "Users can update their own appointments"
ON appointments FOR UPDATE
USING (auth.uid() = requester_id OR auth.uid() = recipient_id);
