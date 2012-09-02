--- 
layout: post
title: Rails 2.1 ActiveRecord的Create方法支持Block
---
ActiveRecord::Base.create 现在可以像 ActiveRecord::Base.new 一样带上一个代码块参数了。

    @person = Person.create(params[:person]) do |p|
      p.name = 'Konata Izumi'
      p.age = 17
    end
