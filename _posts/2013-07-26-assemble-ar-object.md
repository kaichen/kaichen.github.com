---
layout: article
title: "ActiveRecord 对象的拼装"
date: 2013-07-26 20:12
comments: true
tags: ["Ruby on Rails", "Ruby"]
category: "inspect-rails"
---

Rails开发者们写得最多的逻辑，一般在Model这一级, 很多时候就是在操作ActiveRecord对象。这些对象是怎样构造拼装出来的,  它们持有哪些状态，并且怎样持有状态的呢？这就是本文要讨论的内容。


> 本文是[Inspect Rails](/inspect-rails)的一部分，[Inspect Rails](/inspect-rails)是由我正在编写的讲解Rails内部实现与设计的一本书，欢迎阅读


**注意** ActiveRecord对象, 在下文都简称为AR对象。

AR对象有两种状态, 要么是已经持久化, 要么还未持久化。它们只通过以下两个入口构造出来

- initialize
- init\_with

查询的方式得到的结果AR对象, 都是已持久化状态的, 都通过`init_with`方法构造出来。它的入口基本来自于数据查询的源头`find_by_sql`方法

```ruby
def find_by_sql(sql, binds = [])
  # 发送查询到数据库 bla bla bla
  result_set.map { |record| instantiate(record, column_types) }
end
```

这里的`instantiate`的实现是这么调用的, `class.allocate.init_with`, 即分配好内存后调用`init_with`方法构造出对象。

通过`new`或者是关联对象上的`build`方法构造出来AR对象, 即未持久化的, 都通过`initialize`方法构造出来。

这两个不同途径的最大不同就是得到的持久化状态不同。判断是否持久化通过`persisted?`方法来得到

```ruby
def persisted?
  !(new_record? || destroyed?)
end
```

在AR对象里持久化状态, 由一个名为`new_record`和一个名为`destroyed`的布尔型实例变量标记决定。在构造未持久化状态的对象时就是将`new_record`设置为true, 反之则是false。而无论哪种方式构造出来的对象, 它的`destroyed`标记都为false, 因为你不可能查询出一个不存在的AR对象, 也不可能创建还未持久化就被删除的AR对象。这个事实反映了[ActiveRecord](http://www.martinfowler.com/eaaCatalog/activeRecord.html)这个模式的本质，即对象与数据库记录一一对应。

关于持久化状态的变更, 我们先来说说`destroyed`。`destroyed`这个标记, 它的状态变化只通过两个API能改变, `delete`和`destroy`（这里省略了`destory!`, 因为`destory!`也是调用的`destroy`的)。在AR对象里, 被标记为`destroyed`的对象不会马上消失, 只有离开了作用域后才会被回收。

接下来是`new_record`标记, 它的变更只通过`create_record`这个API。道理也很浅显, 只有这个对象被写入到数据库后才真正地摆脱new这种状态。而所有的比如`save`/`create`这些最外层的API调用的都是`create_record`。

当然除了持久化之外, AR对象还带上了许多其他的状态, 比如监控属性改变内容的状态, 上下文的事务状态, 是否只读状态等。AR对象出于效率考虑加上缓存, 比如关联对象的缓存, 属性的缓存等。这些状态, 无论怎么途径构建出来, 都会统一通过`init_internals`去做初始化。

AR对象, 为了实现两次查询出同一条数据库记录可以判等, 它还覆写了`==`以及`<=>`等方法, 全部将其改为对比模型类和数据的主键。也就是只要是同一个模型, 且数据库记录的主键是一致的, 则认为它们是等同的。

最后列出文中提到的几个API的所在模块

- ActiveRecord::Querying
  - `initialize`
  - `init_with`
  - `init_internals`
  - `==` 和 `eql?`
  - `<=>`
- ActiveRecord::Persistence
  - `persisted?`
  - `instantiate`
  - `delete`
  - `destroy`
  - `create_record`
- ActiveRecord::Querying
  - `find_by_sql`
