---
title: "Read and Write ActiveRecord Attribute"
date: 2013-09-08
category: "inspect-rails"
tags: ["Ruby on Rails", "Ruby"]
---

上一节讲完了ActiveRecord的对象怎么从是数据库里取出来，但距离数据最终的读写其中还有不少的处理过程。比如模型的属性在读取时需要做出一些相应的转换，同理在修改了模型属性之后回写数据库的时候也需要做转换。另外ActiveRecord使用了Ruby的动态特性为所有的属性读写都生成了与属性名相对应的方法，让开发者能更加便捷地访问所需要的属性值。


## 原始数据

首先来看看数据库取出的数据怎样存放到对象中，以下是相应的代码，`instantiate`方法的解释请参考[Assemble ActiveRecord Object](/2013/07/26/assemble-ar-object)

```ruby
  # file: active_record/persistence
  def instantiate(record, column_types = {})
    column_types = self.decorate_columns(column_types.dup)
    klass.allocate.init_with('attributes' => record, 'column_types' => column_types)
  end

  # file: active_record/core_
  def init_with(coder)
    @attributes   = self.class.initialize_attributes(coder['attributes'])
    # 其他初始化过程 bla bla bla
    self
  end
```

可以看到，数据库里的每条记录从数据库查出来之后，会直接塞进每个对象的`@attributes`实例变量中，这里包括了所有的字段的名字和值。这个原始的记录数据是个以属性名为键，原始内容为值的哈希表。

ActiveRecord提供了接口可以直接访问原始数据，这种方式就是直接对`@attributes`进行读取。

```ruby
Post.first.attributes_before_type_cast # 读取所有原始数据
Post.first.read_attribute_before_type_cast(:id) # 读取ID字段的原始数据
Post.first.id_before_type_cast # 同上，ActiveModel::AttributeMethods生成的DSL
```

## 读取属性

通常我们不会直接访问原始数据，而是访问已经转化好的数据。ActiveRecord提供了几种形式来访问处理过属性

```ruby
post = Post.new(name: "First Post")

post.name
post[:name]
post.attributes[:name]
post.read_attribute(:name) #=> "First Post"
```

以上几种的模型属性访问其实都通过同一个入口进行访问，这个入口就是`read_attribute`。以上几个属性读取的实现有兴趣可以自行翻查源码，我们来重点讲解`read_attribute`。

`read_attribute`的基本逻辑如以下代码所示，这里是精简过的代码

```ruby
# file: active_record/attribute_methods/read.rb
def read_attribute(attr_name)
  name = attr_name.to_s
  column = @column_types[name]

  value = @attributes.fetch(name) {
    return block_given? ? yield(name) : nil
  }

  column.type_cast value
end
```

1. 查找对应对应的数据库字段(AR::ConnectionAdapters::Column)实例，即获得该属性在数据库里对应的类型
2. 从原始数据`@attributes`里查找出对应的值
3. 使用对应的字段类型来转换该属性的原始值

## 类型转换

数据库表与AR对象的映射会在对应的章节里讲解，本篇只讲解和字段读写相关的部分，以下是类型转换的实现

```ruby
def type_cast(value)
  return nil if value.nil?
  return coder.load(value) if encoded?

  klass = self.class

  case type
  when :string, :text        then value
  when :integer              then klass.value_to_integer(value)
  when :float                then value.to_f
  when :decimal              then klass.value_to_decimal(value)
  when :datetime, :timestamp then klass.string_to_time(value)
  when :time                 then klass.string_to_dummy_time(value)
  when :date                 then klass.value_to_date(value)
  when :binary               then klass.binary_to_string(value)
  when :boolean              then klass.value_to_boolean(value)
  else value
  end
end
```

我们看到除了字符串和文本之外的类型都需要根据其逻辑类型，进行转换的方法主要是解析内容并实例化到对应的类型。

写入属性的情况与读取属性的逻辑基本相同，并且Column里有一个与`type_cast_for_write`对应的`type_cast_for_write`方法，用来处理写入的类型转换。

在扩展性方面，Postgres的链接代码重写了类型转换方法以支持它丰富的数据类型。

## 自定义序列化字段

ActiveRecord支持将Ruby对象直接序列化到数据库中，并且可以制定序列化的方式，默认使用的是YAML。

```ruby
# file: active_record/attribute_methods/serialization.rb
def serialize(attr_name, class_name = Object)
  include Behavior

  coder = if [:load, :dump].all? { |x| class_name.respond_to?(x) }
            class_name
          else
            Coders::YAMLColumn.new(class_name)
          end
  self.serialized_attributes = serialized_attributes.merge(attr_name.to_s => coder)
end
```

在实现上通过Coder这种形式来在属性的读写时，调用Coder的`load`与`dump`方法进行预先处理。

这里指定的Coder并不需要特定的类型，它只需要实现接受一个参数的`load`和`dump`方法就可以作为一个Coder。

## 属性方法的动态生成

ActiveRecord模型利用Ruby的元编程能力，在运行时生成与数据库字段名相对应的读写方法。具体的方式就是使用`method_missing`和`respond_to?`，在找不到对应的方法时，ActiveRecord会在以上的两个方法里调用`define_attribute_methods`去生成**所有的属性**读写方法。

这个`define_attribute_methods`方法有两个定义，其中一个定义在ActiveRecord::AttributeMethods，另一个定义在ActiveModel::AttributeMethods模组中，其中实质性的定义是在ActiveModel中，ActiveRecord继承并在这之上加了一些线程安全和方法是否已经生成的标记。

```ruby
# file: active_model/attribute_methods
def define_attribute_methods(*attr_names)
  attr_names.flatten.each { |attr_name| define_attribute_method(attr_name) }
end
```

ActiveRecord里无需参数的定义主要作用只是代理，将所有的字段名字传入到ActiveModel里的`define_attribute_methods`。然后遍历所有的属性名，将每个属性都传入`define_attribute_method`里。`define_attribute_method`方法比较复杂，基本的思路是遍历所有的AttributeMethodMatcher，并从Matcher拼装出需要调用的方法名。

这里稍微解释一下AttributeMethodMetcher，所有模型的父类ActiveRecord::Base定义了一堆的Metcher，它用来为所有属性添加方法。除了上面的读写方法和原数据访问方法外，ActiveRecord模型还定义了如下一堆属性相关的方法

```ruby
post = Post.new title: "Nice Post"
post.title
post.title?
post.title_before_type_cast
post.title_changed?
post.title_change
post.title_will_change!
post.title_was
```

这类方法的定义就是通过Metcher，举个栗子，`{attribute}_before_type_cast`是这么定义的

```ruby
attribute_method_suffix "_before_type_cast"
#=> #<ActiveModel::AttributeMethods::ClassMethods::AttributeMethodMatcher:0x007fb36c41ddf0
#     @method_missing_target="attribute_before_type_cast",
#     @method_name="%s_before_type_cast",
#     @prefix="",
#     @regex=/^(?:)(.*)(?:_before_type_cast)$/,
#     @suffix="_before_type_cast">
```

通过这样的定义，前文提到的`define_attribute_method`的时候会调用到上面这个Matcher，然后通过`method_missing_target`调用`attribute_before_type_cast`去定义模型的`title_before_type_cast`。

同时在方法未定义的检查里也是通过遍历所有Matcher，找出是否为预定义的属性方法。

整个方法生成的故事就如是发展，在遇到未定义的方法的时候，ActiveRecord发现该方法是属性相关的方法，那么遍历所有的属性，再嵌套遍历所有的Matcher去生成所有的属性相关方法。
