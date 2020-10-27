# livepush
1. キーワードを入力
1. ツイッターのタイムラインを定期的に取得（API/スクレイピング）
1. 「放送，始まった」などの開始コメントが確認されたら，プッシュ通知を送る（service worker）

- 下の方で，タイムラインを流す．
- 「始まった」

# herokuへのアップ方法
```
heroku apps:destroy -a livepush --confirm livepush
git remote rm heroku


git clone git@github.com:shoot16625/livepush.git
cd livepush/Go

(
heroku login
heroku container:login
)
heroku create -a livepush
heroku git:remote -a livepush

heroku container:push web -a livepush
heroku container:release web -a livepush
heroku logs --tail

```

# conohaへのアップ方法
```

cd livepush
git fetch origin master

git reset --hard origin/master
rm docker-compose.yml Go/Procfile Go/Dockerfile Go/Dockerfile.dev
mv docker-compose-prod.yml docker-compose.yml

```