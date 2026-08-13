しずペット - Supabase接続完成版

接続先
- Project URL: https://abofyfovxysqzchstnbx.supabase.co
- Browser key: Publishable key を使用
- Secret key / service_role key は使用していません

施設情報
- public.facilities から読み込み
- 一般ユーザー: 閲覧 / 検索 / お気に入り / 地図 / 経路案内
- 管理者: 追加 / 編集 / 削除
- 管理者権限は app_admins + RLS でSupabase側でも制限

管理者
- すでにSupabase app_adminsへ登録済みのユーザーでログイン
- 公開アプリからの管理者アカウント新規作成ボタンは非表示

GitHub Pages更新
1. index.html を新しいものへ上書き
2. sw.js も新しいものへ上書き
3. manifest.webmanifest はそのまま上書き
4. GitHub Pages公開URLをSafariで再読み込み
