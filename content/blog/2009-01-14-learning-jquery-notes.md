---
title: Learning jQuery Notes
date: 2009-01-14
tags: ["jQuery", "JavaScript"]
---

以下内容是Learning JQuery一书的前六章笔记摘要，基本的JQuery操作就在这里了。很多地方只是提一下，具体要用时还是去查[官方文档](http://docs.jquery.com)。

## Selecter ##

基本通过工厂方法`$()`进行选择，可以选择标签名（Tag），ID（id），类（Class）。

通过子元素组合符（&gt;）可以选择到后代元素

当需要通过属性进行选择时可以使用XPath语法：`tag[@attribute]`。更好的选择过滤符$=，^=，\*=。

JQuery特有的自定义选择符，以冒号开头（:）

* `:not` 反向选择
* `:eq(index)` 通过下标对数组进行选择
* `:odd` 索引为奇数的元素
* `:even` 索引为偶数的元素
* `:nth-child(index)` 通过索引访问子元素
* `:contains(string)` 包含指定字符串的元素

选择到元素后可通过JQuery的特有遍历方式进行遍历

`filter()` 可以调用自定义选择符进行过滤
`parent()` 取得父元素
`next()` 取得下一个同辈元素
`siblings()` 取得所有同辈元素
`find()` 通过标签加选择符进行过滤

通过`get(0)`或者`$(el)[0]`可以直接返回DOM元素

## Event ##

`$(document).ready()`是注册事件处理器的入口，它会在HTML下载完毕并解析为DOM树时自动执行，并且是按顺序执行注册的处理器。

一般的形式：

    $(document).ready(function(){
        # codes....
    });

事件绑定是使用bind()函数进行的，常见形式：

``$(el).bind(event, function-define);``

bind到元素上的事件不会覆盖，即可为元素同个事件定义多个事件处理器并让其按顺序执行。

`bind()`的简写形式是直接调用与事件同名函数，如`click(functions-define)`。

`toggle()`方法接受两个函数参数，在第一次单击时会调用第一个函数，第二次则调用第二个函数并循环这个过程。

`toggleClass(classname)`方法会为元素切换指定的类。

`hover()`方法与`toggle()`方法类似，接受两个函数的参数，分别在鼠标指针进入和离开该元素范围时执行。

`unbind()`方法可以解除元素的事件处理器绑定，提供两个参数，一个事件名，和函数名。

`one()`方法可以绑定一次性事件，即绑定完成后解除。

`trigger()`方法可以模拟事件的发生。参数为事件名。其简写形式为不带任何参数的事件名同名函数。

## Effect ##

`css()`方法可以接受属性名和值来对元素的style进行设置。两种调用形式`css(property, value)`，`css(property1 : value1, property2 : value2...)`。

`css()`方法也可以取得对应属性名的值。

BTW，`css()`方法类似reader和writer。

`hide()`和`show()`方法可以对元素进行隐藏和显示。

所有的效果都可以加上速度参数：slow normal fast。

`fadeIn()`，`fadeOut()`和`fadeTo()`修改元素的不透明度。

`slideDown()`和`slideUp()`修改元素的高度。

`animate()`方法可以同时修改元素的多个属性。

效果函数可以带上第二个参数作为回调函数，在效果完成后调用。

效果的顺序原则：

1. 一组元素上的效果
  * 当在一个.antimate()方法中以多个属性的方式应用时，是同时发生的。
  * 当以方法连缀的形式应用时，是按顺序发生的（排队效果）。
2. 多组元素上的效果
  * 默认情况下是同时发生的。
  * 当在事件处理程序的回调函数中应用时，是按顺序发生的（排队效果）。

## DOM ##

`addClass()`和`removeClass()`，`togleClass()`可以对元素的类进行增删。

`attr()`和`removeAttr()`可以对元素属性进行操作。

`each(function(index){})`可以对元素组进行迭代。

`clone()`方法可以进行深度复制

`insertBefore()`，`before()`，`insertAfter()`，`after()`方法用于在相邻位置插入新元素。insertXxx和Xxx存在着被动与主动的关系。

`append()`，`appendTo()`，`prepend()`，`prependTo()`用于元素中插入新元素。

`wrap()`用于在元素外插入新元素，即用新元素包裹自身。

`html()`，`text()`使用新元素或文本进行替换

`empty()`移除元素

`remove()`移除元素及其后代元素

## Ajax ##

``load()``方法可以直接请求html片段并直接插入元素中。

``$.getJSON()``方法可以请求json文档，第二个参数可以带上回调函数。

``$.get()``和``$.post()``两个方法可以模拟GET和POST请求，并支持回调函数。第二个参数可以加上一个参数map。

``$('#form').find('input').serialize()``可以序列化表单数据。

``ajaxStart()``和``ajaxStop()``是两个Ajax请求的监听器，在请求开始时会调用注册在前一个函数的回调处理器，在请求结束时会调用后一个函数的回调处理器。
