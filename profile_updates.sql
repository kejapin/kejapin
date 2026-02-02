-- PROFILE UPDATES SQL
-- Add username, bio, and profile_completed flag to users table

-- 1. Add columns
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS username TEXT UNIQUE;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT FALSE;

-- 2. Update existing users (optional: generate a simple username from email if not present)
UPDATE public.users 
SET username = lower(split_part(email, '@', 1)) || '_' || substring(id::text, 1, 4)
WHERE username IS NULL;

-- 3. Update handle_new_user function to auto-generate a username if not provided in meta_data
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  generated_username TEXT;
BEGIN
  -- Try to get username from metadata first, fallback to email prefix + short id
  generated_username := COALESCE(
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'full_name',
    lower(split_part(new.email, '@', 1)) || '_' || substring(new.id::text, 1, 4)
  );

  INSERT INTO public.users (id, email, first_name, last_name, username, role, profile_completed)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    generated_username,
    COALESCE(new.raw_user_meta_data->>'role', 'TENANT'),
    FALSE -- New users start with incomplete profile
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
