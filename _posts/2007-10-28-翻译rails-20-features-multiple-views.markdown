--- 
layout: post
title: Rails 2.0 Multiple View
---
作者： madpilot

原文链接：
http://www.sitepoint.com/blogs/2007/10/26/rails-20-features-multiple-views/

下一个主要版本的Ruby on Rails（指2.0）加入了复合视图这个新特性。大约上个月底，预览版发布了，我有幸试用了一下，我想及时地概述一下一些新特点。

复合视图

在rails 1.2中，支持多种数据类型的respond_to块被引入，它可以轻松地支持象XML或者JSON。你需要做就是像下面这样：
CODE:

{% highlight ruby %}
    def index
      @stories = Story.find :all
      respond to do |format|
        format.html { render }
        format.xml {
          render :xml => @stories.to_xml
        }
        format.json {
          render :json => @stories.to_json
        }
      end
    end
{% endhighlight %}

然后在浏览器上，如果你加上了扩展文件（比如/stories/index.xml）并得到包括请求格式的内容，那么你可以在environment.rb文件的最后添加MIME::Type.register，来创建自定义的类型。

这种做法的一个问题是，基于扩展文件这种方式没有办法支持不同的HTML页面。因为MIME::Type解析器工作方式是，添加其他MIME类型为 text/html的内容标识（handler）会扰乱默认的标识（handler），这意味着上面的代码会提供错误的视图。

输入Mime::Type.register_alias

现在你可以告诉Rails用HTML响应你希望使用的多种文件类型。就是说你想设计一个mobile版本和iPhone版本的站点，你能通过添加下面的代码到/config/initializers/mime_types.rb文件创建两个新的格式：

{% highlight ruby %}
    Mime::Type.register_alias "text/html", :iphone
    Mime::Type.register_alias "text/html", :mobile
{% endhighlight %}

这使下面代码可以运作:

{% highlight ruby %}
    def index
    @stories = Story.find :all
    respond to { |format|
    format.html {}
    format.xml {
    render :xml =&gt; @stories.to_xml
    }
    format.json {
    render :json =&gt; @stories.to_json
    }
    format.iphone {
    // Serve up the iPhone version
    }
    format.mobile {
    // Serve up the mobile version
    }
    }
    end
{% endhighlight %}

当然，必须在每个respond_to代码块用手工提交不同的版本的做法不太符合DRY原则，所以已经为所有的视图文件创建了一种新的命名惯例。相对于在上面的index.rhtml中调用视图文件，根据你要使用的方式建立三种不同的版本的视图文件更好，比如， index.html.erb, index.iphone.erb 和 index.mobile.erb。

当rails找到一个匹配的视图就使用它;当找不到时就使用默认的.html.erb或者.rhtml文件。这让你的站点方便地用不同的版本的视图提供服务。

PS： 这篇文章有drive2me大哥帮我校对，谢谢drive2me帮我耐心地讲解，和校对。
