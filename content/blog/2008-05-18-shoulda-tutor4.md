---
tags: ['posts']
title: "[译文] Shoulda教程4 - Test Controller"
date: 2008-05-18
---

基本的控制助手方法

如ActiveRecord宏一样，Shoulda 提供了一套测试控制器的宏，以尽可能简洁的方法进行测试。所有的这些方法都在Shoulda的Rdoc中，但这里再送上一个快捷的例子：

```ruby
    class UsersControllerTest < Test::Unit::TestCase
        context "on GET to :show" do
            setup { get :show, :id => 1 }

            should_assign_to :user
            should_respond_with :success
            should_render_template :show
            should_not_set_the_flash

            should "do something else really cool" do
                assert_equal 1, assigns(:user).id
            end
        end

        context "on POST to :create" do
            setup { post :create, :user => {:name => 'Ronald', :party => 'Repukeulan' } }
            should_assign_to :user
            should_redirect_to "user_url(@user)"
            should_set_the_flash_to(/created/i)
        end
    end
```

## 应该RESTful

这里每个 should_xxx 宏都会产生一个单独的测试方法，编写起来又DRY。而should_be_restful 宏可以产生遵循基本的RESTful设计模式的控制器。should_be_restful 宏就像一个超级测试生成器，每次调用是都会产生40到50个测试方法。这里有个超简单的例子：

```ruby
    class UsersControllerTest < Test::Unit::TestCase
        def setup
            @user = User.find(:first)
        end

        should_be_restful do |resource|
            resource.create.params = { :name => "Billy Bumbler", :party => 'Sure do!'}
            resource.update.params = { :name => "Changed" }
        end
    end
```

这里会生成一整套包含全部CRUD行为的测试，也包括 :new 和 :edit 。对这个宏还有很多定义的空间，能让它处理各种情况的控制器，不过默认设置已经非常智能了。在上面的例子中，通过测试类名就能查找出如何处理User模型，users_url方法，params[:user]，@user 和@users实例变量等。

### 配置should\_be\_restful

来看看更改should-be_restful产生的测试的行为的方法。（这些也在Rdoc文档中有详细记录）

```ruby
      class UsersControllerTest < Test::Unit::TestCase
          def setup
              @user = User.find(:first)
          end

          should_be_restful do |resource|
              resource.klass      = User
              resource.object     = :user
              resource.parent     = []
              resource.actions    = [:index, :show, :new, :edit, :update, :create, :destroy]
              resource.formats    = [:html, :xml]

              resource.create.params = { :name => "bob", :email => 'bob@bob.com', :age => 13}
              resource.update.params = { :name => "sue" }

              resource.create.redirect  = "user_url(@user)"
              resource.update.redirect  = "user_url(@user)"
              resource.destroy.redirect = "users_url"

              resource.create.flash  = /created/i
              resource.update.flash  = /updated/i
              resource.destroy.flash = /removed/i
          end
      end
```

下面是参数的具体解释：

* klass：要处理的模型类。
* objuect：用于#edit，#update和#destroy测试的对象的名字。所以如果在setup中实例化@user，那么res.object 应该设置为 :user。
* parent：嵌套资源中的上级对象名字。这是要传入到嵌套资源url助手方法的参数。如果不需要用到嵌套资源，可以忽略这个参数。如果使用嵌套资源，路由设置中:users置于:cities之下，那么user测速中res.parent设置应为:city。实际上，parent参数是User模型类的关联对象引用。所以如果当User belongs_to :location，class_name => "City"，那么应该把这个参数设置为:city。
* actions：要测试的行为列表。这个值应该是[:index, :show, :new, :edit, :create, :update, :destroy]（默认）的子集或全集。如果控制器是read_only的，那么可能需要设置这个值为[:index, :show]。
* formats：测试控制器支持的格式列表。默认值为:html和 :xml，以后会加入JSON，CSV和其他。添加上其他的新格式也是非常简单的，可以参考ThoughtBot::Shoulda::Controller::XML文件。</blockquote>

在#create，#update和#destory测试中可以附上一些参数：

* params：要传给行为的参数。
* flash：在行为完成之后在flash中预期得到的值。可以是字符串或者正则表达式。
* redirect：在行为完成之后应该重定向到方向。这里有些巧妙...在测试运行时才会解释设置的字符串。这个延后解析的字符串将会遍历所有的命名路由和所有控制器创建的实例变量。

### Denied行为

RESTful控制器的部分或全部的行为在大多数场景里是有访问限制的（比如需要用户认证的时候）。resource.denied选项让should_be_restful原生地支持行为的访问限制。

```ruby
    class UsersControllerTest < Test::Unit::TestCase
        def setup
        @user = User.find(:first)
        end

        should_be_restful do |resource|
            resource.create.params = { :name => "bob", :email => 'bob@bob.com', :age => 13}
            resource.update.params = { :name => "sue" }

            resource.denied.actions  = [:new, :create, :edit, :update, :destroy]
            resource.denied.redirect = "new_session_url"
            resource.denied.flash    = /administrator/i
        end
    end
```

每个列在resource.denied.actions的行为（默认为空）将测试行为被限制访问，相关的记录不会被触及。 :redirect 和 :flash 参数和上面的 resource.create 和 resource.update 一样。

### 混合使用should_be_restful和上下文

测试每个控制器和所有控制器行为时，混合should_be_restful和上下文代码块是一个非常强大的方法。下面的代码是在我们（作者）的应用的测试中很常见到。

```ruby
    class PostsControllerTest < Test::Unit::TestCase
        def setup
            @user = users(:bob)
            @post = @user.posts.first
        end

        context "An administrator" do
            setup { login_as users(:admin) }

            should_be_restful do |resource|
                resource.create.params = { :subject => "test", :body => "message" }
                resource.update.params = { :subject => "changed" }
            end
        end

        context "A user" do
            setup { login_as @user }

            should_be_restful do |resource|
                resource.create.params = { :subject => "test", :body => "message" }
                resource.update.params = { :subject => "changed" }
            end
        end

        context "A stranger" do
            setup { login_as users(:sally) }

            should_be_restful do |resource|
                resource.create.params   = { :subject => "test", :body => "message" }
                resource.denied.actions  = [:edit, :update, :destroy]
                resource.denied.redirect = "login_url"
                resource.denied.flash    = /only the owner can/i
            end
        end

        context "The public" do
            setup { logout }

            should_be_restful do |resource|
                resource.denied.actions  = [:new, :create, :edit, :update, :destroy]
                resource.denied.redirect = "signup_url"
                resource.denied.flash    = /must be a member/i
            end
        end
    end
```

### 混合与匹配

最后，记住更好的测试在should_be_restful助手之外的额外行为，或者在Shoulda中加入一般的test_xxx方法。

```ruby
    class UsersControllerTest < Test::Unit::TestCase
        def setup
            @user = User.find
        end

        should_be_restful do |resource|
            resource.create.params = { :name => "Billy Bumbler", :party => 'Sure do!'}
            resource.update.params = { :name => "Changed" }
        end

        context "on GET to /users/:id;activate"
            setup { get :activate, :id => @user.id }
            should_render_template :activate
            # etc.
        end

        def test_normal_stuff
            assert true
        end
    end
```