-- ComprAI — Initial Schema
-- 5 tables: lists, list_members, items, item_price_observations, purchase_history

-- Function to generate share codes
create or replace function generate_share_code()
returns text as $$
declare
  chars text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result text := '';
  i int;
begin
  for i in 1..6 loop
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  end loop;
  return result;
end;
$$ language plpgsql;

-- Lists
create table lists (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  emoji text default '🛒',
  share_code text unique default generate_share_code(),
  budget decimal(10,2),
  is_recurring boolean default false,
  archived_at timestamptz,
  created_by uuid references auth.users(id) not null,
  created_at timestamptz default now()
);

create index idx_lists_created_by on lists(created_by);
create index idx_lists_share_code on lists(share_code);

-- List Members
create table list_members (
  list_id uuid references lists(id) on delete cascade not null,
  user_id uuid references auth.users(id) not null,
  store_name text,
  joined_at timestamptz default now(),
  primary key (list_id, user_id)
);

create index idx_list_members_user on list_members(user_id);

-- Items
create table items (
  id uuid primary key default gen_random_uuid(),
  list_id uuid references lists(id) on delete cascade not null,
  name text not null,
  quantity text default '1',
  category text default 'outros',
  checked boolean default false,
  checked_by uuid references auth.users(id),
  added_by uuid references auth.users(id) not null,
  created_at timestamptz default now()
);

create index idx_items_list on items(list_id);

-- Item Price Observations
create table item_price_observations (
  id uuid primary key default gen_random_uuid(),
  item_id uuid references items(id) on delete cascade not null,
  user_id uuid references auth.users(id) not null,
  store_name text not null,
  price decimal(10,2) not null,
  observed_at timestamptz default now()
);

create index idx_price_obs_item on item_price_observations(item_id);

-- Purchase History
create table purchase_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) not null,
  list_id uuid references lists(id) on delete set null,
  list_name text not null,
  list_emoji text,
  item_name text not null,
  category text,
  quantity text,
  price decimal(10,2),
  store_name text,
  purchased_at timestamptz default now()
);

create index idx_history_user_list on purchase_history(user_id, list_name);
create index idx_history_purchased_at on purchase_history(purchased_at desc);

-- Auto-add creator as list member
create or replace function auto_add_creator_as_member()
returns trigger as $$
begin
  insert into list_members (list_id, user_id) values (new.id, new.created_by);
  return new;
end;
$$ language plpgsql;

create trigger trg_auto_add_creator
  after insert on lists
  for each row execute function auto_add_creator_as_member();

-- Enable Realtime
alter publication supabase_realtime add table items;
alter publication supabase_realtime add table item_price_observations;
alter publication supabase_realtime add table list_members;
