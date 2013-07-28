---
layout: post
title: "Sass入门"
date: 2013-07-23 19:01
comments: true
categories: ["CSS", "Web Development"]
---
Sass是一个CSS方言, 通过编译器实现将Sass/Scss编译为CSS。

http://sass-lang.com/

Sass具有两种语法, 一种是靠缩进去实现层级关系的Sass, 和另一种和CSS一样通过大括号实现层级的Scss。

## 特性

### 嵌套式语法

啥也不说了, 看代码

{% codeblock lang:scss %}
header {
  line-height: 3em;
  h1 {
    font-weight: bold;
  }
}
{% endcodeblock %}

这种形式的代码，大大减少了CSS编写层级定义时重复性。

### 变量

Sass可以通过变量去提高样式的可维护性。比如我们一套样式里, 我们常常会使用同样的间距, 但这往往要写到每个具体的元素上, 而当需要做出修改的时候就特别痛苦, 需要在每个用到的地方都去修改, 还不能简单粗暴地使用文本替换, 因为你不知道哪些是我们需要修改的。这种情况使用变量就特别适合, 示例如下

{% codeblock lang:scss %}
$margin: 16px;

.main-content {
  padding: $margin;
  margin: $margin;
}

.sidebar {
  padding: $margin;
  margin: $margin;
}
{% endcodeblock %}

### 函数

Sass内置了一些很实用的[函数](http://sass-lang.com/docs/yardoc/Sass/Script/Functions.html), 它们为样式编写提供了计算能力, 比如我最喜欢的[lighten](http://sass-lang.com/docs/yardoc/Sass/Script/Functions.html#lighten-instance_method), 它能把给出的颜色转换为更亮的颜色。

函数的编写, 不仅可以使用Ruby, 也可以使用Sass本身, 比如下面是我最近写的一个函数

{% codeblock lang:scss %}
@function opposite-position($direction) {
  @if $direction == "left" {
    @return "right"
  } @else if $direction == "right" {
    @return "left"
  } @else if $direction == "bottom" {
    @return "top"
  } @else {
    @return "bottom"
  }
}
{% endcodeblock %}

### Mixins

Mixins的思路就是通过把一组样式绑定到一个名字上，然后某个层级样式可以复用这组样式。

这个功能是Sass最强大的功能, 这提供及其强大的代码抽象能力, 让我们可以更好地组织起庞大的样式代码。各种Sass框架就通过Mixins来开放出它们的功能。

### Import

Sass通过Import的形式来管理样式间的依赖, 这就像是Node.js的require。通过这个我们就能把样式打包为一个文件, 并且清晰地定义好加载顺序。

## 教程

官方Reference

http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html

Sass缩进语法

http://sass-lang.com/docs/yardoc/file.INDENTED_SYNTAX.html

The Sass Way, 有分为不同阶段的文章

http://thesassway.com/

组织Sass代码的方式

http://thesassway.com/beginner/how-to-structure-a-sass-project

应用

得益于Sass强大的抽象能力和扩展力, 许多的框架基于它开发出来

Compass是一个基于Sass开发的CSS Framework, 集成了许多实用的Mixins

http://compass-style.org/

Twitter Bootstrap Sass, 使用Sass重写Bootstarp的项目

https://github.com/thomas-mcdonald/bootstrap-sass

方便处理Media Query的项目

https://github.com/paranoida/sass-mediaqueries

几个专门处理按钮样式的项目

- https://github.com/ubuwaits/css3-buttons
- https://github.com/alexwolfe/Buttons

还有许多Sass的项目, 这里再列出几个, 更多请自行上Github搜索

- https://github.com/csswizardry/inuit.css
- https://github.com/GumbyFramework/Gumby

竞争对手有Less.js和Stylus, 对比介绍

- https://gist.github.com/chriseppstein/674726
- http://net.tutsplus.com/tutorials/html-css-techniques/sass-vs-less-vs-stylus-a-preprocessor-shootout/
- http://coding.smashingmagazine.com/2011/09/09/an-introduction-to-less-and-comparison-to-sass/
