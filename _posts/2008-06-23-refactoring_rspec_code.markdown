--- 
layout: post
title: 重构Rspec测试代码
---
消除Spec中的冗余，减少浪费。

看到ben的Blog写了一篇关于Rspec的测试宏的文章：
http://www.benmabey.com/2008/06/08/writing-macros-in-rspec/

其实很多人都是看到Tammer Saleh在MountainWest_Ruby_Conference2008上的Shoulda演示后，和我有一样的感想，就是如果如此DSL化，如此DRY的测试宏能用在Rspec上那就好了。那时我还把Shoulda的官方文档翻译了一下=_=，还有人和我讨论为什么要用Shoulda，还说他就是喜欢Rspec，其实我一次也没有用过Shoulda，但就是觉得这个DSL写的很好。不过Shoulda的缺点也很明显，AR的测试宏依赖于fixture，在业界不提倡使用fixture的情况下还有对测试数据的控制粒度的角度来说，这个做法是不受欢迎的。Rspec中提倡的是全部数据都是在测试时手动Mock出来，所以在1.1.4中才有了stub_mock!这个方法来减轻Mock对象的负担。

Rspec测试的粒度是比较细的，测试的覆盖面在Stroy框架出来之后也能和之前Rails提供的Unittest一样。但是Rspec的测试代码，看上去很冗余，一开始就有这种感觉，一直到看到了Shoulda才发现原来它冗余的地方是什么，这存在于很多地方，比如Controller中每次都是mock一个请求方法，然后就对各种会触发的行为和保存的状态进行断言。这些每次千篇一律的东西，我在想如果在每个context下定义一个请求方法（do_xxx之类的），然后在测试时会在测试方法内部的断言前或断言后自动调用它，这样就能减少很多冗余了。当然我在看完了Shoulda的文档后也尝试写出Rspec的测试宏，不过由于不知道怎么连接到Rspec中就放弃了，话说回来，Rspec中每个测试中上下文关系是很复杂的。

不说废话了，看看鬼佬们怎么减少Rspec中的冗余吧。

下面是一个常见的以Product为领域模型的Controller的测试，用Rspec-Rails插件生成的Scaffold的测试就类似下面这样：

    describe ProductsController do
      describe "handling GET /products" do
     
        before(:each) do
          @product = mock_model(Products)
          Product.stub!(:find).and_return([@product])
        end
     
        def do_get
          get :index
        end
     
        it "should be successful" do
          do_get
          response.should be_success
        end
     
        it "should render index template" do
          do_get
          response.should render_template('index')
        end
     
        it "should find all products" do
          Product.should_receive(:find).with(:all).and_return([@product])
          do_get
        end
     
        it "should assign the found products for the view" do
          do_get
          assigns[:products].should == [@product]
        end
      end
    end

上面的代码一看过去就觉得很多重复吧。如果我想让它变成下面这些DSL化的测试代码要怎么办呢？

    describe ProductsController do
      describe "处理Get /products" do
        before(:each) do
          @products = mock_model(Product)
          Products.stub!(:find).and_return([@product])
        end
        def do_get
          get :index
        end
        it_should_response_success
        it_should_render :template, "index"
        it_should_receive Product, :find, :all, [@product]
        it_should_assign :products, [@product]
      end
    end

那么首先为这些宏定义一个Module吧：

    module ControllersMacro
      module ExampleMethods
        def do_action
          verb = [:get, :post, :put, :delete].find{|verb| respond_to? :"do_#{verb}"}
          raise "No do_get, do_post_ do_put, or do_delete has been defined!" unless verb
          send("do_#{verb}")
        end
      end
     
      module ExampleGroupMethods
        def it_should_assign(variable_name, value=nil)
          it "should assign #{variable_name} to the view" do
            value ||= instance_variable_get("@#{variable_name}")
            if value.kind_of?(String) &amp;&amp; value.starts_with?("@")
              value = instance_variable_get(value)
            end
            do_action
            assigns[variable_name].should == value
          end
        end
        def it_should_response_success
          it "should be successful" do
            do_action
            response.should be_success
          end
        end
        def it_should_receive model, action, with_value = anything, return_value = anything
          it "should make #{model.to_s} #{action.to_s}" do
            model.should_receive(action).with(with_value).and_return(return_value)
            do_action
          end
        end
      end
     
      def self.included(receiver)
        receiver.extend         ExampleGroupMethods
        receiver.send :include, ExampleMethods
      end
    end

这些就是Spec中的DSL，一般称为Rspec Macros，Rspec宏。那么那么把这些宏与Controller们挂钩呢？每次测试挂一次？当然不是，在ben那篇Blog的留言里，Rspec的核心开发成员David Chelimsky给出了答案，原来Rspec中本来就有接口开放了：

    Spec::Runner.configure do |config|
      #...
      config.include(ControllerMacros, :type =&gt; :controllers)
    end

这样就把测试宏挂到了Controller的Spec那里，那还等什么就直接在Spec用这些DSL来写出清爽的Spec吧，享受BDD。在这之后当然，我们不会止步于只在Controller中消除冗余，我立马就想到了Shoulda中几个Api，像下面那样，马上就能想到一些ActiveRecord的测试宏。

    module ModelsMacro
      module ExampleMethods
            #......
      end
     
      module ExampleGroupMethods
        def it_should_require_attributes(variable_name)
          it "should require #{variable_name}" do
           #TODO
          end
        end
           
        def it_should_require_unique_attributes variable_name
          it "should require unique attributes #{variable_name}" do
           #TODO
          end
        end
           
        def    it_should_not_allow_values_for variable_name, not_allow = []
          it "should require #{variable_name}" do
           #TODO
          end
        end
           
        def it_should_allow_values_for variable_name, allow_values = []
          it "should allow values for #{variable_name}" do
           #TODO
          end
        end
     
        def it_should_protect_attributes variable_name
          it "should protect attributes #{variable_name}" do
           #TODO
          end
        end
     
        def it_should_have_one variable_name
          it "should have one #{variable_name}" do
           #TODO
          end
        end
           
        def it_should_have_many variable_name, option =&gt; {}
          it "should have many #{variable_name}" do
           #TODO
          end
        end
                   
        def it_should_belong_to variable_name
          it "should belong to #{variable_name}" do
           #TODO
          end
        end
      end
     
      def self.included(receiver)
        receiver.extend         ExampleGroupMethods
        receiver.send :include, ExampleMethods
      end
    end

如果觉得自己写很麻烦，那就用别人做好的现成的东西吧：
一个现成的Rspec宏项目，Skinny Spec。它已经完成了Controller和AR的测试宏，页面的测试宏，还有一个生成器：
<a href="http://github.com/rsl/skinny_spec/tree">http://github.com/rsl/skinny_spec/tree</a>
使用很简单，只要用script/plugin安装就好了。不过这个还有些不足，比如还没有shoulda中那个should_be_restful这个最魔幻的方法，在控制器中做出请求动作的那个方法的定义是实现一个名为shared_request方法，在其中加入请求的方法和参数。

其实我对Rspec还有很多想法，比如更加DSL化的测试，对Mock测试数据时更加强大的控制，测试中描述信息的国际化，动态生成测试方法等等。

清爽的Rspec代码，相信每个人都想把它放进自己的项目中。。。
