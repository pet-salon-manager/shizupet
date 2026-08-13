-- しずペット：おすすめ店舗 + クーポン機能
alter table public.facilities
  add column if not exists recommended boolean not null default false,
  add column if not exists sponsored boolean not null default false,
  add column if not exists coupon_enabled boolean not null default false,
  add column if not exists coupon_title text,
  add column if not exists coupon_code text,
  add column if not exists coupon_terms text;

select count(*) as total, count(*) filter (where recommended) as recommended_count, count(*) filter (where coupon_enabled) as coupon_count from public.facilities;
