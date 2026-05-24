-- ─────────────────────────────────────────────────────────────
-- TrackR — Supabase database setup
-- Run this in: supabase.com → your project → SQL Editor → New query
-- ─────────────────────────────────────────────────────────────

-- 1. Profiles (one row per user)
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'User',
  created_at timestamptz default now()
);

alter table profiles enable row level security;

create policy "Users can read all profiles"
  on profiles for select using (true);

create policy "Users can update own profile"
  on profiles for update using (auth.uid() = id);

create policy "Users can insert own profile"
  on profiles for insert with check (auth.uid() = id);


-- 2. Locations (one row per user, upserted on every GPS update)
create table if not exists locations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  altitude_m double precision not null default 0,
  speed_kmh double precision not null default 0,
  updated_at timestamptz default now(),
  unique(user_id)
);

alter table locations enable row level security;

create policy "Users can upsert own location"
  on locations for all using (auth.uid() = user_id);

create policy "Anyone in a share can read locations"
  on locations for select using (
    exists (
      select 1 from location_shares
      where (shared_user_id = user_id and shared_with_user_id = auth.uid())
         or (shared_user_id = auth.uid() and shared_with_user_id = user_id)
    )
  );


-- 3. Location shares (who can see who)
create table if not exists location_shares (
  id uuid primary key default gen_random_uuid(),
  shared_user_id uuid not null references auth.users(id) on delete cascade,
  shared_with_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz default now(),
  unique(shared_user_id, shared_with_user_id)
);

alter table location_shares enable row level security;

create policy "Users can manage their own shares"
  on location_shares for all using (
    auth.uid() = shared_user_id or auth.uid() = shared_with_user_id
  );


-- 4. Enable Realtime on locations table
-- (Do this in Supabase dashboard: Database → Replication → toggle locations ON)
-- Or run:
alter publication supabase_realtime add table locations;
