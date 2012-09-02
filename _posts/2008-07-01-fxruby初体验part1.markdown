--- 
layout: post
title: FxRuby part1
---
FxRuby，一个更新较为频繁的Ruby GUI 开发库。今年还出了本书，今晚刚好有空，吃了饭后，6：30开始到现在9：30，看完了它的入门例子。其实是因为今晚不用开工，而想起了一个想做很久的事情，就是开发一个编辑器，一个能够用Ruby作为配置和开发语言的编辑器，就像Emacs能用Lisp在其上开发一样，而且能支持Rails，Rspec，Rake语法和开发辅助（如MVC跳转）等等，这是个妄想:-)

<a href="http://pragprog.com/titles/fxruby/fxruby"><img src="http://www.fxruby.org/images/fxruby-book.jpg" alt="FxRuby book" /></a>
<a href="http://pragprog.com/titles/fxruby/fxruby">http://pragprog.com/titles/fxruby/fxruby
</a>

先来看看它的HelloWorld的代码：
    require 'fox16'
    include Fox
    class HelloWindow &lt; FXMainWindow
      def initialize(app)
        super(app, "Hello, World!" , :width =&gt; 200, :height =&gt; 100)
      end
      def create
        super
        show(PLACEMENT_SCREEN)
      end
    end
    if __FILE__ == $0
      FXApp.new do |app|
        HelloWindow.new(app)
        app.create
        app.run
      end
    end

HW没什么太多好讲的，有些东西要提一提就Ok了。GUI应用，肯定有个明显的入口点，就是<a href="http://www.fxruby.org/doc/api/classes/Fox/FXApp.html">FxApp</a>的实例，因为是Desktop app，所以一般都有个主窗体，在FxRuby中是<a href="http://www.fxruby.org/doc/api/classes/Fox/FXMainWindow.html">FXMainWindow</a>的实例。FxRuby中，App实例创建之后还要调用create和run两个方法，主窗体的构造函数要做的事情是设置好主窗体的属性，App的create方法会调用会调用每个下级控件的create方法，在create中要加入的就是显示的方式(好像窗体才需要)等等。从上面的HW就可以看到这些。
<a href="http://www.fxruby.org/doc/ch03s05.html">
FxRuby官方手册</a>中还有另一个复杂一点点的HelloWorld。

入门例子是个相册管理的桌面应用，名曰Picture Book。这个例子书中用了5 Chapter（2－6）来讲，基本讲到了常用的Gui组件。

好像太长了，拆开放到另一个日志上吧。

参考Link：

FxRuby官站：<a href="http://www.fxruby.org/">http://www.fxruby.org/</a>

FxRuby的Rdoc：<a href="http://www.fxruby.org/doc/api/">http://www.fxruby.org/doc/api/</a>

FxRuby在线手册：<a href="http://www.fxruby.org/doc/book.html">http://www.fxruby.org/doc/book.html</a>
