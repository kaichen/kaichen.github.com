---
layout: article
title: "[译文] New Feature on Rails 2.1: change_table"
date: 2008-05-12 11:11
tags: [Ruby, ActiveRecord, Ruby on Rails]
---
原文：http://blog.codefront.net/2008/05/04/living-on-the-edge-of-rails-19-change_table-for-migrations-and-more/

现在可以通过 change_table 代码块来完成对数据库表的修改。

```ruby
change_table :videos do |t|
  t.add_timestamps
  t.add_belongs_to :goat
  t.add_string :name, :email, :limit =&gt; 20
  t.remove_column :name, :email # takes multiple arguments
  t.rename :new_name
  t.string :new_string_column # executes against the renamed table name
end
```

补充些要注意的事情：

* add_XXX 方法会添加一个新列，比如 add_string 会添加一个新的 string 类型的字段。
* Of course, add_timestamps 会添加神奇的 created_at 和 updated_at 的 datetime 类型的字段。
* remove_column 现在可以接受多个参数。
* rename 方法会重命名数据库表。
