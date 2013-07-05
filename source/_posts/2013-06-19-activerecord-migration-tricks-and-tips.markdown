---
layout: post
title: "你可能不知道的ActiveRecord Migration小技巧"
date: 2013-06-19 10:22
comments: true
categories: ["ActiveRecord", "Ruby on Rails", "Ruby"]
---

ActiveRecord的Migration是ActiveRecord用来维护RDBMS Schema的工具，
使开发者的机器和服务器上的Schema保持同步。其原理在于将每次对数据库的改动都保存为一个脚本，
并以改动内容以及时间戳命名防止重复。

以下我分享一些关于Migration的小技巧。

## say/say\_with\_time

我们有时会在Migration里执行数据的改动或更新，而此时最好能在输出里打印一些对应的信息，或者记录下对应的代码的执行时间。

[say](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say)和
[say_with_time](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time)就是为了上述需求而诞生的。对比使用`puts`之类的方法的优点是，这类输出会带有缩进或对应的与
Migration各种API更一致的输出。

下次需要在Migration里输出点什么的话，请用`say`以及`say_with_time`吧。

## references/belongs\_to

很多时候我们会创建互相关联的表，这就需要在表里加入一些引用到其它表的外键字段，这时我们一般会以添加一个
integer类型的字段，并赋以对应的名字(一般为对应模型的单数形式再加上`_id`)。ActiveRecord提供了[references](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-references)API帮助我们更快捷地处理这种情况。

这里列出文档中的一个非常好的例子，这个例子非常明显地体现了使用这个API的好处。

{% codeblock lang:ruby %}
create_table :taggings do |t|
  t.references :tag, index: { name: 'index_taggings_on_tag_id' }
  t.references :tagger, polymorphic: true, index: true
  t.references :taggable, polymorphic: { default: 'Photo' }
end
{% endcodeblock %}

以上的代码等价于下面较长的代码：

{% codeblock lang:ruby %}
create_table :taggings do |t|
  t.integer :tag_id, :tagger_id, :taggable_id
  t.string  :tagger_type
  t.string  :taggable_type, default: 'Photo'
end
add_index :taggings, :tag_id, name: 'index_taggings_on_tag_id'
add_index :taggings, [:tagger_id, :tagger_type]
{%  endcodeblock %}

此外，`references`这个API也被alias为更容易记住的`belongs_to`。

## change\_table

在Migration里提供了Schema操作的API都操作了两种形式，比如`add_column`和`column`。在`create_table`里
可以使用如`column`比较简短形式的API，这与Form Helper在Form Buildler里可以使用不带`_tag`后缀的API一致。

当我们需要去对同一个表做多次操作的时候，可以通过`change_table`来化简代码，在`change_table`的代码块中，
可以使用简短形式的API

{% codeblock lang:ruby %}
change_table(:suppliers) do |t|
  t.column :name, :string, limit: 60  
  t.remove :company_id
end
{% endcodeblock %}

## create\_join\_table/drop\_join\_table

当我们使用多对多(has_and_belongs_to_many)关联时需要创建关联表，而关联Schema很简单，只是
需要把关联的两张表的ID字段分别记录下来，而其中涉及了ActiveRecord的命名规范。这时使用
[create_join_table](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table)这个API就能很方便地帮我们去处理命名的事情，
只需要将对应两个表的表名作为参数传进去。

对应的也有一个[drop_join_table](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table)API去帮我们删除这种关联表。

## change\_column\_default/change\_column\_null

业务总是在不断变化的，有时数据库里一些字段可能会由非空改为允许为空，修改默认值。当你把这些规则放到数据库时就
需要修改对应的字段和数据。

{% codeblock lang:ruby %}
change_column_null(:users, :nickname, false)
change_column_default(:accounts, :authorized, 1)
{% endcodeblock %}

`change_column_default`会做两个事情，首先是把对应的字段填上指定的默认值，之后再修改Schema。

## reversible

我们知道Migration提供了Up/Down两个方向，相当于do和undo。随着`change`API的流行，很多时候我们不会去写
up和down两个方法，但有时就是需要写两个方向的代码。比如下面这个例子，在添加了first_name和last_name两个字段
后，在up这个方法上需要从full_name字段提取出first_name和last_name，而down的方法又需要合并出full_name的数据，这就是[reversible](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible)的使用场景。

{% codeblock lang:ruby %}
class SplitNameMigration < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    reversible do |dir|
      User.reset_column_information
      User.all.each do |u|
        dir.up   { u.first_name, u.last_name = u.full_name.split(' ') }
        dir.down { u.full_name = "#{u.first_name} #{u.last_name}" }
        u.save
      end
    end

    revert { add_column :users, :full_name, :string }
  end
end
{% endcodeblock %}

## revert

某些时候写反向的逻辑会比正向的逻辑好写一点，比如有时我们会用`unless`而不是`if`。Migration里的
[revert](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert)方法就能提供这样的形式去编写数据库改动。

{% codeblock lang:ruby %}
class FixTLMigration < ActiveRecord::Migration
  def change
    revert do
      create_table(:horses) do |t|
        t.text :content
        t.datetime :remind_at
      end
    end
    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
{% endcodeblock %}

同时`revert`这个方法也支持传入一个Migration的名字，其作用是执行该Migration的down方法，当某个Migration已经同步上代码库后，希望撤销这个Migration时特别有用。

{% codeblock lang:ruby %}
require_relative '2012121212_tenderlove_migration'

class FixupTLMigration < ActiveRecord::Migration
  def change
    revert TenderloveMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
{% endcodeblock %}

## At the end

最后，提示一下，以上的API有些在Rails 3.x中没有加入，在Rails 4.0上以上的API可以找到。