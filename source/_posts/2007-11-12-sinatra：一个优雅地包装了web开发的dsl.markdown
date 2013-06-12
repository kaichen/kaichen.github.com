--- 
layout: post
title: 简洁的Sinatra
---
你相信用100行代码可以实现一个博客吗？用Sinatra框架就可以做到。

下面就是这样子的一个Web应用：

<a href="http://journal.redflavor.com/reprise---a-minimalistic-blog">Reprise - A Minimalistic Blog</a>

这个应用的代码：http://redflavor.com/reprise.rb 一个简单的hello world的web应用要写多少代码？用Sinatra只需5行代码：
CODE:

    require 'rubygems'
    require 'sinatra'

    get '/' do
      'Hello World'
    end

Sinatra官方主页：http://sinatra.rubyforge.org/
