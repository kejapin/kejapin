-- SUPABASE STORAGE POLICIES FOR 'profile-pics' BUCKET

-- 1. Create the bucket (if not exists)
insert into storage.buckets (id, name, public)
values ('profile-pics', 'profile-pics', true)
on conflict (id) do nothing;

-- Note: We skip 'alter table storage.objects enable row level security' as it requires superuser privileges 
-- and is usually enabled by default in Supabase.

-- 2. Drop existing policies to avoid conflicts when re-running
drop policy if exists "Public Access to Profile Pics" on storage.objects;
drop policy if exists "User can upload own profile pic" on storage.objects;
drop policy if exists "User can update own profile pic" on storage.objects;
drop policy if exists "User can delete own profile pic" on storage.objects;

-- 3. Policy: Public Read Access (Everyone can view profile pics)
create policy "Public Access to Profile Pics"
on storage.objects for select
to public
using ( bucket_id = 'profile-pics' );

-- 4. Policy: Authenticated users can upload their own profile pic
-- Restricts uploads to a folder named after their User ID to prevent overwriting others.
create policy "User can upload own profile pic"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'profile-pics' and
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 5. Policy: Authenticated users can update their own profile pic
create policy "User can update own profile pic"
on storage.objects for update
to authenticated
using (
  bucket_id = 'profile-pics' and
  (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'profile-pics' and
  (storage.foldername(name))[1] = auth.uid()::text
);

-- 6. Policy: Authenticated users can delete their own profile pic
create policy "User can delete own profile pic"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'profile-pics' and
  (storage.foldername(name))[1] = auth.uid()::text
);
