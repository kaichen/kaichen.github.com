--- 
layout: post
title: 10分钟在Netbean 6上完成Rails 2.0的Weblog
---
原文来自：<a href="http://blogs.sun.com/divas/entry/creating_a_rails_2_0">http://blogs.sun.com/divas/entry/creating_a_rails_2_0</a>

本文是之前NetBean6关于Ruby部分的教程（<a href="http://www.ruby-lang.org.cn/forums/thread-1896-1-1.html">http://www.ruby-lang.org.cn/forums/thread-1896-1-1.html</a>）其中的一个例子，如何在10分钟创建一个Weblog的升级版。<!--more-->我会把和之前的不同之处用<font color="Blue">蓝色</font>标记出来

Rails2.0到来之后带来了很多新的特性，新的变化，这样就导致了以前大量的Rails1.2.X的示例无法在升级到Rails2.0之后运行。 NetBeans6关于Ruby部分的教程中的例子就是这样，由于之前采用的是Rails1.2.5还有ActionController的脚手架方法（scaffold），这些与Rails 2.0并不兼容，故作者写了一篇文章，也就是之前那篇的升级版，一边学习Rails 2.0的新特性新变化，一边修改例子。

首先创建一个Rails项目，这个和以前一样，也就是File &gt; New Project，名字取weblog2.0吧，具体参考上面提到的那篇旧的文章！

创建出项目后自动打开database.yml，真是神奇，NB6竟然帮我们修改好了，使用了以前默认的MySQL，莫非它知道我们对MySQL比较熟？配置一下用户名和密码吧。然后就<font color="Blue">右键点击项目选择Rake Task =&gt; db =&gt; create</font>来创建数据库。

接着开始使用Rails 2.0的脚手架创建Model和Controller。右击项目后选择Generate，<font color="Blue">接着在下拉列表中选择scaffold，再在Model栏中输入Post title:string。注意在Rails 2.0下不能在此对话框的Controller和Action栏里填入字符。</font>这样就创建好了Post model和PostsController还有<font color="Blue">相关的view（可以看到后缀都改为.html.erb了）</font>。在生成的迁移任务（migrate）中可以看到Rails 2.0的新脚手架已经帮你填好了，如下代码：

    # db/migrate/001_create_posts.rb
    class CreatePosts &lt; ActiveRecord::Migration
      def self.up
        create_table :posts do |t|
          t.string :title
          t.timestamps
        end
      end
      def self.down
        drop_table :posts
      end
    end

那就直接可以运行migrate了，和之前一样，右击项目=&gt; Migrate Database =&gt; To current version，或者 Rake Task =&gt; db =&gt; migrate。

接下来就可以运行一下看看这个应用了。不过先要修改默认路由，注释掉默认路由（welcome），然后添加新的路由:

    # config/routes.rb
    # map.root :controller =&gt; "welcome"
    map.root :controller =&gt; "posts"

Rails 2.0脚手架默认生成的规则是REST的，以后添加自定义的Controller的Action要用REST化的方式编写路由。这里可以看到用的也是 <font color="Blue">具名路由，map.root</font>。接着删除了public/ index.html后按下NB6工具栏上面大大的三角形运行服务器，这就可以用浏览器打开那localhost:3000看到我们刚刚完成的一切了。 

按照之前的教程里，下一步就是添加Post的字段。右击Database Magrate =&gt; Generate，接着在Argument栏中填入AddBodyToPost body:text。这样Rails 2.0又帮我们写好了migrate任务，剩下的就是执行migrate任务。添加了新的字段后，就要修改view了，让我们再次打开Generate对话框，在下拉框中选择scaffold，在Model栏输入Post title:string body:text --skip-migration，并且这次要在下面的单选按钮中选择overwrite。然后就可以打开浏览器看看生效了没有。

下一步就是让Rails对创建Post时进行输入校验。这里展示的是对Post的属性进行非空校验，在Post Model源码（app/model/post.rb）中新建一行，输入vp再按tab，NB6的模板完成功能就体现了，vp自动扩展为 validates_presence_of，那接着就输入:title, :body。（由此可得vu就是 validates_uniqueness_of，试了一下，果然，具体模板完成请看NB6中选项里关于模板的部分）下来就是打开浏览器试验一下。 

最后一步就是稍微打扮一下weblog，打开app/view/posts/index.html.erb，把文件里的内容替换为以下内容：

    &lt;h1&gt;The Ruby Blog&lt;/h1&gt;
     &lt;% @posts.each do |post| %&gt;
      &lt;h2&gt;&lt;%= post.title %&gt;&lt;/h2&gt;
      &lt;p&gt;&lt;%= post.body %&gt;&lt;/p&gt;
      &lt;small&gt; &lt;%= link_to 'Permalink', post_path(post) %&gt;&lt;/small&gt;
      &lt;hr&gt;
    &lt;% end %&gt;
    &lt;br /&gt;
     &lt;%= link_to 'New post', new_post_path %&gt;

最后就是让Posts按时间顺序显示，把上面第3行代码改为：

    &lt;% @posts.reverse.each do |post| %&gt;

可以看到在视图中，新的脚手架创建的这句代码&lt;%= link_to 'New post', new_post_path %&gt;中的new_post_path，这是Rails2.0中REST化的体现之一。另外，原文中第6行代码还是以前那种写法，也就是指定controller和action的写法，我改了过来，让它和下面New Post的写法统一，我在原文下面留言提了这个。

很多同学都有问我，Rails升级到2.0后NB6中关于Ruby的这个10分钟创建weblog的教程怎么做，这里就是答案。有什么错误请大家指出来哦。
