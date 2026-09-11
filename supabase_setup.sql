-- Pokémon Draft Board – Supabase setup
-- Einmal im Supabase SQL Editor ausführen.

create extension if not exists pgcrypto;

create table if not exists public.draft_rooms (
  id uuid primary key default gen_random_uuid(),
  code text not null unique check (code ~ '^[A-Z0-9]{6}$'),
  player_count integer not null check (player_count between 4 and 8),
  trainer_names jsonb not null default '[]'::jsonb,
  host_user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.draft_room_members (
  room_id uuid not null references public.draft_rooms(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (room_id, user_id)
);

create table if not exists public.draft_picks (
  room_id uuid not null references public.draft_rooms(id) on delete cascade,
  pokemon_name text not null check (char_length(pokemon_name) between 1 and 80),
  player_index integer not null check (player_index between 0 and 7),
  points integer not null check (points between 1 and 20),
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now(),
  primary key (room_id, pokemon_name)
);

alter table public.draft_rooms enable row level security;
alter table public.draft_room_members enable row level security;
alter table public.draft_picks enable row level security;

revoke all on table public.draft_rooms from anon, authenticated;
revoke all on table public.draft_room_members from anon, authenticated;
revoke all on table public.draft_picks from anon, authenticated;

grant select on table public.draft_rooms to authenticated;
grant update (trainer_names) on table public.draft_rooms to authenticated;
grant select on table public.draft_room_members to authenticated;
grant select, insert, update, delete on table public.draft_picks to authenticated;

create or replace function public.is_draft_room_member(p_room_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.draft_room_members m
    where m.room_id = p_room_id
      and m.user_id = auth.uid()
  );
$$;

revoke all on function public.is_draft_room_member(uuid) from public;
grant execute on function public.is_draft_room_member(uuid) to authenticated;

drop policy if exists "members can read rooms" on public.draft_rooms;
create policy "members can read rooms"
on public.draft_rooms
for select
to authenticated
using (public.is_draft_room_member(id));

drop policy if exists "members can rename trainers" on public.draft_rooms;
create policy "members can rename trainers"
on public.draft_rooms
for update
to authenticated
using (public.is_draft_room_member(id))
with check (public.is_draft_room_member(id));

drop policy if exists "users can read own memberships" on public.draft_room_members;
create policy "users can read own memberships"
on public.draft_room_members
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "members can read picks" on public.draft_picks;
create policy "members can read picks"
on public.draft_picks
for select
to authenticated
using (public.is_draft_room_member(room_id));

drop policy if exists "members can add picks" on public.draft_picks;
create policy "members can add picks"
on public.draft_picks
for insert
to authenticated
with check (
  public.is_draft_room_member(room_id)
  and updated_by = auth.uid()
);

drop policy if exists "members can move picks" on public.draft_picks;
create policy "members can move picks"
on public.draft_picks
for update
to authenticated
using (public.is_draft_room_member(room_id))
with check (
  public.is_draft_room_member(room_id)
  and updated_by = auth.uid()
);

drop policy if exists "members can remove picks" on public.draft_picks;
create policy "members can remove picks"
on public.draft_picks
for delete
to authenticated
using (public.is_draft_room_member(room_id));

create or replace function public.create_draft_room(
  p_code text,
  p_player_count integer
)
returns table (
  id uuid,
  code text,
  player_count integer,
  trainer_names jsonb,
  host_user_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_room public.draft_rooms;
  v_names jsonb;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  if p_player_count < 4 or p_player_count > 8 then
    raise exception 'INVALID_PLAYER_COUNT';
  end if;

  if p_code !~ '^[A-Z0-9]{6}$' then
    raise exception 'INVALID_ROOM_CODE';
  end if;

  select jsonb_agg('Trainer ' || n order by n)
  into v_names
  from generate_series(1, p_player_count) as n;

  insert into public.draft_rooms (
    code, player_count, trainer_names, host_user_id
  )
  values (
    p_code, p_player_count, coalesce(v_names, '[]'::jsonb), auth.uid()
  )
  returning * into v_room;

  insert into public.draft_room_members (room_id, user_id)
  values (v_room.id, auth.uid())
  on conflict do nothing;

  return query
  select v_room.id, v_room.code, v_room.player_count,
         v_room.trainer_names, v_room.host_user_id;
end;
$$;

create or replace function public.join_draft_room(p_code text)
returns table (
  id uuid,
  code text,
  player_count integer,
  trainer_names jsonb,
  host_user_id uuid
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_room public.draft_rooms;
begin
  if auth.uid() is null then
    raise exception 'AUTH_REQUIRED';
  end if;

  select *
  into v_room
  from public.draft_rooms r
  where r.code = upper(p_code)
  limit 1;

  if not found then
    raise exception 'ROOM_NOT_FOUND';
  end if;

  insert into public.draft_room_members (room_id, user_id)
  values (v_room.id, auth.uid())
  on conflict do nothing;

  return query
  select v_room.id, v_room.code, v_room.player_count,
         v_room.trainer_names, v_room.host_user_id;
end;
$$;

create or replace function public.reset_draft_room(p_room_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.draft_rooms r
    where r.id = p_room_id
      and r.host_user_id = auth.uid()
  ) then
    raise exception 'HOST_ONLY';
  end if;

  delete from public.draft_picks
  where room_id = p_room_id;
end;
$$;

revoke all on function public.create_draft_room(text, integer) from public;
revoke all on function public.join_draft_room(text) from public;
revoke all on function public.reset_draft_room(uuid) from public;

grant execute on function public.create_draft_room(text, integer) to authenticated;
grant execute on function public.join_draft_room(text) to authenticated;
grant execute on function public.reset_draft_room(uuid) to authenticated;

create or replace function public.validate_draft_pick()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_player_count integer;
  v_points integer;
  v_pick_count integer;
begin
  -- Serialize changes for one receiving trainer so simultaneous picks
  -- cannot both pass the same 100-point / 10-pick check.
  perform pg_advisory_xact_lock(
    hashtextextended(new.room_id::text || ':' || new.player_index::text, 0)
  );

  select player_count
  into v_player_count
  from public.draft_rooms
  where id = new.room_id;

  if v_player_count is null or new.player_index >= v_player_count then
    raise exception 'INVALID_PLAYER';
  end if;

  select
    coalesce(sum(points), 0),
    count(*)
  into v_points, v_pick_count
  from public.draft_picks
  where room_id = new.room_id
    and player_index = new.player_index
    and pokemon_name <> new.pokemon_name;

  if v_points + new.points > 100 then
    raise exception 'MAX_BUDGET';
  end if;

  if v_pick_count + 1 > 10 then
    raise exception 'MAX_PICKS';
  end if;

  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists validate_draft_pick_trigger on public.draft_picks;
create trigger validate_draft_pick_trigger
before insert or update on public.draft_picks
for each row execute function public.validate_draft_pick();

-- Realtime: add the two synchronized tables to Supabase Realtime.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'draft_picks'
  ) then
    execute 'alter publication supabase_realtime add table public.draft_picks';
  end if;

  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'draft_rooms'
  ) then
    execute 'alter publication supabase_realtime add table public.draft_rooms';
  end if;
end $$;
