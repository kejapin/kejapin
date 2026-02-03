-- Add metadata columns to role_applications to capture state at time of submission
ALTER TABLE public.role_applications 
ADD COLUMN IF NOT EXISTS full_name TEXT,
ADD COLUMN IF NOT EXISTS phone_number TEXT,
ADD COLUMN IF NOT EXISTS national_id TEXT,
ADD COLUMN IF NOT EXISTS kra_pin TEXT,
ADD COLUMN IF NOT EXISTS company_name TEXT,
ADD COLUMN IF NOT EXISTS company_bio TEXT,
ADD COLUMN IF NOT EXISTS business_role TEXT,
ADD COLUMN IF NOT EXISTS payout_method TEXT,
ADD COLUMN IF NOT EXISTS payout_details TEXT;

-- Ensure RLS allows admins to see these new columns (already covered by existing policies usually, but good to be safe)
COMMENT ON TABLE public.role_applications IS 'Stores partner verification applications with captured user snapshot data.';
