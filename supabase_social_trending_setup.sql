-- しずペットマップ：SNS話題スポット機能
alter table public.facilities
add column if not exists trending boolean not null default false;

select
  count(*) as total_facilities,
  count(*) filter (where trending) as trending_count
from public.facilities;
