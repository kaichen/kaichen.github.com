--- 
tags: ['posts']
title: Ruby与Java对比
date: 2007-10-09
---
<a HREF="http://www.ruby-lang.org/en/documentation/ruby-from-other-languages/to-ruby-from-java/">原文地址</a>
下午无聊翻译一下，看看ruby官方怎么和java对比
<!--more-->
相同点：

类似于java，在ruby中：

内存管理都是由GC（garbage collector）负责。
都是强类型语言。
都有public，private，protected的方法可见性之分。
都有嵌入式文档工具（ruby的叫做RDoc）。rdoc生成的文档看起来非常像由javadoc生成的。

不同：

于java不同的是，在ruby中：

你不必编译代码，你只需要直接运行代码。
Gui开发包不同。比如，ruby的用户会尝试WxRuby，FXRuby，Ruby-GNOME2,或者基于Ruby Tk库。
你要在定义任何事物（像class）后面加上关键字end，而不是用花括号（{}）来包围代码块。
使用了require代替了import。
所有的成员变量（属性）都是private级的。在类外访问任何事物要通过方法调用。
什么都是对象，包括2和3.14159。
没有静态类型检查。
变量名都只是标签，它们没有与类型相关。
不用声明变量类型，你只需要赋值给新的变量名就可以了（例子，a = [1,2,3] 相当于 int[] a = {1,2,3};）。
没有类型强制转换这个概念，只管调用方法就好了。
用 foo = Foo.new( "hi") 取代这样新建对象的方法 Foo foo = new Foo( "hi" )。
构造方法一直都叫“initialize”，不是和class同名的方法。
使用“混入” 代替 “接口”。
YAML 比 XML 更受欢迎。
这里用nil代替null。
==和equals()方法处理方法不同。当你想要测试相等性时就使用 == 操作符（就像Java的equals()方法）。当要想要知道两个对象是否是同一个时就使用equal?()方法(就像Java中的==)。 [点击图片可在新窗口打开]
