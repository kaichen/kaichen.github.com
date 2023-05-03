---
title: "ActionView基本架构"
date: 2013-08-10
comments: true
tags: ["Ruby on Rails", "Ruby"]
category: "inspect-rails"
---

`ActionView`是MVC中最后一公里, 将内容拼装完成, 等待服务器将其最终结果传输到用户端。


> 本文是[Inspect Rails](/inspect-rails)的一部分, [Inspect Rails](/inspect-rails)是由我正在编写的讲解Rails内部实现与设计的一本书, 欢迎阅读

**注** 下文中`ActionView`在作为命名空间时全部简写为`AV`。

在开发者的角度看来, `ActionView`的处理过程似乎没有太多值得一提的事情, 大部分情况下需要关心的只是某个Helper要传哪些参数进去。但实际其中ActionView完成的事情并不简单, 这里主要有4个步骤

1. 需要将路由生成方法和各种Helper方法绑定到渲染的上下文中, 并绑定在当前Controller中的实例变量
2. 需要有对象负责知道怎么去找到对应的模版。Rails能做到的查找规则极为灵活, 可以查找某个对应Format（如json）, 对应Locale（如zh-CN）, 从文件系统或数据库里找到这个对应的模版。
3. 找到了这个模版后, 需要知道怎样去编译这个模版。Ruby世界有很多的模板语言, 比如Erb, Builder, Haml和Slim等等, Rails需要找到对应的编译方式去编译它们。
4. 将编译好的模版, 加上之前的渲染上下文, 拼装得到最后的结果。

在Controller里调用到ActionView接口只有以下三个

- AV::Base 维护整个渲染过程的上下文(View Context)
- AV::LookupContext 维护模版查找的上下文
- AV::Renderer 渲染接口

渲染的调用逻辑基本集中在`AbstractController::Rendering`这个模组, 下图为其中大概的逻辑关系

![av](/images/action_view_arch.png)

图中的View Context就是上文提到的`AV::Base`, View Assigns指的是在Controller中设置的各种实例变量。最后Controller通过调用`AV::Renderer#render`去渲染出最终的结果。

关于ActionView内部具体的各个机制会在后续章节中一一讲解。

## 参考

Rails Core Team里的[José Valim](https://twitter.com/josevalim)可能是对ActionPack中大部分实现最为熟悉的人之一, 以下列出的书以及Presentation就讲到了这部分内容。

- [Crafting Rails 4 Applications](http://pragprog.com/book/jvrails2/crafting-rails-4-applications)
- [Rails Conf 2013 You've got a Sinatra on your Rails by José Valim](http://www.youtube.com/watch?v=TslkdT3PfKc)

