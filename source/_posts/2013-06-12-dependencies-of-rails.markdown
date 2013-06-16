---
layout: post
title: "Dependencies of Rails"
date: 2013-06-12 21:43
comments: true
categories: ["Ruby on Rails", "Inspect Rails", "Ruby"]
---

> 本文是[Inspect Rails][0]的一部分，[Inspect Rails][0]是由我写的讲解Rails内部的实现与设计的一本书，欢迎阅读

我们平时安装Rails时，执行的是`gem install rails`，安装的Rubygem名称就叫rails，而
这个Rubygem其实只是个没有代码的Meta Gem，它的作用就是定义rails依赖的组件，从
rails的gemspec看到

{% codeblock lang:ruby %}
# rails.gemspec
s.add_dependency 'activesupport', version
s.add_dependency 'actionpack',    version
s.add_dependency 'activerecord',  version
s.add_dependency 'actionmailer',  version
s.add_dependency 'railties',      version

s.add_dependency 'bundler',         '>= 1.3.0', '< 2.0'
s.add_dependency 'sprockets-rails', '~> 2.0.0.rc4'
{% endcodeblock %}

以上的依赖声明说明了Rails依赖于哪些组件，首先有几个active或action打头的Rubygem

- activesupport, 对Ruby语言的一些扩展，Rails的所有核心组件都是依赖于它
- actionpack, 包含了处理Web请求逻辑，包含了MVC中的Controller和View
- activerecord, 以Active Record模式为基础的ORM
- actionmailer, 包含邮件发送和接收逻辑
- railties, 把以上的组件组合起来
- [sprockets-rails](https://github.com/rails/sprockets-rails), [Sprockets](https://github.com/sstephenson/sprockets)的Rails
  集成代码，Sprockets为Rails带来了著名的Assets Pipeline，Rails 3.1引入
- [bundler](https://github.com/carlhuda/bundler), 管理依赖Rubygem的版本

除了Bundler和sprockets-rails外的几个Act\*\*\*框架都是放在
[Rails的Repo](https://github.com/rails/rails)里，还有以下介绍的大部分***-rails
的Rails与其它库的集成都是放在[Rails的Github账号](https://github.com/rails)下的，
如sprockets-rails。

当然，各个组件还引用了其它的依赖

- [builder](https://github.com/jimweirich/builder), 创建XML数据的DSL
- [rack](https://github.com/rack/rack), Ruby的Web Server接口，我们知道Rails是
  一个基于Rack的Web框架
- [rack-test](https://github.com/brynary/rack-test), rack的测试框架
- [erubis](https://github.com/kwatch/erubis), 最快的ERB渲染引擎
- [arel](https://github.com/rails/arel), 基于关系代数的SQL生成框架
- [rake](https://github.com/jimweirich/rake), 不解释
- [thor](https://github.com/wycats/thor), rake的替代品，在Rails中只用到了Thor的
  文件操作功能去构建Generator

<a name='req-deps' href='#req-deps'></a>
## 必要组件

Rails在gemspec里声明是核心组件，但并非是必要的组件，比如Assets Pipeline，
ActiveRecord和AtionMailer不是一定需要包含在你的Rails Application里。

Rails 应用程序首先必须是个Rails Application，所以需要railites去维护整个程序的
加载和目录结构等。除此以外，Rails是个Web Framework，所以actionpack也是其必要的
组件之一。剩下的一个必要组件是，ActiveSupport，所有组件的必要依赖。

<a name='opt-deps' href='#opt-deps'></a>
## 可选组件

AcitveRecord，在Rails 3之后属于可替换的组件。由于在Actionpack里如Routing和Form
Helper严重依赖于ActiveRecord，所以Rails Core Team就抽象出了ActiveModel去解开
这个依赖，将Routing和Form Helper等需要调用到的部分，以Module的形式定义好接口，
只要包含或者实现了ActiveModel接口就能完美地与ActionPack协作。

ActionMailer，不是所有的Rails应用都有发邮件的需求，显然这不是必要的组件。

Sprockets，为Rails提供Assets Pipeline功能，但并不是所有人都喜欢它。在Rails应用
生成器里也提供了这个选项，去掉Assets Pipeline功能。

Test::Unit，Rails默认的测试框架，但由于Test::Unit是Ruby语言自带的，当开发者不想
直接使用它的时候，Rails只是关闭相关的代码生成器。另外，其他任何的测试框架都只是
Test::Unit的包装，添加了Syntax Sugar而已。
