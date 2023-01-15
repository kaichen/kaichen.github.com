--- 
layout: article
title: runtime error words file not found of DataMapper
date: 2009-01-30 11:11
---

最近运行测试时在跑到用dm-sweatshop创建fixtures时总是报RuntimeError words file not found，而出错的行包含/\w+/.gen，然后就开始折腾…

最初看到/\w+/.gen这种语法时觉得十分的新奇，还以为是dm-sweatshop的创意，原来是dm-sweatshop依赖的randexp库的魔法，而这背后原来是从系统的words文件中随机挑选出一个单词来实现的。<a href="http://en.wikipedia.org/wiki/Words_(Unix)" target="_blank">words file in Wikipedia</a>

如果系统中没有words文件那在使用刀sweatshop的/\w+/.gen时就一直会报RuntimeError words file not found。而就是这个没有明确说明的依赖，让我折腾了好多天，因为系统中不一定一开始就有这个words文件，像在我用的ArchLinux上是由 words包提供的（貌似Ubuntu中是wbritish包）。

一开始我以为是DM又抽风了，就删了dm，然后又把整个rubygems删了。然后开始用grep和find搜索各种源码，先是在dm-more中找不到，接着去找ParseTree（sweatshop依赖它来完成unique {/\w+/.gen}）语法。最后读了一下sweatshop依赖中看到randexp，接着在randexp中搜索到了”words file not found”这个RuntimeError。

以上的做法比较S13，如果在使用sweatshop之前<a href="http://en.wikipedia.org/wiki/RTFM" target="_blank">RTFM</a>，就能看到它依赖于Randexp，然后如果再去看看源码，就不用折腾那么久XD

不过仔细读了一下sweatshop的源码，知道其中的猫腻，sweatshop为DataMapper::Model模块加入了几个方法：

fixtures：定义fixtures，和FactoryGirl的define差不多，可以用个Symbol指定名字，否则就为:defualt。方法缩写fix。
generate：使用之前fixtures方法中定义的属性值创建模型实例，调用的是模型的create方法。缩写gen。
generate!：同上，不过故名思义创建实例调用的方法是create!。缩写gen!。
generate_attributes：返回在fixtures方法中定义的属性Hash。类似FactoryGirl的attribute_for。
make：调用new创建实例，即不保存。
pick：返回一个由上述创建实例的方法创建的实例。一般用于关联，要将已创建的模型实例作为关联对象时使用。
sweatshop中维护了两个Hash，维护模型定义的model_map和维护实例（包括保存与未保存）的record_map。上述方法中 fixtures将模型定义加入model_map，gen/gen!/make方法则在创建实例后将其加入record_map中，pick方法就在 record_map中找出现存实例。

如果想要在FactoryGirl中使用/\w+/.gen就require ‘rendexp’这句就行了。

最后有个疑问，Rendexp这个包在win平台能用吗？
