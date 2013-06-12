--- 
layout: post
title: Story on Rspec
---
Stroy框架是一个在应用程序级别对测试进行描述的框架。Rspec的BDD测试中其实缺少了一个像Rails传统测试中的集成测试（integration tests）那样的东西，Rspec::Strop就是为了补上这个部分而产生的。

Stroy格式：

    Title (故事标题)
     
    故事的描述:
    作为一个怎样的角色
    我想要什么样
    最后得到怎样的结果
     
    验证故事的标准: (以场景(Scenario)的形式提出)
     
    Scenario: 场景标题
    Given [场景内容]
      And [场景附加内容]…
    When  [发生事件]
    Then  [产生的后果]
      And [其它后果]…
     
    Scenario: …

以上就是故事编写的基本结构，Given后可以加多个And，Then也是。故事直接保存为文本文件就可以了。然后开始编写故事的验证机制（其实就是针对上面描述的场景以代码来表示）。

故事验证格式：

    steps_for(:故事名)  do
      Given("场景内容") do |占位符|
        代码描述
      end
      When("发生事件") do |占位符|
        代码描述
      end
      Then("产生的后果") do |占位符|
        代码描述
      end
    end

解释下，Given块的个数应该与故事清单中的Given语句加后面的And的个数相当，Then块也是。

例子：
故事login

    Story: 以存在的用户身份登录
    作为一个未认证的用户
    我想要登录到网站
    那么我能看见我的账户信息

    Scenario: 正常登录
        Given 我的账户为test@example.org
        When 我用邮箱为test@example.org和密码是foofoo进行登录
        Then 我能够登录
        And 我会看到账户页面

故事验证login.rb：

    require 'rubygems'
    require 'spec/story'
    steps_for(:login) do
      Given "我的账户为$email" do |email|
        @user = find_or_create_user_by_email({:email =&gt; email,
        :password =&gt; 'foofoo',
        :password_confirmation =&gt; 'foofoo'})
      end
      
      When "我用邮箱为$email和密码是$password进行登录" do |email, password|
        post '/login', :user =&gt; \{:email =&gt; email, :password =&gt; password\}
      end
      
      Then("我能够登录") do
      end
      
      Then("我会看到账户页面") do
      end
    end
      
    with_steps_for(:login) do
      run "login"
    end

参考：
* <http://rspec.info/>
* <http://blog.davidchelimsky.net/articles/2007/10/22/plain-text-stories-on-rails>
* <http://dannorth.net/whats-in-a-story>
* <http://www.letrails.cn/archives/rspec-story-tutorials>
