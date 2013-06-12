---
layout: post
title: "Rails 2.0: Nested Resource"
date: "2008-03-02 20:00"
comments: true
categories: [Ruby on Rails, Ruby]
---

Rails2.0中提供了一套更好的嵌套资源的处理方法（更加形象化）。

比如有两个model:

{% codeblock lang:ruby %}
# app/model/project.rb
class Project < ActiveRecord::Base
  has_many :tasks
end
# app/model/task.rb
class Task < ActiveRecord::Base
  belongs_to :project
end
{% endcodeblock %}

在migrate中可以用referece类型来表示引用外键，比如在创建task的migrate中

{% codeblock lang:ruby %}
create_table :tasks do |t|
  #...
  t.references :project
  #...
end
{% endcodeblock %}

路由规则定义如下：

{% codeblock lang:ruby %}
# config/routes.rb
ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :tasks
  end
end
{% endcodeblock %}

比较好的一个方法调用Task所属Project的方法是用before_filter调用一个方法来设置：

{% codeblock lang:ruby %}
class ArticlesController &lt; ApplicationController
  before_filter :load_project
  #...
  def load_project
    @project = Project.find params[:project_id]
  end
end
{% endcodeblock %}

把Controller中的涉及内嵌资源的find和new的调用改一下：

{% codeblock lang:ruby %}
@project.tasks.find #=> 代替原来的Tasks.find
@projece.tasks.build #=> 代替原来的Tasks.new
{% endcodeblock %}

还有把Controller中的redirect_to方法的参数修改一下：

{% codeblock lang:ruby %}
redirect_to([@project, @task])
{% endcodeblock %}

那在Task的view中应该做如下处理

在生成表单时，传入一个数组给form_for方法：

{% codeblock lang:ruby %}
form_for([@project, @task])
{% endcodeblock %}

调用TasksController的new方法：

    new_project_task_path
    # => domain/projects/:id/tasks/new

调用TasksController的show方法：

    link_to 'Show', [@project, @task]
    # => domain/projects/:id/tasks/:id

调用TasksController的edit方法：

    link_to 'Edit' edit_project_task_path
    # => domain/projects/:id/tasks/:id/edit

或者

    link_to 'Delete', [:edit, @project, @task]
    # => domain/projects/:id/tasks/:id/edit

调用TasksController的destory方法：

    link_to 'Delete', [@project, @task], :confirm =&gt; 'Are you sure?', :method =&gt; :delete
    # => domain/projects/:id/tasks/:id

通过这些方法就能让内嵌资源使用时更加优雅，而不用在导向时指定controller和action，再传入父资源和子资源的id。这些xx_path方法会帮你查找routes.rb的路由定义，然后生成url，当然这一切都是基于Rails2.0提倡的RESTful。

参考文章：
<http://www.akitaonrails.com/2007/12/12/rolling-with-rails-2-0-the-first-full-tutorial>
