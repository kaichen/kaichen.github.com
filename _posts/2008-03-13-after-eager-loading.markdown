--- 
layout: post
title: After Eager Loading
---
Eager Loading是ActiveRecord的一个数据查询的优化措施，在查询model的时候连同它的关联对象都全查询出来（通过一条包含LEFT OUTER JOIN的SQL语句）。但是在你使用了Eager Loading后，如果还是用一些会触发数据库本身的统计函数的查询方法（如count，average等）的话，那前面的Eager Loading就白费了。下面给出例子：<!--more-->

两个Model，Project和Task，关系是Project has_many Task。

在ProjectController的show中：

    @project&nbsp;=&nbsp;Project.find(params[:id],&nbsp;:include&nbsp;=&gt;&nbsp;[:articles,&nbsp;:tasks])

这是project/show页面：

    &lt;h1&gt;&lt;%=h&nbsp;@project.title&nbsp;%&gt;&lt;/h1&gt;&nbsp;&lt;h2&gt;&lt;%=h&nbsp;@project.description&nbsp;%&gt;&lt;/h2&gt;&nbsp;&lt;p&gt;统计信息:&lt;br/&gt;共有&lt;%=&nbsp;@project.tasks.count&nbsp;%&gt;个&lt;%=link_to&nbsp;'任务',&nbsp;project_tasks_path(@project)%&gt;，&nbsp;已完成&lt;%=&nbsp;@project.completed_tasks.length&nbsp;%&gt;个任务。&nbsp;&lt;hr/&gt;&nbsp;&lt;h3&gt;最新未完成的5个任务&lt;/h3&gt;&nbsp;&lt;table&gt;&nbsp;&nbsp;&nbsp;&lt;tr&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;th&nbsp;width="25%"&gt;任务名&lt;/th&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;th&nbsp;width="75%"&gt;任务摘要&lt;/th&gt;&nbsp;&nbsp;&nbsp;&lt;/tr&gt;&nbsp;&nbsp;&nbsp;&lt;%&nbsp;for&nbsp;task&nbsp;in&nbsp;@project.tasks.incompleted&nbsp;%&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;tr&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;td&gt;&lt;%=&nbsp;link_to&nbsp;task.name,&nbsp;project_task_path(@project,task)&nbsp;%&gt;&lt;/td&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;td&gt;&lt;%=&nbsp;task.content&nbsp;%&gt;&lt;/td&gt;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;/tr&gt;&nbsp;&nbsp;&nbsp;&lt;%&nbsp;end&nbsp;%&gt;&nbsp;&lt;/table&gt;

来看看log吧：

    Project Load Including Associations (0.000595)   SELECT `projects`.`id` AS t0_r0, `projects`.`title` AS t0_r1, `projects`.`description` AS t0_r2, `projects`.`created_at` AS t0_r3, `projects`.`updated_at` AS t0_r4, `articles`.`id` AS t1_r0, `articles`.`subject` AS t1_r1, `articles`.`summary` AS t1_r2, `articles`.`content` AS t1_r3, `articles`.`project_id` AS t1_r4, `articles`.`created_at` AS t1_r5, `articles`.`updated_at` AS t1_r6, `articles`.`lock_version` AS t1_r7, `tasks`.`id` AS t2_r0, `tasks`.`name` AS t2_r1, `tasks`.`content` AS t2_r2, `tasks`.`completed` AS t2_r3, `tasks`.`project_id` AS t2_r4, `tasks`.`created_at` AS t2_r5, `tasks`.`updated_at` AS t2_r6 FROM `projects` LEFT OUTER JOIN `articles` ON articles.project_id = projects.id LEFT OUTER JOIN `tasks` ON tasks.project_id = projects.id WHERE (`projects`.`id` = 2)
    Rendering template within layouts/application
    Rendering projects/show
    SQL (0.000255)   SELECT count(*) AS count_all FROM `tasks` WHERE (tasks.project_id = 2)

可以看到在Project的Eager Loading的查询之后可以看到又有一个count()的select查询进行了。那前面的Eager Loading的效果似乎没有了。再试试把count方法调用改为调用length方法，这时就看不到另外的那个count()查询了。

这个可能在写代码的时候不会太留意，不过这对性能的影响还是有些的，如果Eager Loading后不会在调用统计函数就ok了。
