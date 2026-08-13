-- しずペット：施設マスタ + 管理者専用編集
-- Supabase SQL Editor で一度だけ実行してください。

create table if not exists public.app_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.facilities (
  id text primary key,
  name text not null,
  area text not null check (area in ('東部','中部','西部','伊豆')),
  city text,
  address text,
  type text not null check (type in ('動物病院','トリミング','ペット用品','ドッグラン','ペット同伴','宿泊','その他')),
  url text,
  phone text,
  memo text,
  lat double precision,
  lng double precision,
  approx boolean not null default true,
  sort_order integer not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists facilities_set_updated_at on public.facilities;
create trigger facilities_set_updated_at before update on public.facilities
for each row execute function public.set_updated_at();

create or replace function public.is_app_admin() returns boolean
language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.app_admins a where a.user_id = auth.uid());
$$;

revoke all on function public.is_app_admin() from public;
grant execute on function public.is_app_admin() to anon, authenticated;

alter table public.facilities enable row level security;
alter table public.app_admins enable row level security;

grant select on table public.facilities to anon, authenticated;
grant insert, update, delete on table public.facilities to authenticated;

drop policy if exists facilities_public_read on public.facilities;
create policy facilities_public_read on public.facilities for select
using (is_active = true or public.is_app_admin());

drop policy if exists facilities_admin_insert on public.facilities;
create policy facilities_admin_insert on public.facilities for insert to authenticated
with check (public.is_app_admin());

drop policy if exists facilities_admin_update on public.facilities;
create policy facilities_admin_update on public.facilities for update to authenticated
using (public.is_app_admin()) with check (public.is_app_admin());

drop policy if exists facilities_admin_delete on public.facilities;
create policy facilities_admin_delete on public.facilities for delete to authenticated
using (public.is_app_admin());

-- app_admins はクライアントから直接読めない/書けないままにします。
revoke all on table public.app_admins from anon, authenticated;

