---
layout: post
title: Instance Property of CoffeeScript
---

用Class语法定义的Instance Property是直接append到prototype上，当
你把一个property定义为某个对象(非立即值)时，那所有的
Instance都会指向同一个内存地址上。

{% highlight coffeescript %}
class Foo
  favSites: ["Google"]
{% endhighlight %}

会编译得到：

{% highlight javascript %}
var Foo;

Foo = (function() {
  function Foo() {}
  Foo.prototype.favSites = ["Google"];
  return Foo;
})();
{% endhighlight %}

这里容易犯错的地方就是当有实例去修改上面提到的共享
内存地址的内容，这样就会得到一个奇怪的结果。

{% highlight coffeescript %}
foo1 = new Foo
foo2 = new Foo

foo1.favSites.push "Github"
alert foo2.favSites # => ["Google", "Github"]
{% endhighlight %}

当不想出现这种情况时最好避免直接把Instance Property定义在
Class Contructor的prototype上。

{% highlight coffeescript %}
class Foo
  constructor: (@options = {}) ->
    @favSites = ["Google"]

foo1 = new Foo
foo2 = new Foo

foo1.favSites.push "Github"
alert foo2.favSites # => ["Google"]
{% endhighlight %}

在Backbonejs里也是这么处理的，比如在Model中，每个实例的所
有属性值(`attributes`)：

{% highlight javascript %}
var Model = Backbone.Model = function(attributes, options) {
    var defaults;
    attributes || (attributes = {});
    #...
    this.attributes = {};
    this._escapedAttributes = {};
    this.cid = _.uniqueId('c');
    this.changed = {};
    this._silent = {};
    this._pending = {};
    #...
}
{% endhighlight %}

