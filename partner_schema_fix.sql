-- 1. Add missing partner columns to the users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS company_name TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS company_bio TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS national_id TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS kra_pin TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS business_role TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS payout_method TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS payout_details TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS v_status TEXT DEFAULT 'PENDING';

-- 2. Setup Storage Bucket for Verifications (if not exists)
-- This is usually done in the Supabase UI, but we can attempt to set polices if it exists
-- Bucket name: verification-documents

-- 3. Storage Policies for Verification Documents
-- Allow users to upload to their own folder
-- Allow admins to see everything

-- Note: 'storage' is a separate schema in Supabase
-- POLICY: Admins can view everything in the verification-documents bucket
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'verification-documents') THEN
        DROP POLICY IF EXISTS "Admins can view verification documents" ON storage.objects;
        CREATE POLICY "Admins can view verification documents" ON storage.objects
            FOR SELECT TO authenticated
            USING (
                bucket_id = 'verification-documents' AND 
                (
                    EXISTS (
                        SELECT 1 FROM public.users
                        WHERE users.id = auth.uid() AND users.role = 'ADMIN'
                    )
                    OR
                    (auth.uid()::text = (storage.foldername(name))[1])
                )
            );
    END IF;
END $$;
