--- 
tags: ['posts']
title: 译文 Rails Cache教程1
date: 2008-01-30
---
原文来自Rails Envy
<http://railsenvy.com/2007/2/28/rails-caching-tutorial>

整个教程有两部份，第一部分也就是这篇讲page cache，第二篇讲其它的cache。这篇文章其实主要还是讲基础，不过结合了一些示例，并配上生动的语言。

合适的缓存机制可以提升Rails应用的性能。而Page Cache就是Rails中最高效的缓存。Page Cahe机制可以让每次请求不用进行数据库查询，甚至不用触动到Ruby解析器，完全由前端web服务器来进行服务。

配置

如果你想在devlopment模式启用cache机制，就需要修改`/config/environments/development.rb`文件，找到下面这行并把配置项改为true：

    config.action_controller.perform_caching = true

页面缓存

两种很适合缓存页面的情况：

1. 当页面对于所有用户都是相同的
2. 当页面是公开的，而且无须用户认证

假设环境是在一个不经常改动的Blog页面中。。。Controller的代码应该貌似这样：

    class BlogController &lt; ApplicationController
      def list
         Post.find(:all, :order =&gt; "created_on desc", :limit =&gt; 10)
      end
      ...

如果想要缓存list action中显示的页面就在代码中加入：

    class BlogController &lt; ApplicationController
       caches_page :list
      
       def list
         Post.find(:all, :order =&gt; "created_on desc", :limit =&gt; 10)
       end
      ...

这样，在下次请求时就会生成并返回缓存好的list.html页面，下下次的话就是直接返回缓存页面。

如果使用的是mongrel，对list action进行配置后的第一次请求时，/logs/development.log会有貌似以下的记录：

    Processing BlogController#list (for 127.0.0.1 at 2007-02-23 00:58:56) [GET]
    Parameters: {"action"=&gt;"list", "controller"=&gt;"blog"}
    SELECT * FROM posts ORDER BY created_on LIMIT 10
    Rendering blog/list
    Cached page: /blog/list.html (0.00000)
    Completed in 0.18700 (5 reqs/sec) | Rendering: 0.10900 (58%) | DB: 0.00000 (0%) | 200 OK [http://localhost/blog/list]

Cached page: `/blog/list.html`

这行记录表明了页面已被导入，并存放在`/public/blog/list.html`位置下。在这个文件中没有一丁点Ruby代码。下一次请求到来时又会绕过Rails再次返回这个静态页面，这就提升了效率，降低了服务器的开销。

这样的话，如果是有动态表单的页面和经常更新的页面，Page Cache就不太适合了。不过还可以采用其它的缓存机制，请留意本教程的Part2。（卖广告:&gt;）如果在代码里再加上这一句：

    caches_page :show

当URL指向`/blog/show/5`访问id为5的blog日志时，请问调用的是哪个缓存文件（或其文件名为什么）？

答案是：`/public/blog/show/5.html`

看看下面的例子（URL和对应的缓存文件）：

    http://localhost:3000/blog/list =&gt; /public/blog/list.html
    http://localhost:3000/blog/edit/5 =&gt; /public/edit/5.html
    http://localhost:3000/blog =&gt; /public/blog.html
    http://localhost:3000/ =&gt; /public/index.html
    http://localhost:3000/blog/list?page=2 =&gt; /public/blog/list.html

伊，等等，不太对阿。第一行和最后一行怎么返回的缓存文件一样？Page Cache忽略了URL附带的参数了。

在采用分页的页面怎么使用Page Cahe

要缓存不同的文件，只能创建不同格式的URL了。使用`/blog/list?page=2`的话会出问题，那就使用`/blog/list/2`吧。这样子的话，数字2就是作为params[:id]了，那就要修改路由规则（`/config/routes.rb`）了：

    map.connect 'blog/list/:page',
        :controller =&gt; 'blog',
        :action =&gt; 'list',
        :requirements =&gt; { :page =&gt; /\d+/},
        :page =&gt; nil

配合新的路由，页面的链接也要改一下：

    &lt;%= link_to "Next Page", :controller =&gt; 'blog', :action =&gt; 'list', :page =&gt; 2 %&gt;

上面这句生成的URL就是`/blog/list/2`了，访问这 URL时会以下两件事会发生：

Rails应用把数字2作为params[:page]

这个页面被缓存为`/public/blog/list/2.html`

上面这个示例告诉我们，如果要使用PageCache机制的话，那就要对附加参数做一下处理，让附加参数成为URL的一部分。

清理Cache

页面失效了怎么办？那就清理掉失效页面呗！

以下两行代码可以清除上面例子中生成的Cache：

    # This will remove /blog/list.html
    expire_page(:controller =&gt; 'blog', :action =&gt; 'list')
    # This will remove /blog/show/5.html
    expire_page(:controller =&gt; 'blog', :action =&gt; 'show', :id =&gt; 5)

那就要在每次添加/改动/删除blog日志时都进行这些操作。要把这两行代码加入action中吗？不，有优雅的解决方法。。。

Sweepers

Sweepers是一些能在页面失效是删除旧的缓存的代码。Sweepers监视Model的一举一动，当Model进行CRUD时，Sweepers得知后就会去把相应的缓存删除掉。

Sweepers的操作应该放在一个Controller中，而且作者认为还应该与其它的controller分离开。那就要改动配置文件`/config/environment.rb`：

    Rails::Initializer.run do |config|
       # ...
       config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )
       # ...
    end

友情提示，改动环境变量之后记得重启服务器。

