---
layout: page
title: "Inspect Rails"
date: 2013-06-12 21:22
comments: false
sharing: true
footer: true
---

这是一本关于Ruby on Rails框架内部实现的书，目标针对中高级开发者，帮助大家去理解Rails的实现和设计，在阅读本书之后能一直跟进Rails框架的源码更新。本书是基于Rails 4.0 stable编写的。

目前完成度已经有30%，正在陆续整理并发布上来。

- Ruby on Rails框架的构成
  - [Ruby on Rails的组件](/2013/06/12/dependencies-of-rails)
  - Assets Pipeline带来的依赖
  - Rails Doc
- Rails Applcation
  - Railite
  - Rails Engine
  - Code Loading
  - Rails Application
  - Rails Middleware
- ActionDispatch
  - HTTP Hack base on Rack
  - Middlewares
  - Routing
- ActionView
  - AV::Renderer
  - Lookup Context
  - ActionView::Base
  - View Paths
  - Resolvers
  - Template handler
- ActiveRecord
  - ORM Pattern
  - ActiveRecord Object的组装
  - Attribute Serialization
  - Database Connection
  - SQL Generation
  - Association Mapping
- ActionMailer
