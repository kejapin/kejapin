-- Add metadata column to notifications
ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS metadata JSONB;

-- Ensure sender can insert notification for recipient
DROP POLICY IF EXISTS "Users can create notifications for others" ON public.notifications;
CREATE POLICY "Users can create notifications for others"
ON public.notifications FOR INSERT
WITH CHECK (true); -- We rely on the app logic, but ideally we'd restrict it to message-related notifications
