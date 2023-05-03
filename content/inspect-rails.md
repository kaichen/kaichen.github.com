---
layout: layouts/base.njk
title: "Inspect Rails"
date: 2013-06-12
description: "About rails framework implementation under the hook"
tags: ["series"]
---

# Inspect Rails

这是一本关于Ruby on Rails框架内部实现的书，目标针对中高级开发者，帮助大家去理解Rails的实现和设计，在阅读本书之后能一直跟进Rails框架的源码更新。本书是基于Rails 4.0 stable编写的。

目前完成度已经有40%，已停止更新

- Framework Structure
  - [Components](/2013-06-12-dependencies-of-rails)
    <br>Rails有多少个组件，每个组件还有哪些依赖
  - Assets Pipeline Dependences
    <br>Assets Pipeline为Rails带来了哪些依赖
  - Rails Doc
    <br>Rails的官方文档有哪些，是如何组织和编写的
- Rails Applcation
  - [Railite Hierarchy](/2013/06/14/rails-internal-hierarchy/)
    <br>Railite是所有组件整合在一起的核心，Rails应用和Rails Engine是怎样的一个关系</i>
  - [File Convension](/2013/07/12/rails-paths/)
    <br>Rails的Convention Over Configuration是怎样实现的
  - [Code Loading](/2013/07/04/code-loading-of-rails/)
    <br>Rails会自动加载内部
  - Rails Application booting under hook
    <br>Rails应用的启动流程
  - Rails Middleware Stack
    <br>Rails的中间件栈组织机制
- ActionDispatch
  - HTTP Hack base on Rack
  - Middlewares
  - Routing
- ActionView
  - [Rendering Stack](/2013/08/10/actionview-architect)
    <br>整个ActionView的Stack是怎么组织
  - Renderers
  - Template Lookup
    <br>ActionView是如何找到正确的模版
  - Handle Template
  - [Safe Output Buffer](/2013/08/17/actionview-safe-buffer)
    <br>ActionView的Buffer机制怎样处理
- ActiveRecord
  - [Assemble ActiveRecord Object](/2013/07/26/assemble-ar-object)
    <br>数据记录如何变成AR对象
  - Table Mapping
    <br>数据库表结构怎样映射到AR模型
  - [Read and Write Attribute](/2013/09/08/read-write-activerecord-attribute)
    <br>关于属性的读写和方法生成
  - Dynamic Finder
    <br>被最多人谈论的动态查询方法是怎么生成出来的
  - Database Connection
  - SQL Generation
  - Association Mapping
    <br>模型间的关联的实现机制
- ActionMailer
