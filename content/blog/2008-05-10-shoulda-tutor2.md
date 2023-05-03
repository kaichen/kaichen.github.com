---
tags: ['posts']
title: "[译文] Shoulda教程2 - Context & Nesting"
date: 2008-05-10
---
原文：http://thoughtbot.com/projects/shoulda/tutorial/context

# 上下文

在学习了Should语句之后，Shoulda的更多基本构建代码的知识就是上下文(Context)。上下文创建一个运行should语句的类似场景的fixture。Context代码块可以包含 setup/teardown 代码块，should代码块，或者其他context代码块。下面来试试在测试中使用简单的context：

```ruby
    class QueueTest < Test::Unit::TestCase
      context "一个队列实例" do
        setup do
          @queue = Queue.new
        end

        should "响应 :push 调用" do
          assert_respond_to @queue, :push
        end
      end
    end
```

这里创建了一个名为"测试：一个队列实例可以响应:push调用"的测试方法，这很漂亮和易读。

## 嵌套

上面详尽的测试，简单测试队列的实例响应:push调用，但也提出了更多的上下文和测试。现在想看看让队列返回任何放进其中的东西。来添加一个嵌套的上下文进到其中：

```ruby
    class QueueTest &lt; Test::Unit::TestCase
      context "一个队列实例" do
        setup do
          @queue = Queue.new
        end

        should "响应 :push 调用" do
          assert_respond_to @queue, :push
        end

        context "具有一个元素" do
          setup { @queue.push(:something) }

          should "在:pop调用后返回元素" do
            assert_equal :something, @queue.pop
          end
        end
      end
    end
```

上面生成了测试方法"测试：一个队列实例应该响应:push调用"和"测试：一个队列实例具有一个元素应该在:pop调用后返回元素"。

注意一下，上下文的setup代码块是为每个should代码块运行一次的。首先@queue实例被创建出来，然后:something被放进去，接着执行assert_equal。下面用一个同样语意的测试方法虚拟地演示一下，记住下面的代码只是为了帮助理解，并不会实际的发生：

```ruby
    define_method "测试：一个队列实例有一个元素应该在:pop调用后返回元素。" do
      @queue = Queue.new
      @queue.push(:something)
      assert_equal :something, @queue.pop
    end
```

现在，如果使用一般的测试风格，就会在一个测试方法中，把一个元素放进队列中并在一个测试方法中把元素取出来，然后进行断言。但是将这个测试分离出来放到一个测试push的上下文时，就可以添加更多的共享同样setup的测试。

```ruby
    class QueueTest < Test::Unit::TestCase
      context "一个队列实例" do
        setup do
          @queue = Queue.new
        end

        should "响应 :push 调用" do
          assert_respond_to @queue, :push
        end

        context "具有一个元素" do
          setup { @queue.push(:something) }

          should "在:pop调用后返回元素" do
            assert_equal :something, @queue.pop
          end

          should "在:size调用后返回1" do
            assert_equal 1, @queue.size
          end
        end
      end
    end
```

在让测试保持可读性和防止重复代码方面，嵌套的上下文是一个强大的工具。测试文件变得更大时，更多的这种重构就会起作用。

## 在setup中断言

另一个美妙的setup代码块的特性是，可以运行一部分测试方法，也就是可以完美地把断言放在其中。在setup代码块中调用断言来代替在should代码块中断言，并不是一个非常好的做法，但是可以起到一个明确的检查作用。来个例子：

```ruby
    class PersonTest < Test::Unit::TestCase
      context "A Person" do
        setup { assert @person = Person.find(:first) }

        should "rock out" do
          assert @person.rocks_out!
        end
      end
    end
```

在find调用失败时，在setup中看到失败的断言比出现烦人的异常要好看多了。

should代码块和上下文是为测试宏(test macros)不错的起点。Shoulda还有一个ActiveRecord助手方法集合，让测试简明扼要。