--- 
layout: article
title: Skinny Spec的小技巧
date: 2008-06-26 11:11
---
使用Skinny Spec对Controller进行测试时需要定义shared_request来进行请求，
但是这个方法的命名非常的令我费解，一般都是使用do_get，
make_request，do_request等等，那要使用Skinny_Spec对原来的Spec进行测试时比较挺麻烦。

因为我是个懒人，简单Hack一下就不用定义多个shared_request方法。

{% highlight ruby %}
    #spec/spec_helper.rb
    module ControllerMacros
      
       module ExampleMethods
           def shared_request
               verb = [:get, :post, :put, :delete].find{|verb| respond_to? :"do_#{verb}"}
               raise "未定义do_get, do_post, do_put, 或do_delete方法 / No do_get, do_post_ do_put, or do_delete has been defined" unless verb
               send("do_#{verb}")
           end
       end
    end
    Spec::Runner.configure do |config|
       #...
       config.include(ControllerMacros, :type =&gt; :controllers)
    end
{% endhighlight %}
