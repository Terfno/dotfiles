```sh
brew install rclone
```

client_id と client_secret は Google Cloud Console からとってきて
```sh
cp .env.example .env
```

Ruby が必要。
```sh
ruby render-config.rb
```
rclone.conf が生まれる。
やってることはシンプルで、rclone.conf.erb を ERB でレンダリングして rclone.conf を生成しているだけ。

token は別途生成が必要なので↓のコマンドで得る。
```sh
rclone config reconnect privat-googledrive:
```
