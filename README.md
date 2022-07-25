# メモアプリ
Sinatraの練習で作ったメモアプリです。

## DBの準備
```
CREATE DATABASE memoapp;

memoapp=$ CREATE TABLE memo(
id SERIAL NOT NULL,
title VARCHAR(100) NOT NULL,
content VARCHAR(255) NOT NULL,
PRIMARY KEY (id));
```

## 実行手順
```
git clone https://github.com/bouru02/sinatra-practice.git
cd sinatra_practice
bundle install
ruby app.rb
```
