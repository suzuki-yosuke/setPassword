# setPassword
## 用途
複数台のLinuxサーバに対して、パスワードを一斉に変更します。

## 前提条件
* 本プログラムの実行サーバからパスワード変更サーバに対して、キーを利用してroot権限でログインできる必要があります。

## 実行方法
```
# ruby setPassword.rb -a [ACCOUNT FILE] -k [SSH_KEY_FILE]
```

## Account File
以下の書式でパスワード変更対象のアカウントは設定して下さい。
(最初の行はヘッダーの為、削除しないこと！)
下記の例では、server1、10.7.22.41のroot,operatorユーザのパスワードを変更します。
```
host account
10.7.22.41 operator
server1 operator
10.7.22.41 root
server1 root
```
