---
title: "[译文] Rails 2.1 ActiveRecord的Create方法支持Block"
date: 2008-05-12
tags: ['Ruby', 'Ruby on Rails', 'ActiveRecord', 'posts']
---
ActiveRecord::Base.create 现在可以像 ActiveRecord::Base.new 一样带上一个代码块参数了。

```ruby
@person = Person.create(params[:person]) do |p|
  p.name = 'Konata Izumi'
  p.age = 17
end
```
