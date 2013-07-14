---
layout: post
title: "Code loading of Rails"
date: 2013-07-04 23:03
comments: true
categories: ["Ruby on Rails", "Ruby"]
---

> 本文是[Inspect Rails](/inspect-rails)的一部分，[Inspect Rails](/inspect-rails)是由我正在编写的讲解Rails内部的实现与设计的一本书，欢迎阅读

Ruby on Rails中实现了一套复杂的代码加载机制，比如怎样自动加载对应的模型，在开发模式
如何重新加载整个项目的代码，以及开发模式下的代码预加载。

## ActiveSupport::Dependencies

本篇中讲到的Ruby on Rails的代码加载机制大部分实现代码都在[`ActiveSupport::Dependencies`][0]这个类中，这其中的实现逻辑算是比较复杂，我不想在这里贴满代码，在本篇中只是讲到实现机制以及对应的方法，请读者自行去看对应的代码。

`ActiveSupport::Dependencies`这个类所在的文件被require时，就会自动进行初始化，以下是这个文件的最后一行代码。

ActiveSupport::Dependencies.hook!

我们可以先看看这个对应的`hook!`方法

{% codeblock lang:ruby %}
# ActiveSupport::Dependencies
def hook!
  Object.class_eval { include Loadable }
  Module.class_eval { include ModuleConstMissing }
  Exception.class_eval { include Blamable }
end
{% endcodeblock %}

它就是将所需的各种Meta Programming挂到Object和Module下，以下就会一步步讲到对应的秘密。

## 自动加载

Ruby on Rails开发者一般不需关心这样一个问题，从来没有手动加载某个模型类或者控制器类，但为什么这个类可以直接使用呢？其中的秘密就是Rails使用了Ruby的其中一个Meta Programming功能，`const_missing`。所有的类和模组在Ruby里都是常量，当Ruby解析器在遇到没有见过的常量时，就会去调用对应上下文的`const_missing`方法。开启`const_missing`的地方就在前面看到加载到Module里的`ModuleConstMissing`模组中。

当Rails项目代码里遇到一个从来没有加载过的类或模组时，会调用
`Dependencies.load_missing_constant`方法去尝试利用之前章节提到的文件结构惯例加载对应代码。这个`load_missing_constant`的基本思路是，调用`Dependencies.search_for_file`方法去找到对应的文件，找到后通过`Dependencies.require_or_load`去加载。这过程其中需要将已经加载的所有内容都记录下来，以便对这个加载状态进行管理。

## 开发模式的代码重新加载

Rails的一个著名的功能就是在开发时，当你修改了某个文件后，Rails会帮你自动去重新加载对应的代码。

ActiveSupport里实现了一个名为FileUpdateChecker的类，可以监视文件变化，当文件被更
改的时候调用相应的逻辑。Rails通过这种方式去监视所有标记为`autoload`的目录下的文件，
当下一次请求过来时，在文件被修改的条件下会自动去进行重新加载。

而重新加载的机制，同样是利用Ruby语言的Meta Programming，通过[remove_const][3]去
把已经加载的类和模组都从内存中清空，这就让加载状态又回到了原点。虽然这个实现的思路很简单，但是由于Ruby里对于命名空间的处理是以嵌套的形式存在的，故需要循环遍历所有已加载的类和模组，并对其下的类和模组做深度遍历，最后将它们通通都清理。

这部分对应的代码入口如下

{% codeblock lang:ruby %}
# ActiveSupport::Dependencies
def clear
  log_call
  loaded.clear
  remove_unloadable_constants!
end
{% endcodeblock %}

另外，由于不是所有的代码都是通过这种自动加载的方法，那么利用`require`和`load`手动显式加载的。因此必须替换系统的`require`和`load`，以记录哪些代码已经被加载进来，实现之后的代码重载。这个就是最开始提到的`Dependenciese.hook!`里include到Object类中的`Loadable`模组做的事情。

## 生产模式的代码预加载

Rails在生产模式下，为了提高运行时的速度，去掉在处理请求时加载对应代码的延迟，所以会在
启动后把所有的业务代码都预先加载进来。它是通过如下的initializer来实现的，这个功能
通过`eager_load`的选项来控制。

{% codeblock lang:ruby %}
# Rails::Application::Finisher
initializer :eager_load! do
  if config.eager_load
    ActiveSupport.run_load_hooks(:before_eager_load, self)
    config.eager_load_namespaces.each(&:eager_load!)
  end
end
{% endcodeblock %}

如果需要某个环境启用预加载的话，可以对应环境将这个`eager_load`选项打开。

## 加载日志

ActiveSupport::Dependencies内部的所有操作都是可以输出到日志，但默认情况Rails关闭了这部分日志，希望读者在读完这部分内容后去打开日志选项，去实际看看在你的项目中代码是怎样被加载的。打开的方法也很简单，在你的`config/application.rb`的Application类定义里加上这几行代码:

{% codeblock lang:ruby %}
config.after_initialize do
  ActiveSupport::Dependencies.logger = Rails.logger
  ActiveSupport::Dependencies.log_activity = true
end
{% endcodeblock %}

如果你在项目里引用了一些Rails Engine，由于前面章节所提到的Rails Engine与Rails Application的关系，Engine的MVC组件的加载也是通过同种方式进行，因此也能看到相应的Rails Engine里的日志。

[0]: https://github.com/rails/rails/blob/4-0-stable/activesupport/lib/active_support/dependencies.rb
[1]: http://en.wikipedia.org/wiki/Convention_over_configuration
[2]: http://www.ruby-doc.org/core-2.0/Module.html#method-i-const_missing
[3]: http://www.ruby-doc.org/core-2.0/Module.html#method-i-remove_const
[4]: http://www.ruby-doc.org/core-2.0/Module.html#method-i-append_features
