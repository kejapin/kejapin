-- Update notifications type constraint to include FAVORITE
ALTER TABLE public.notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE public.notifications ADD CONSTRAINT notifications_type_check CHECK (type IN ('MESSAGE', 'FINANCIAL', 'SYSTEM', 'FAVORITE', 'EFFICIENCY'));

-- Update support_tickets policies for Admin access
DROP POLICY IF EXISTS "Admins can view all tickets" ON public.support_tickets;
CREATE POLICY "Admins can view all tickets" ON public.support_tickets
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid() AND users.role = 'ADMIN'
        )
    );

DROP POLICY IF EXISTS "Admins can update all tickets" ON public.support_tickets;
CREATE POLICY "Admins can update all tickets" ON public.support_tickets
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid() AND users.role = 'ADMIN'
        )
    );

-- Ensure users can view profiles of people they chat with
DROP POLICY IF EXISTS "Users can view profiles of chat partners" ON public.users;
CREATE POLICY "Users can view profiles of chat partners"
    ON public.users FOR SELECT
    USING (
        auth.uid() = id OR 
        EXISTS (
            SELECT 1 FROM public.messages
            WHERE (sender_id = auth.uid() AND recipient_id = users.id)
               OR (recipient_id = auth.uid() AND sender_id = users.id)
        )
    );
