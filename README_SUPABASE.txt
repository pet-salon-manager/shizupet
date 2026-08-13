しずペット - Supabase施設マスタ / 管理者専用編集版

この版で変わること
- 施設情報はSupabaseの public.facilities から読み込み
- 一般利用者：閲覧、検索、お気に入り、現在地から経路案内
- 管理者のみ：施設の追加、編集、削除
- 管理者判定は public.app_admins とRLSでサーバー側でも強制
- 管理者でない人が画面を改造しても、Supabase側が書き込みを拒否

初回セットアップ
1. Supabase → SQL Editor を開く
2. supabase_facilities_setup.sql を全て貼り付けて Run
3. しずペット → その他 → 管理者ログイン → アカウント作成
4. 必要ならメール確認後にログイン
5. Supabase SQL Editor で以下を実行（メールを自分のものに変更）

insert into public.app_admins(user_id)
select id from auth.users where email = 'あなたのメールアドレス';

6. アプリで一度ログアウト→ログイン
7. 「＋登録」「編集」「削除」が管理者だけに表示される

接続先
- Supabase URL と Publishable Key は index.html に設定済みです。
- Publishable Key はブラウザアプリに置く前提の公開キーです。
- service_role key は絶対にブラウザへ入れないでください。

GitHub Pages更新
- index.html / manifest.webmanifest / sw.js を既存 shizupet リポジトリへ上書き
- SQLファイルはGitHub公開に必須ではありません（セットアップ用）