-- 現在の43件を施設マスタへ投入（同じidがあれば更新）
insert into public.facilities
(id,name,area,city,address,type,url,phone,memo,lat,lng,approx,sort_order,is_active) values
('r1','伊豆高原わんわんパラダイスホテル＆コテージ','伊豆','伊東市',null,'宿泊',null,null,'実在施設。ペット同伴宿泊施設。最新の営業情報・利用条件は公式情報で確認してください。',34.9029,139.1038,false,1,true),
('r2','愛犬お宿 伊豆高原','伊豆','伊東市',null,'宿泊',null,null,'実在施設。愛犬同伴型の宿泊施設。最新情報は公式情報で確認してください。',34.8898,139.1069,false,2,true),
('r3','ウブドの森 伊豆高原','伊豆','伊東市',null,'宿泊',null,null,'実在施設。愛犬同伴型の宿泊施設。最新情報は公式情報で確認してください。',34.8899,139.1098,false,3,true),
('r4','伊豆ぐらんぱる公園','伊豆','伊東市',null,'ペット同伴',null,null,'実在施設。ペット同伴エリア・利用条件があります。最新情報は公式情報で確認してください。',34.9077,139.12,false,4,true),
('r5','伊豆シャボテン動物公園','伊豆','伊東市',null,'ペット同伴',null,null,'実在施設。ペット同伴に条件があります。最新情報は公式情報で確認してください。',34.9075,139.1014,false,5,true),
('r6','伊豆ドッグランド','伊豆','伊豆市',null,'ドッグラン',null,null,'実在するドッグラン施設。最新の営業情報は公式情報で確認してください。',34.9515,138.9784,false,6,true),
('r18','伊豆マウンテンドッグラン','伊豆','東伊豆町',null,'ドッグラン',null,null,'実在するドッグラン。営業日・利用条件は公式情報で確認してください。',34.817,139.06,false,7,true),
('r19','伊豆アニマルキングダム','伊豆','東伊豆町',null,'ペット同伴',null,null,'実在施設。ペット同伴可否・対象エリアは最新の公式案内を確認してください。',34.814,139.043,false,8,true),
('r20','修善寺 虹の郷','伊豆','伊豆市',null,'ペット同伴',null,null,'実在施設。ペット入園条件は最新の公式案内を確認してください。',34.979,138.911,false,9,true),
('r21','小室山リッジウォーク MISORA','伊豆','伊東市',null,'ペット同伴',null,null,'実在施設。ペット同伴条件・リフト利用条件は公式情報で確認してください。',34.949,139.13,false,10,true),
('r22','大室山','伊豆','伊東市',null,'ペット同伴',null,null,'実在観光スポット。ペットのリフト利用条件等は最新の公式情報で確認してください。',34.903,139.094,false,11,true),
('r7','朝霧高原 Field Dogs Garden','東部','富士宮市',null,'ドッグラン',null,null,'実在施設。ドッグラン・キャンプ等を備える施設。最新情報は公式情報で確認してください。',35.3304,138.5967,false,12,true),
('r8','富士ミルクランド','東部','富士宮市',null,'ペット同伴',null,null,'実在施設。ペット同伴可否やエリアは最新の施設案内を確認してください。',35.2961,138.596,false,13,true),
('r9','EXPASA足柄（下り）ドッグラン','東部','小山町',null,'ドッグラン',null,null,'実在するサービスエリア内ドッグラン。利用状況はNEXCO中日本の最新情報で確認してください。',35.3216,138.9477,false,14,true),
('r10','EXPASA足柄（上り）ドッグラン','東部','小山町',null,'ドッグラン',null,null,'実在するサービスエリア内ドッグラン。利用状況はNEXCO中日本の最新情報で確認してください。',35.3152,138.9493,false,15,true),
('r11','NEOPASA駿河湾沼津（上り）ドッグラン','東部','沼津市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',35.1323,138.838,false,16,true),
('r12','NEOPASA駿河湾沼津（下り）ドッグラン','東部','沼津市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',35.1294,138.8387,false,17,true),
('r23','御殿場プレミアム・アウトレット','東部','御殿場市',null,'ペット同伴',null,null,'実在施設。ペット同伴可能エリアや入店条件は各店舗・公式案内で確認してください。',35.306,138.963,false,18,true),
('r24','富士山樹空の森','東部','御殿場市',null,'ペット同伴',null,null,'実在施設。ペット同伴可能範囲・利用ルールは公式案内で確認してください。',35.293,138.855,false,19,true),
('r25','カインズ 沼津店','東部','沼津市',null,'ペット用品',null,null,'実在するホームセンター店舗。ペット用品の取扱内容・併設サービスは公式店舗情報で確認してください。',35.0956,138.8634,true,20,true),
('r26','カインズ 富士宮店','東部','富士宮市',null,'ペット用品',null,null,'実在するホームセンター店舗。ペット用品の取扱内容・併設サービスは公式店舗情報で確認してください。',35.2221,138.6216,true,21,true),
('r27','PETEMO 富士宮店','東部','富士宮市',null,'ペット用品',null,null,'実在するペット関連店舗。取扱商品・グルーミング等のサービスは最新の公式店舗情報で確認してください。',35.2221,138.6216,true,22,true),
('r28','ペットショップCoo&RIKU 沼津店','東部','沼津市',null,'ペット用品',null,null,'実在するペットショップ。営業時間・サービス内容は公式店舗情報で確認してください。',35.0956,138.8634,true,23,true),
('r13','NEOPASA静岡（上り）ドッグラン','中部','静岡市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',35.062,138.2995,false,24,true),
('r14','NEOPASA静岡（下り）ドッグラン','中部','静岡市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',35.0588,138.2983,false,25,true),
('r29','日本平夢テラス','中部','静岡市',null,'ペット同伴',null,null,'実在観光施設。ペット同伴条件・館内立入条件は公式案内で確認してください。',34.974,138.468,false,26,true),
('r30','三保松原','中部','静岡市',null,'ペット同伴',null,null,'実在する景勝地。散策時は現地ルール・マナーを確認してください。',35,138.523,false,27,true),
('r31','カインズ 清水店','中部','静岡市',null,'ペット用品',null,null,'実在するホームセンター店舗。ペット用品の取扱内容・併設サービスは公式店舗情報で確認してください。',34.9756,138.3828,true,28,true),
('r32','ペットショップCoo&RIKU 静岡SBS通り店','中部','静岡市',null,'ペット用品',null,null,'実在するペットショップ。営業時間・サービス内容は公式店舗情報で確認してください。',34.9756,138.3828,true,29,true),
('r33','静岡動物医療センター','中部','静岡市',null,'動物病院',null,null,'実在する動物医療施設。診療時間・診療科・救急対応は必ず公式情報で確認してください。',34.9756,138.3828,true,30,true),
('r34','PETEMO 焼津店','中部','焼津市',null,'ペット用品',null,null,'実在するペット関連店舗。取扱商品・グルーミング等のサービスは最新の公式店舗情報で確認してください。',34.8669,138.3231,true,31,true),
('r35','PETEMO グルーミングサロン 焼津店','中部','焼津市',null,'トリミング',null,null,'実在店舗系列のグルーミングサービス。予約・受付条件は最新の公式店舗情報で確認してください。',34.8669,138.3231,true,32,true),
('r15','NEOPASA浜松（上り）ドッグラン','西部','浜松市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',34.8346,137.7302,false,33,true),
('r16','NEOPASA浜松（下り）ドッグラン','西部','浜松市',null,'ドッグラン',null,null,'実在する新東名SA内ドッグラン。最新情報はNEXCO中日本で確認してください。',34.8318,137.7287,false,34,true),
('r17','HAMA&WAN','西部','浜松市',null,'ドッグラン',null,null,'実在する浜松市のペット関連施設。最新の営業内容は公式情報で確認してください。',34.7366,137.6997,false,35,true),
('r36','浜名湖ガーデンパーク','西部','浜松市',null,'ペット同伴',null,null,'実在する県営公園。ペット同伴ルール・立入制限は公式案内で確認してください。',34.713,137.596,false,36,true),
('r37','浜名湖パルパル','西部','浜松市',null,'ペット同伴',null,null,'実在施設。ペット同伴可否や条件は最新の公式案内で確認してください。',34.761,137.618,false,37,true),
('r38','カインズ 浜松雄踏店','西部','浜松市',null,'ペット用品',null,null,'実在するホームセンター店舗。ペット用品の取扱内容・併設サービスは公式店舗情報で確認してください。',34.7108,137.7261,true,38,true),
('r39','PETEMO 浜松志都呂店','西部','浜松市',null,'ペット用品',null,null,'実在するペット関連店舗。取扱商品・グルーミング等のサービスは最新の公式店舗情報で確認してください。',34.7108,137.7261,true,39,true),
('r40','PETEMO 浜松市野店','西部','浜松市',null,'ペット用品',null,null,'実在するペット関連店舗。取扱商品・グルーミング等のサービスは最新の公式店舗情報で確認してください。',34.7108,137.7261,true,40,true),
('r41','ペットショップCoo&RIKU 浜松店','西部','浜松市',null,'ペット用品',null,null,'実在するペットショップ。営業時間・サービス内容は公式店舗情報で確認してください。',34.7108,137.7261,true,41,true),
('r42','PETEMO グルーミングサロン 浜松志都呂店','西部','浜松市',null,'トリミング',null,null,'実在店舗系列のグルーミングサービス。予約・受付条件は最新の公式店舗情報で確認してください。',34.7108,137.7261,true,42,true),
('r43','PETEMO グルーミングサロン 浜松市野店','西部','浜松市',null,'トリミング',null,null,'実在店舗系列のグルーミングサービス。予約・受付条件は最新の公式店舗情報で確認してください。',34.7108,137.7261,true,43,true)
on conflict (id) do update set
 name=excluded.name, area=excluded.area, city=excluded.city, address=excluded.address,
 type=excluded.type, url=excluded.url, phone=excluded.phone, memo=excluded.memo,
 lat=excluded.lat, lng=excluded.lng, approx=excluded.approx, sort_order=excluded.sort_order,
 is_active=excluded.is_active;

-- ★ 管理者アカウント作成後、下のメールアドレスだけ自分のものに変更して実行してください。
-- insert into public.app_admins(user_id)
-- select id from auth.users where email = 'あなたのメールアドレス';

-- 確認
select count(*) as facility_count from public.facilities;
