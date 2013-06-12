--- 
layout: post
title: 译文 Rails Cache教程2
---
原文地址：<http://railsenvy.com/2007/3/20/ruby-on-rails-caching-tutorial-part-2>

本教程的编写顺序是按照各个缓存的效率来排序的，Page缓存最快，所以在第一篇教程就介绍了，这篇教程就介绍其它的几种缓存。
<!--more-->
Action 缓存

Action缓存和Page缓存十分相似，唯一的区别就是对页面的请求会触及Rails服务器并且filter还是会运行。类似下面代码这样设置Action缓存：

    class BlogController &lt; ApplicationController
      layout 'base'
      before_filter :authenticate  # &lt;--- Check out my authentication
      caches_action :list, :show
    end

可以从代码中看到，用户必须通过认证才能访问list action，当对list进行请求时可以从 <strong>/log/development.log</strong>看到如下日志

    Processing BlogController#list (for 127.0.0.1 at 2007-03-04 12:51:24) [GET]
    Parameters: {"action"=&gt;"list", "controller"=&gt;"blog"}
    Checking Authentication
    Post Load (0.000000) SELECT * FROM posts ORDER BY created_on LIMIT 10
    Rendering blog/list
    Cached fragment: localhost:3000/blog/list (0.00000)
    Completed in 0.07800 (12 reqs/sec) | Rendering: 0.01600 (20%) | DB: 0.00000 (0%) | 200 OK [http://localhost/blog/list]

看到“Cached fragment: localhost:3000/blog/list”这行了吗？这表示有缓存文件生成，并且可以找到如下这个文件：

/tmp/cache/localhost:3000/blog/list.cache

默认的情况是， Action缓存会在/tmp/cache/目录下缓存文件，而不是像Page缓存那样直接输出.html文件，是输出.cache文件。如果你在单个应用中包含了一个以上的自域名，缓存文件的路径会包含主机和端口（localhost:3000）。这种情况下每个自域名会缓存在各自的目录下。

如果打开“list.cache”文件，就会看到其中的内容是完整的静态html页面，就像Page缓存的一样。那它们之间有什么区别呢？如果我们再次对页面做出请求（经过上面的请求之后），来看看<strong>/log/development.log</strong>：

    Processing BlogController#list (for 127.0.0.1 at 2007-03-04 13:01:31) [GET]
    Parameters: {"action"=&gt;"list", "controller"=&gt;"blog"}
    Checking Authentication
    Fragment read: localhost:3000/blog/list (0.00000)
    Completed in 0.00010 (10000 reqs/sec) | DB: 0.00000 (0%) | 200 OK [http://localhost/blog/list]

如你所见， 前置过滤器Authentication执行了，接着读取了缓存文件，然后输出。所以在这个情况下，依然是输出那个完整的缓存文件，并且还做了用户认证的检查。

这里值得注意的是，action执行前前置过滤器必须被执行。另一方面，你也可能会缓存到一个错误的html文件。

怎样清理Action缓存

如教程Part1中，缓存必须在数据发生变化后被清除掉。这里也是用sweepers，只不过在<strong>/app/sweepers/blog_sweeper.rb</strong>中"expire_page" 要改为 "expire_action"：

    # Expire the list page now that we posted a new blog entry
    expire_action(:controller =&gt; 'blog', :action =&gt; 'list')
    # Also expire the show page, incase we just edited a blog entry
    expire_action(:controller =&gt; 'blog', :action =&gt; 'show', :id =&gt; record.id)

也可以用以下的rake任务来清除 Action 缓存和 Fragment 缓存：

    rake tmp:cache:clear

这个rake任务会删除所有的\.cache文件。

Fragment Caching

使用了缓存之后会让应用变得飞快，但是由于这是动态的web应用，缓存整个页面并且总能命中这是不实际的，所以有了Fragment缓存。Fragment缓存能缓存页面中的一部分。

要对Blog应用中Post列表进行Fragment进行缓存就要编辑 <strong>/app/views/blog/list.rhtml</strong>：

    &lt;strong&gt;My Blog Posts&lt;/strong&gt;
    &lt;% cache do %&gt;
    &lt;ul&gt;
    &lt;% for post in @posts %&gt;
    &lt;li&gt;&lt;%= link_to post.title, :controller =&gt; 'blog', :action =&gt; 'show', :id =&gt; post %&gt;&lt;/li&gt;
    &lt;% end %&gt;
    &lt;/ul&gt;
    &lt;% end %&gt;

这段cache do的代码会创建文件/tmp/cache/localhost:3000/blog/list.cache，即使用当前的controller和action来进行命名。当下次请求来到并命中cache do部分的代码时就会读取刚刚说到那个缓存文件。让我们查看<strong>/log/development.log</strong>，来看看第一次和第二次请求中发生了什么：

    Processing BlogController#list (for 127.0.0.1 at 2007-03-17 22:02:16) [GET]
    Authenticating User
    Post Load (0.000230)   SELECT * FROM posts
    Rendering blog/list
    Cached fragment: localhost:3000/blog/list (0.00267)
    Completed in 0.02353 (42 reqs/sec) | Rendering: 0.01286 (54%) | DB: 0.00248 (10%) | 200 OK [http://localhost/blog/list]
    Processing BlogController#list (for 127.0.0.1 at 2007-03-17 22:02:17) [GET]
    Authenticating User
    Post Load (0.000219)   SELECT * FROM posts
    Rendering blog/list
    Fragment read: localhost:3000/blog/list (0.00024)
    Completed in 0.01530 (65 reqs/sec) | Rendering: 0.00545 (35%) | DB: 0.00360 (23%) | 200 OK [http://localhost/blog/list]

有没有感觉到一些冗余？
在第一次请求时生成了缓存，第二次时读取缓存，但是对Posts的SQL查询进行了两次。我们已经对SQL查询的结果缓存到页面中了，我们在缓存之后不用再进行SQL查询了，是吗？

解决这个问题的其中的一个方法就是编辑<strong>/controllers/blog_controller.rb</strong>，在查询前加上一个条件检查：

    def list
      unless read_fragment({})
        @post = Post.find(:all, :order =&gt; 'created_on desc', :limit =&gt; 10) %&gt;
      end
    end

现在只会在没有缓存的时候才有查询出现。或者有人会想，把这个请求放到view中的cache do代码块中不就好了吗？但是这个是MVC架构啊。

猜猜怎样清除Fragment缓存

    # Expire the blog list fragment
    expire_fragment(:controller =&gt; 'blog', :action =&gt; 'list')

没错吧？

在分页中使用Fragment缓存

默认情况下，缓存的命名是通过直接查找当前的controller和action名字来决定的。也就是说controller 为 "blog"并且 action 为 "list"就会缓存到 "/localhost:3000/blog/list.cache"。

在分页的情况下，就要把分页的页码加到缓存文件中。<strong>blog_controller.rb</strong>应该类似下面那样处理：

    def list
      unless read_fragment({:page =&gt; params[:page] || 1})  # Add the page param to the cache naming
        @post_pages, @posts = paginate :posts, :per_page =&gt; 10
      end
    end

在这里代码也可以为：read_fragment({:controller =&gt; 'blog', :action =&gt; 'list', :page =&gt; params[:page] || 1})，但Rails决定了前两个参数，这个无法改变，所以可以省略。

/views/blog/list.rhtml如下：

    &lt;% cache ({:page =&gt; params[:page] || 1}) do %&gt;
    ...  All of the html to display the posts ...
    &lt;% end %&gt;

这段代码会在第一次访问 /blog/list时，会创建 /localhost:3000/blog/list.page=1.cache 的缓存文件，按理可知访问分页2时会创建缓存文件/localhost:3000/blog/list.page=2.cache。 Pretty cool!

对Fragment缓存高级命名机制

大多数时候要对cache进行命名，这里有个示例：

话说现代的Web设计中每个页面都有一个用户自定义的导航目录（nav menu）。这里是一个列出用户要完成的项目任务（task）的导航目录：

    &lt;div id="nav-bar"&gt;
    &lt;strong&gt;Your Tasks&lt;/strong&gt;
    &lt;ul&gt;
    &lt;% for task in Task.find_by_member_id(session[:user_id]) %&gt;
    &lt;li&gt;&lt;%= task.name %&gt;&lt;/li&gt;
    &lt;% end %&gt;
    &lt;/ul&gt;
    &lt;/div&gt;

这个会在站点的每个页面中显示，如果能在用户第一次访问页面时缓存起来，在之后的访问就不用总是打扰数据库了。那就要对代码进行一点点改动：

    &lt;div id="nav-bar"&gt;
    &lt;strong&gt;Your Tasks&lt;/strong&gt;
    &lt;% cache (:controller =&gt; "base", :action =&gt; "user_tasks", :user_id =&gt; session[:user_id]) do %&gt;
    &lt;ul&gt;
    &lt;% for task in Task.find_by_member_id(session[:user_id]) %&gt;
    &lt;li&gt;&lt;%= task.name %&gt;&lt;/li&gt;
    &lt;% end %&gt;
    &lt;/ul&gt;
    &lt;% end %&gt;
    &lt;/div&gt;

当user_id为1时会创建缓存文件/localhost:3000/base/user_tasks.user_id=1.cache。

Fragment缓存命名示例
这里有些用户命名缓存的例子：

    cache ("turkey") =&gt; "/tmp/cache/turkey.cache"
    cache (:controller =&gt; 'blog', :action =&gt; 'show', :id =&gt; 1) =&gt; "/tmp/cache/localhost:3000/blog/show/1.cache"
    cache ("blog/recent_posts") =&gt; "/tmp/cache/blog/recent_posts.cache"
    cache ("#{request.host_with_port}/blog/recent_posts") =&gt; "/tmp/cache/localhost:3000/blog/recent_posts.cache"

怎样一次sweep多个缓存

上面的分页的Fragment缓存最后生成了很多缓存文件，已知的清除方法只是：

    expire_fragment(:controller =&gt; 'blog', :action =&gt; 'list', :page =&gt; 1)
    expire_fragment(:controller =&gt; 'blog', :action =&gt; 'list', :page =&gt; 2)
    expire_fragment(:controller =&gt; 'blog', :action =&gt; 'list', :page =&gt; 3)
    .....

但是这里还有一个方法来做这些事情：
``expire_fragment(%r{blog/list.*})``
这样会查找blog/list下的所有cache文件。使用这个方法要明白下面几点：
1. 不能在Memcached（下面会提到）下运行。
2. 这种方法会对所有的cache文件进行正则匹配，如果你的系统中有4,000+个cache文件，这会让你的系统处理很久。
3. 如果你不慎写错了正则表达式，那可能会出大问题。

Action/Fragment缓存的几种缓存机制

Page 缓存只能使用文件系统。Action 和 Fragment缓存就有几种选择：

1. File Store - (默认) - 把缓存放在磁盘中 (默认在 /tmp/cache/ 目录)。
2. Memory Store - Rails服务器的处理方法，放在内存。
3. DRb Store - 使用DRb服务器。
4. MemCache Store - MemCache是一个高性能的缓存处理程序。注意它不是用Ruby实现的。

作者认为FileStore是一开始最好的选择，在以后升级为其它的方式（如MemCache）也不难，要改变缓存文件存储的位置可以编辑config/environment.rb：
<code>ActionController::Base.fragment_cache_store = :file_store, "/path/to/cache/directory"</code>
ActiveRecord查询缓存

这是第四种缓存机制，对这种机制并没有过多的文档，它只出现在 Rails Edge中，现在来介绍一下。

ActiveRecord并不需要做配置，在默认情况下会自动运行。看看这个action：

    class BlogController &lt; ApplicationController
      def some_complex_thing
        post = Post.find(1)
        # .... Do alot of other stuff
        post_again = Post.find(1)
      end
    end

在没有AR缓存的情况下，SQL查询会进行两次。现在使用了AR缓存后，在第二次的查询会读取第一次查询时生成的缓存。这样就不用担心在单个的Action中两次相同的查询会查询数据库两次了。

不过这里的例子不够直观，但想像复杂的认证代码。很多时候可能会在多种认证方式中进行用户数据的查询，而且这是发布在几个不同地方的代码中的，如果缓存了结果，无疑对性能有提高。

查询缓存在action中第一次查询时缓存，在action结束时清除掉缓存。这里没有真正的存储，当 inserts/updates/deletes 执行时，全部缓存就会刷新。如果你要在多个actions或users间缓存数据，请使用MemCache。

参考：

关于fragment缓存的失效可以参看martin推荐的<a href="http://www.ruby-lang.org.cn/forums/thread-1701-1-3.html">timed_fragment_cache插件</a><br /> 关于AR的缓存，可以看看<a href="http://ryandaigle.com/articles/2007/2/7/what-s-new-in-edge-rails-activerecord-explicit-caching">这篇文章</a>的，<a href="http://yudionrails.com/2007/12/17/what-s-new-in-edge-rails-activerecord-explicit-caching">这篇文章yudi有翻译</a>。
