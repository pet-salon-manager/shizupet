-- しずペット：施設の編集・削除権限 修正版
-- 管理者だけが facilities を追加・更新できるようにします。

alter table public.facilities enable row level security;

-- 一般ユーザー/ログインユーザーは、削除済み以外の施設を閲覧可能
drop policy if exists facilities_public_read on public.facilities;
create policy facilities_public_read
on public.facilities
for select
to anon, authenticated
using (is_active is distinct from false);

-- 管理者だけ追加可能
drop policy if exists facilities_admin_insert on public.facilities;
create policy facilities_admin_insert
on public.facilities
for insert
to authenticated
with check (public.is_app_admin());

-- 管理者だけ更新可能
-- 削除ボタンは is_active=false への更新として動作します。
drop policy if exists facilities_admin_update on public.facilities;
create policy facilities_admin_update
on public.facilities
for update
to authenticated
using (public.is_app_admin())
with check (public.is_app_admin());

-- 必要な権限
grant select on table public.facilities to anon, authenticated;
grant insert, update on table public.facilities to authenticated;

-- 確認
select
  count(*) as total,
  count(*) filter (where is_active is distinct from false) as visible,
  count(*) filter (where is_active = false) as deleted
from public.facilities;
