-- しずペット：施設権限 修正版 v3

alter table public.facilities enable row level security;

-- 一般ユーザーは削除済み以外を閲覧
drop policy if exists facilities_public_read on public.facilities;
create policy facilities_public_read
on public.facilities
for select
to anon, authenticated
using (is_active is distinct from false);

-- 管理者は削除済みを含む全施設を閲覧可能
drop policy if exists facilities_admin_read_all on public.facilities;
create policy facilities_admin_read_all
on public.facilities
for select
to authenticated
using (public.is_app_admin());

-- 管理者だけ追加可能
drop policy if exists facilities_admin_insert on public.facilities;
create policy facilities_admin_insert
on public.facilities
for insert
to authenticated
with check (public.is_app_admin());

-- 管理者だけ更新可能
drop policy if exists facilities_admin_update on public.facilities;
create policy facilities_admin_update
on public.facilities
for update
to authenticated
using (public.is_app_admin())
with check (public.is_app_admin());

grant select on table public.facilities to anon, authenticated;
grant insert, update on table public.facilities to authenticated;

select
  count(*) as total,
  count(*) filter (where is_active is distinct from false) as visible,
  count(*) filter (where is_active = false) as deleted
from public.facilities;
