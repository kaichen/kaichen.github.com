---
layout: post
title: "Rails Internal Hierarchy"
date: 2013-06-14 21:19
comments: true
categories: ["Ruby on Rails", "Ruby"]
---

> 本文是[Inspect Rails][/inspect-rails]的一部分，[Inspect Rails][/inspect-rails]是由我正在编写的讲解Rails内部的实现与设计的一本书，欢迎阅读

Rails 内部有清晰的层级结构，以实现Rails应用程序和Rails插件的配置以及初始化。

{% graphviz %}
digraph rails_hierarchy {
    label = "Rails Hierarchy";

    edge[dir=back, arrowtail=empty]

    node [
      style = box
      style = filled
      fontname = "Ubuntu Mono"
      fontcolor = "#F2F2F2"
      arrowhead = "empty"
    ];

    railtie [label = "Railtie", fillcolor = "#8FBCDB"];
    rengine [label = "Rails Engine", fillcolor = "#447294"];
    rapp    [label = "Rails Application", fillcolor = "#294052"];

    railtie -> rengine;
    rengine -> rapp;
}
{% endgraphviz %}

如上图所示，所有Rails Application继承自Rails Engine，而Rails Engine继承自Railtie，这套继承体系的实现全部都封装在railties这个Rubygem里。值得一提的是，Railtie和Rails Engine的子类都是[Singleton][4]，Rails Application本身就是[Singleton][4]，所以在一个程序里Rails Application只有一个实例。

## Railtie

我们先从Railtie说起，如果你翻查过一些Rails插件的源码，会发现它都继承了Railtie。Railtie位于层级里最低最底层的部分，它实现了配置和初始化这两大功能，其中的逻辑都组织在以下两个Modules中

- Initializable, 实现位于`rails/lib/rails/initializable`
- Configuration, 实现位于`rails/lib/rails/railtie/configuration`

Initializable 模块顾名思义就是负责初始化，常用的方法只有一个叫`initializer`的方法，它的方法签名如下，接受一个名字，一个可选的参数，一个代码块

{% codeblock lang:ruby %}
initializer(name, opts = {}, &blk)
{% endcodeblock %}

定义好的 Initializer 代码块会在Rails应用程序启动时执行，并且可以在参数里指定`before`或者`after`选项，
让其在某个已定义的Initializer执行之前或之后执行，这个功能是通过[Ruby内置的TSort][1]实现的。以下是ActiveRecord设置Logger的Initializer

{% codeblock lang:ruby %}
initializer "active_record.logger" do
  ActiveSupport.on_load(:active_record) { self.logger ||= ::Rails.logger }
end
{% endcodeblock %}

Configuration 是实现常见的`config.xxx = yyy`这一常见写法的源头，它使用了Ruby的method\_missing实现了配置参数的属性访问和设置，全部的配置都放在一个名为`@@options`的类变量里。

{% codeblock lang:ruby %}
def method_missing(name, *args, &blk)
  if name.to_s =~ /=$/
    @@options[$`.to_sym] = args.first
  elsif @@options.key?(name)
    @@options[name]
  else
    super
  end
end
{% endcodeblock %}

Action Mailer, Action Controller, Action View和Active Record 它们集成到Rails框架的都是通过Railtie实现。

如果你去看现实中的各种插件写的Railtie中，基本上就是调用initializer方法配置初始化逻辑和通过config变量在添加自身相关的各种配置选项。而且Rails也使用这两个模块去设置各种框架本身的初始化和参数配置。

Railtie除此之外，它还负责rake tasks和generator等部分与Rails应用程序的集成，暂不讲。

## Rails Engine

Rails Engine主要的设想就是把一些通用的Rails应用程序抽象出来并得到重用，也就是说每个Rails Engine几乎就是一个Rails应用程序，它拥有MVC结构，具有自己的路由，独立的Middleware Stack。社区里最广为人知的一个Rails Engine应该是[devise][3]。

Rails Engine中实现Rails广为人知的"[Convention over Configuration][5]"特性，整套目录结构的加载就是在这里定义的。

Rails Engine是一个Rack Middleware，它实现了`call`方法，所以能Mount到其他Rails Engine或者Rails Application的路由上。

关于Rails的代码加载方式会在后续的章节详细讲解。

## Rails Application

组织起Rails应用程序的启动流程，是Rails Application这个类最主要的事情。而Rails Application区别于Rails Engine在于需要管理很多外部的资源，比如以下的内容

- `Rails.logger`
- `Rails.cache`
- Session 的存储机制
- 维护完整Middleware Stack
- 代码重新加载
- 与Bundler的集成

关于Rails的启动流程和Middleware Stack等话题会在后续的章节中展开并详细讲解。

本节暂时到此。

[0]: /inspect-rails
[1]: http://www.ruby-doc.org/stdlib-2.0/libdoc/tsort/rdoc/TSort.html
[2]: /inspect-rails/comming-soon
[3]: https://github.com/plataformatec/devise
[4]: http://en.wikipedia.org/wiki/Singleton_pattern
[5]: http://en.wikipedia.org/wiki/Convention_over_configuration