如上改动后在/app/sweepers创建sweepers，文件`/app/sweepers/blog_sweeper.rb`应该是这样：

    class BlogSweeper &lt; ActionController::Caching::Sweeper
      observe Post # This sweeper is going to keep an eye on the Post model
      # If our sweeper detects that a Post was created call this
      def after_create(post)
              expire_cache_for(post)
      end
      
      # If our sweeper detects that a Post was updated call this
      def after_update(post)
              expire_cache_for(post)
      end
      
      # If our sweeper detects that a Post was deleted call this
      def after_destroy(post)
              expire_cache_for(post)
      end
             
      private
      def expire_cache_for(record)
        # Expire the list page now that we posted a new blog entry
        expire_page(:controller =&gt; 'blog', :action =&gt; 'list')
       
        # Also expire the show page, incase we just edited a blog entry
        expire_page(:controller =&gt; 'blog', :action =&gt; 'show', :id =&gt; record.id)&lt;
      end
    end

生成Sweepers可以使用插件Sweeper Generator，可以参看[martin的介绍](http://www.ruby-lang.org.cn/forums/thread-1085-1-5.html)。

友情提示：用after_save方法可以代替上面的after_create和after_update两个方法。

要调用Sweepers，在文件`/app/controllers/BlogController.rb`中应这些写代码：

    class BlogController &lt; ApplicationController
       caches_page :list, :show
       cache_sweeper :blog_sweeper, :only =&gt; [:create, :update, :destroy]
       ...

当创建一个Blog日志时，会在`logs/development.log`中发现这样的记录：

    Expired page: /blog/list.html (0.00000)
    Expired page: /blog/show/3.html (0.00000)

hoho~ sweepers生效了。

在Apache/Lighttpd的漂亮演出

许多Rails应用都会使用Apache作为前端，用Mongrel / Lighttpd处理动态的RoR请求。要使Rails的Page Cache机制生效，告诉服务器当请求来的时候去哪里查找缓存页面。下面是配置Apache为例，修改`httpd.conf`文件：

    &lt;VirtualHost *:80&gt;
      ...
      # Configure mongrel_cluster
      &lt;Proxy balancer://blog_cluster&gt;
        BalancerMember [url]http://127.0.0.1:8030[/url]
      &lt;/Proxy&gt;
      RewriteEngine On
      # Rewrite index to check for static
      RewriteRule ^/$ /index.html [QSA]
      # Rewrite to check for Rails cached page
      RewriteRule ^([^.]+)$ $1.html [QSA]
      # Redirect all non-static requests to cluster
      RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_FILENAME} !-f
      RewriteRule ^/(.*)$ balancer://blog_cluster%{REQUEST_URI} [P,QSA,L]
      ...
    &lt;/VirtualHost&gt;

在lighttpd中应该是类似这样：

    server.modules = ( "mod_rewrite", ... )
    url.rewrite += ( "^/$" =&gt; "/index.html" )
    url.rewrite += ( "^([^.]+)$" =&gt; "$1.html" )

这样代理服务器就会/public目录下查询cache文件，这样你可能会想要修改cache文件的目录。

把Cache文件分离处理

首先这样修改`/config/environment.rb`：

    config.action_controller.page_cache_directory = RAILS_ROOT + "/public/cache/"

这样就让Rails在`/public/cache/` 下生成缓存文件了。接着就修改前端服务器Apache的配置文件`httpd.conf`：

      # Rewrite index to check for static
      RewriteRule ^/$ cache/index.html [QSA]
      # Rewrite to check for Rails cached page
      RewriteRule ^([^.]+)$ cache/$1.html [QSA]

清理单个局部或者全部缓存

当开始使用页面缓存的时候可能会发现，一旦对模型有CRUD操作，基本上所有的缓存都要被清除掉。那直接删除了生成的缓存文件岂不是更好更快。

首先要把cache文件分离出来，这在上一步已经做了。下面的代码直接删除cache文件夹下的所有文件，并记录事件到日志中：

        class BlogSweeper &lt; ActionController::Caching::Sweeper
          observe Post
          def after_save(record)
            self.class::sweep
          end
          
          def after_destroy(record)
            self.class::sweep
          end
          
          def self.sweep
            cache_dir = ActionController::Base.page_cache_directory
            unless cache_dir == RAILS_ROOT+"/public"
              FileUtils.rm_r(Dir.glob(cache_dir+"/*")) rescue Errno::ENOENT
              RAILS_DEFAULT_LOGGER.info("Cache directory '#{cache_dir}' fully sweeped.")
            end
          end
        end

FileUtils.rm_r 方法删除目录下所有文件。这就相当于执行了多次的expire操作。也可以删词cache目录的子目录下的文件，如下面代码展示的对 /public/blog目录下所有文件进行删除：

        cache_dir = ActionController::Base.page_cache_directory
        FileUtils.rm_r(Dir.glob(cache_dir+"/blog/*")) rescue Errno::ENOENT

更高级的Page Cache技巧？

在大型Web应用中Page Cache的处理将会是非常复杂的。

Rick Olson写了[Referenced Page Caching Plugin](http://svn.techno-weenie.net/projects/plugins/referenced_page_caching/)用数据库来对缓存页面进行跟踪。README中有一些示例展示。

Max Dunn写了篇文章[Advanced Page Caching](http://blog.maxdunn.com/articles/2006/09/16/ruby-on-rails-advanced-page-caching)，向我们展示了他如何使用cookies动态地改变页面缓存处理基于用户角色的wiki页面。

最后，Page Cache还无法解决缓存xml文件，Mike Zornek讲述了这个问题并提出了一些方法，详见<http://clickablebliss.com/blog/2006/02/17/rails_caching_xml_bad_mime_types/>。 

Page Cache怎么测试？

Rails本身并没有提供给我们。Damien Merenne写了一个插件<http://blog.cosinux.org/pages/page-cache-test>试图解决这个问题。试一下。
