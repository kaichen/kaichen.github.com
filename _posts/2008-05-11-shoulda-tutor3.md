---
layout: article
title: "[译文] Shoulda教程3 - Model Helpers"
date: 2008-05-11 11:11
---
# ActiveRecord助手方法

Shoulda具有一套ActiveRecord测试宏，这让开发效率大大提高，TDD变得轻而易举。关于这个方面的所有的文档都在Shoulda的Rdoc中。下面就来个小小的例子：

```ruby
    class UserTest
      should_has_many  :dogs
      should_belong_to :lover
    end
```

上面的代码创建了如下的测试：

```bash
test: Person should allow phone_number to be set to "(123) 456-7890".
test: Person should belong to lover.
test: Person should have many dogs.
test: Person should have many messes through dogs.
test: Person should have one profile.
test: Person should not allow admin to be changed by update.
test: Person should not allow phone_number to be set to "1234".
test: Person should not allow phone_number to be set to "abcd".
test: Person should require name to be set.
test: Person should require phone_number to be set.
test: Person should require unique value for name.
```

## 前提

一件需要知道的事情是一些ActiveRecord测试宏找到第一个初始的记录(通过 Class.find(:first))。你可以让这个工作通过一个具有一条记录的fixture文件，或者通过在setup中创建一条记录，类似下面这样：

```ruby
    class UserTest < Test::Unit::TestCase
      def setup
        @user = User.create!(params)
      end

      should_require_unique_attributes :name
    end
```

或者通过一个context，如下：

```ruby
    class UserTest < Test::Unit::TestCase
      context "given an existing record" do
        setup do
          @user = User.create!(params)
        end

        should_require_unique_attributes :name
      end
    end
```

但是Shoulda不止是提供了对模型的测试，还提供了很多强大的助手方法可以使用于控制器。
