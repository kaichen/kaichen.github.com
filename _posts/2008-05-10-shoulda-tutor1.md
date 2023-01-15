---
layout: article
title: "[译文]Shoulda教程1 - Should语法"
date: 2008-05-10 11:11
---

原文：http://thoughtbot.com/projects/shoulda/tutorial/should

# Should 语句

Should语句是一种简洁，优雅，高可读性的方式创建测试。Should语句能轻松地创建测试方法，所以完全向后兼容一般的Test::Unit 用法

```ruby
    class QuoteTest < Test::Unit::TestCase
      def setup
        # 和一般的Test::Unit一样
      end

      def test_should_be_true
        assert true
      end

      should "为真" do
        assert true
      end
    end
```

以上的代码片断创建了两个测试方法:"测试: 应该为真"和test_should_be_true。在这个级别，两个方法只有名字不同。一旦你学习有关Contexts的知识，就可以找到一些非常有用的技巧。
