---
layout: page
title: "Inspect Rails"
comments: false
sharing: true
footer: true
---

这是一本关于Ruby on Rails框架内部实现的书，目标针对中高级开发者，帮助大家去理解Rails的实现和设计，在阅读本书之后能一直跟进Rails框架的源码更新。本书是基于Rails 4.0 stable编写的。

目前完成度已经有40%，正在陆续整理并发布上来。

- Framework Structure
  - [Components](/2013/06/12/dependencies-of-rails)
  - Assets Pipeline Dependences
  - Rails Doc
- Rails Applcation
  - [Railite Hierarchy](/2013/06/14/rails-internal-hierarchy/)
  - [File Convension](/2013/07/12/rails-paths/)
  - [Code Loading](/2013/07/04/code-loading-of-rails/)
  - Rails Application booting under hook
  - Rails Middleware Stack
- ActionDispatch
  - HTTP Hack base on Rack
  - Middlewares
  - Routing
- ActionView
  - [Rendering Stack](/2013/08/10/actionview-architect)
  - Renderers
  - Template Lookup
  - Handle Template
  - [Safe Output Buffer](/2013/08/17/actionview-safe-buffer)
- ActiveRecord
  - ORM Pattern
  - [Assemble ActiveRecord Object](/2013/07/26/assemble-ar-object)
  - Attribute Serialization
  - Database Connection
  - SQL Generation
  - Association Mapping
- ActionMailer

评论、问题、意见或建议都可以发表在本书自带的 Disqus 论坛里， 也可以通过 [豆瓣][1] 、 [Ruby China][2] 或 [Twitter][0] 联系我， 我会尽可能地回复。

要获得本书的最新动态，可以订阅我博客的[RSS](http://thekaiway.com/atom.xml)。

[0]: https://twitter.com/_kaichen
[1]: http://www.douban.com/people/chenk85/
[2]: http://ruby-china.org/_kaichen
