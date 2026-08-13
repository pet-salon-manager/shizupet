-- 施設のホームページURL登録状況を確認
select
  count(*) as total_facilities,
  count(url) filter (where nullif(trim(url), '') is not null) as with_homepage,
  count(*) - count(url) filter (where nullif(trim(url), '') is not null) as without_homepage
from public.facilities;

-- URL未登録施設一覧
select id, name, area, city, type, url
from public.facilities
where nullif(trim(url), '') is null
order by area, city, name;
