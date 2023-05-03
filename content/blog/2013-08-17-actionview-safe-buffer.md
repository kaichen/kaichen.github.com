---
title: "ActionView Safe Buffer"
date: 2013-08-17
category: "inspect-rails"
comments: true
tags: ["Ruby", "Ruby on Rails"]
---

为了提高安全性，ActionView的模版在Rails 3中实现了名为SafeBuffer用来减少被[XSS攻击][xssatt]的风险。


> 本文是[Inspect Rails](/inspect-rails)的一部分, [Inspect Rails](/inspect-rails)是由我正在编写的讲解Rails内部实现与设计的一本书, 欢迎阅读

## XSS攻击

XSS，全称为Cross-site Scripting，中文叫跨站脚本攻击。这是通过对目标网页注入脚本（最常见是JavaScript，也可以是VBScript等），然后通过这段脚本来盗取用户cookies或做跨站提交等。

要防止这种攻击，Rails开发者必须非常小心地处理用户输入的内容，本篇讲到SafeBuffer就是帮助开发者减小被攻击的风险。

## HTML Safe

在ActionView的Template中，默认的内容是HTML Unsafe的，HTML Unsafe的内容被拼接时会先用`ERB::Utils.html_escape`方法先处理一遍。只有两种才会被认为是HTML Safe的

- Numeric
- AS::SafeBuffer的实例对象

这里可能会让人出乎意料的是，SafeBuffer的实现放在ActiveSupport的String Extention里，具体定义文件在`active_support/core_ext/string/output_safety.rb
`。

SafeBuffer被定义为String的子类，与普通的String不同是SafeBuffer的`html_safe`属性为True。

```ruby
module ActiveSupport #:nodoc:
  class SafeBuffer < String
    def initialize(*)
      @html_safe = true
      super
    end
    # other methods
  end
end
```

另外，对于其他的对象，通过打开类的方式将Object的html_safe设置为False，而Numeric被设置为True。具体定义如下

```ruby
class Object
  def html_safe?
    false
  end
end

class Numeric
  def html_safe?
    true
  end
end
```

我们知道String的内容是可变的，同样SafeBuffer的内容也是可变的。出于安全性考虑SafeBuffer会将产生新对象或修改内容本身的方法，比如`capitalize`，`gsub`等等，都替换为结果是HTML Unsafe的字符串

```ruby
class_eval <<-EOT, __FILE__, __LINE__ + 1
  def #{unsafe_method}(*args, &block)
    to_str.#{unsafe_method}(*args, &block)
  end

  def #{unsafe_method}!(*args)
    @html_safe = false
    super
  end
EOT
```

比如替换后的capistalize方法是

```ruby
def capitalize(*args, &block)
  to_str.capitalize(*args, &block)
end

def capitalize!(*args)
  @html_safe = false
  super
end
```

稍微解释一下方法替换的意义，在非[bang方法][bangmethod]中，先调用`to_str`就将原字符串转化为普通的String，由于除了SafeBuffer外的对象都是unsafe的，通过这么转化本来HTML Safe的内容又变回了HTML Unsafe的状态。

当需要将内容标记为html safe状态的时候，可以调用`html_safe`方法，这个方法的原理就是构造一个新的SafeBuffer对象，代码如下

```ruby
class String
  def html_safe
    ActiveSupport::SafeBuffer.new(self)
  end
end
```

## 接口

基本上所有模版语言都放出了，一些回调接口让开发者可以替换掉原有的Buffer实现。ActionView里定义的Template Handler就完成了模版语言Buffer实现的替换，比如这里的[对Erb的替换](https://github.com/rails/rails/blob/4-0-stable/actionpack/lib/action_view/template/handlers/erb.rb)。

一些第三方的模板语言，比如[Haml][haml]直接集成了SafeBuffer，[Slim][slim]通过其依赖的[Temple][temple]也集成了SafeBuffer。

## 参考

- http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/
- http://www.railsdispatch.com/posts/security

[bangmethod]: http://dablog.rubypal.com/2007/8/15/bang-methods-or-danger-will-rubyist
[xssatt]: http://en.wikipedia.org/wiki/Cross-site_scripting
[erubis]: http://www.kuwata-lab.com/erubis/
[slim]: https://github.com/slim-template/slim
[temple]: https://github.com/judofyr/temple
[haml]: https://github.com/haml/haml
[builder]: https://github.com/jimweirich/builder

