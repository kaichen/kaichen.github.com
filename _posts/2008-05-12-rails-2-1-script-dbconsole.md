---
layout: article
title: "[译文] Rails 2.1 dbconsole"
date: 2008-05-12 11:11
tags: ["Ruby", "ActiveRecord", "Ruby on Rails"]
---
原文连接：http://blog.codefront.net/2008/05/11/living-on-the-edge-of-rails-20-scriptdbconsole-and-flashnow-now-test-able/

script/dbconsole 脚本允许用户使用Rails的控制台客户端连接到数据库。

如果需要连接到MySQL的生产数据库作一些操作，直接运行 RAILS_ENV=production script/dbconsole 就能登录到数据库服务器上并使用MySQL的命令行客户端。当然，这个脚本也同样在 PostgreSQL 和 SQLite 数据库运行。

要在当前Rails应用程序中使用这个新脚本，就要先升级到edge Rails，再运行 rake rails:update:script 。好好享受这个脚本的便利吧。
