-- ComprAI — Row Level Security Policies

alter table lists enable row level security;
alter table list_members enable row level security;
alter table items enable row level security;
alter table item_price_observations enable row level security;
alter table purchase_history enable row level security;

-- Helper: check if user is member of a list
create or replace function is_list_member(p_list_id uuid)
returns boolean as $$
  select exists (
    select 1 from list_members where list_id = p_list_id and user_id = auth.uid()
  );
$$ language sql security definer stable;

-- LISTS
create policy "Members can view their lists"
  on lists for select using (is_list_member(id));

create policy "Authenticated users can create lists"
  on lists for insert with check (auth.uid() = created_by);

create policy "Only creator can update list"
  on lists for update using (auth.uid() = created_by);

create policy "Only creator can delete list"
  on lists for delete using (auth.uid() = created_by);

-- LIST_MEMBERS
create policy "Members can view other members"
  on list_members for select using (is_list_member(list_id));

create policy "Members can join via share code (insert)"
  on list_members for insert with check (auth.uid() = user_id);

create policy "Members can leave (delete own)"
  on list_members for delete using (auth.uid() = user_id);

create policy "Members can update own store_name"
  on list_members for update using (auth.uid() = user_id);

-- ITEMS
create policy "Members can view items"
  on items for select using (is_list_member(list_id));

create policy "Members can add items"
  on items for insert with check (is_list_member(list_id) and auth.uid() = added_by);

create policy "Members can update items"
  on items for update using (is_list_member(list_id));

create policy "Members can delete items"
  on items for delete using (is_list_member(list_id));

-- ITEM_PRICE_OBSERVATIONS
create policy "Members can view prices"
  on item_price_observations for select
  using (exists (
    select 1 from items i where i.id = item_id and is_list_member(i.list_id)
  ));

create policy "Members can insert prices"
  on item_price_observations for insert
  with check (auth.uid() = user_id and exists (
    select 1 from items i where i.id = item_id and is_list_member(i.list_id)
  ));

-- PURCHASE_HISTORY
create policy "Users can view own history"
  on purchase_history for select using (auth.uid() = user_id);

create policy "Users can insert own history"
  on purchase_history for insert with check (auth.uid() = user_id);
