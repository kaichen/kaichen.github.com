---
layout: post
title: "[译文] Rails 2.1 ActiveRecord的Create方法支持Block"
categories: [Ruby, ActiveRecord, Ruby on Rails]
---
ActiveRecord::Base.create 现在可以像 ActiveRecord::Base.new 一样带上一个代码块参数了。

{% codeblock lang:ruby %}
@person = Person.create(params[:person]) do |p|
  p.name = 'Konata Izumi'
  p.age = 17
end
{% endcodeblock %}
