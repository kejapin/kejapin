-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- USERS TABLE (Extends Supabase Auth)
create table if not exists public.users (
  id uuid references auth.users not null primary key,
  email text,
  phone_number text,
  first_name text,
  last_name text,
  role text check (role in ('TENANT', 'LANDLORD', 'ADMIN', 'AGENT')) default 'TENANT',
  profile_picture text,
  is_premium boolean default false,
  is_verified boolean default false,
  last_login timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for users
alter table public.users enable row level security;

-- Policies for users
drop policy if exists "Public profiles are viewable by everyone" on users;
create policy "Public profiles are viewable by everyone"
  on users for select
  using ( true );

drop policy if exists "Users can update own profile" on users;
create policy "Users can update own profile"
  on users for update
  using ( auth.uid() = id );

-- PROPERTIES TABLE
create table if not exists public.properties (
  id uuid default uuid_generate_v4() primary key,
  owner_id uuid references public.users(id) not null,
  title text not null,
  description text,
  listing_type text default 'RENT' check (listing_type in ('RENT', 'SALE')),
  property_type text not null check (property_type in ('BEDSITTER', '1BHK', '2BHK', 'SQ', 'BUNGALOW')),
  price_amount numeric not null,
  latitude float8 not null,
  longitude float8 not null,
  address_line_1 text,
  city text not null,
  county text not null,
  amenities text,
  photos text,
  bedrooms int default 0,
  bathrooms int default 0,
  status text default 'AVAILABLE' check (status in ('AVAILABLE', 'OCCUPIED', 'SOLD')),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for properties
alter table public.properties enable row level security;

drop policy if exists "Properties are viewable by everyone" on properties;
create policy "Properties are viewable by everyone"
  on properties for select
  using ( true );

drop policy if exists "Landlords can insert properties" on properties;
create policy "Landlords can insert properties"
  on properties for insert
  with check ( auth.uid() = owner_id );

drop policy if exists "Landlords can update own properties" on properties;
create policy "Landlords can update own properties"
  on properties for update
  using ( auth.uid() = owner_id );

drop policy if exists "Landlords can delete own properties" on properties;
create policy "Landlords can delete own properties"
  on properties for delete
  using ( auth.uid() = owner_id );

-- LIFE PINS TABLE
create table if not exists public.life_pins (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  label text not null,
  latitude float8 not null,
  longitude float8 not null,
  transport_mode text not null check (transport_mode in ('WALK', 'DRIVE', 'CYCLE', 'PUBLIC_TRANSPORT')),
  is_primary boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for life_pins
alter table public.life_pins enable row level security;

drop policy if exists "Users can view own life pins" on life_pins;
create policy "Users can view own life pins"
  on life_pins for select
  using ( auth.uid() = user_id );

drop policy if exists "Users can insert own life pins" on life_pins;
create policy "Users can insert own life pins"
  on life_pins for insert
  with check ( auth.uid() = user_id );

drop policy if exists "Users can update own life pins" on life_pins;
create policy "Users can update own life pins"
  on life_pins for update
  using ( auth.uid() = user_id );

drop policy if exists "Users can delete own life pins" on life_pins;
create policy "Users can delete own life pins"
  on life_pins for delete
  using ( auth.uid() = user_id );

-- MESSAGES TABLE
create table if not exists public.messages (
  id uuid default uuid_generate_v4() primary key,
  sender_id uuid references public.users(id) not null,
  recipient_id uuid references public.users(id) not null,
  property_id uuid references public.properties(id),
  content text not null,
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for messages
alter table public.messages enable row level security;

drop policy if exists "Users can view their own messages" on messages;
create policy "Users can view their own messages"
  on messages for select
  using ( auth.uid() = sender_id or auth.uid() = recipient_id );

drop policy if exists "Users can send messages" on messages;
create policy "Users can send messages"
  on messages for insert
  with check ( auth.uid() = sender_id );

-- NOTIFICATIONS TABLE
create table if not exists public.notifications (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  title text not null,
  message text not null,
  type text not null check (type in ('MESSAGE', 'FINANCIAL', 'SYSTEM')),
  is_read boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for notifications
alter table public.notifications enable row level security;

drop policy if exists "Users can view own notifications" on notifications;
create policy "Users can view own notifications"
  on notifications for select
  using ( auth.uid() = user_id );

-- TRIGGERS to handle user creation
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, email, first_name, last_name, role)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'first_name',
    new.raw_user_meta_data->>'last_name',
    coalesce(new.raw_user_meta_data->>'role', 'TENANT')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger: Check if exists logic for triggers is tricky in standard SQL, usually handled by dropping first
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- SAVED LISTINGS TABLE
create table if not exists public.saved_listings (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references public.users(id) not null,
  property_id uuid references public.properties(id) not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  unique(user_id, property_id)
);

-- Enable RLS for saved_listings
alter table public.saved_listings enable row level security;

drop policy if exists "Users can view own saved listings" on saved_listings;
create policy "Users can view own saved listings"
  on saved_listings for select
  using ( auth.uid() = user_id );

drop policy if exists "Users can save listings" on saved_listings;
create policy "Users can save listings"
  on saved_listings for insert
  with check ( auth.uid() = user_id );

drop policy if exists "Users can unsave listings" on saved_listings;
create policy "Users can unsave listings"
  on saved_listings for delete
  using ( auth.uid() = user_id );
