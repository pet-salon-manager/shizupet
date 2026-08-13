alter table public.facilities
add column if not exists recommended boolean not null default false;

select count(*) as total,
       count(*) filter (where recommended) as recommended_count
from public.facilities;
