-- 1. Grant Admins permission to update user roles and status
DROP POLICY IF EXISTS "Admins can update any profile" ON public.users;
CREATE POLICY "Admins can update any profile"
  ON public.users FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- 2. Ensure your admin user actually has the ADMIN role
-- (Replace with your actual admin user ID if known, or use the email as a filter)
UPDATE public.users 
SET role = 'ADMIN' 
WHERE email = 'kejapinmail@gmail.com';

-- 3. Also allow any user to see if they are verified (fallback)
DROP POLICY IF EXISTS "Users can see own verification status" ON public.users;
CREATE POLICY "Users can see own verification status"
  ON public.users FOR SELECT
  USING (auth.uid() = id);
