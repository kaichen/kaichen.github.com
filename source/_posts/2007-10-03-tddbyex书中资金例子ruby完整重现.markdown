--- 
layout: post
title: TDD by Example书中的例子Ruby版
---
早上看了<a HREF="http://www.ruby-lang.org.cn/forums/thread-1491-1-4.html">blackanger写的TDD by Ex这本书里的资金例子</a>，自己也想写一写。和他不同，我是全过程详细写出来。第一次用Ruby写代码，第一次用Ruby的Unit框架，而且下午睡醒后迷迷糊糊写的，可能有很多错误，请多多指正。

第一次迭代后的代码（简单的TDD代码）

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'dollar'
    class TestMoney &lt; Test::Unit::TestCase
      def testMultiplication
        five = Dollar.new(5)
        five.times(2)
        assert_equal(10, five.amount)
      end
    end

    # file doller.rb
    class Dollar
      def initialize(amount)
        @amount = amount
      end
      def times(multiplier)
        @amount = @amount * multiplier
      end
      def amount
        return @amount
      end
    end

第二次迭代后的代码

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'dollar'
    class TestMoney &lt; Test::Unit::TestCase
      def testMultiplication
        five = Dollar.new(5)
        product = five.times(2)
        assert_equal(10, product.amount)
        product = five.times(3)
        assert_equal(15, product.amount)
      end
    end

    # file doller.rb
    class Dollar
      attr_reader :amount
      protected :amount
      def initialize(amount)
        @amount = amount
      end

      def times(multiplier)
        return Dollar.new @amount * multiplier
      end
    end

第三，四次迭代后的代码（添加了相等性测试，刚好Ruby中的equal?和==的语意和Java相反）

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'dollar'

    class TestMoney &lt; Test::Unit::TestCase
      def testMultiplication
        five = Dollar.new(5)
        product = five.times(2)
        assert_equal(10, product.amount)
        product = five.times(3)
        assert_equal(15, product.amount)
      end
      def testEquality
        assert(Dollar.new(5) == Dollar.new(5))
        assert(Dollar.new(5) != Dollar.new(6))
      end
    end

    # file doller.rb
    class Dollar
      attr_reader :amount
      protected :amount
      def initialize(amount)
        @amount = amount
      end
      def times(multiplier)
        return Dollar.new @amount * multiplier
      end
      def ==(obj)
        return obj.amount == @amount
      end
    end

第五，六，七次迭代后的代码（短命的Franc对象登场）

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'money'
    require 'dollar'
    require 'franc'

    class TestMoney &lt; Test::Unit::TestCase
      def testMultiplication
        five = Dollar.new(5)
        assert_equal(Dollar.new(10), five.times(2))
        assert_equal(Dollar.new(15), five.times(3))
      end

      def testEquality
        assert(Dollar.new(5) == Dollar.new(5))
        assert(Dollar.new(5) != Dollar.new(6))
        assert(Franc.new(5) == Franc.new(5))
        assert(Franc.new(5) != Franc.new(6))
        assert(Franc.new(5) != Dollar.new(5))
      end

      def testFrancMultiplication
        five = Franc.new(5)
        assert_equal(Franc.new(10), five.times(2))
        assert_equal(Franc.new(15), five.times(3))
      end
    end

    # file doller.rb
    class Dollar &lt; Money
      def initialize(amount)
        super(amount)
      end
      def times(multiplier)
        return Dollar.new(@amount * multiplier)
      end
    end

    # file franc.rb
    class Franc &lt; Money
      def initialize(amount)
        super(amount)
      end
      def times(multiplier)
        return Franc.new(@amount * multiplier)
      end
    end

    # file money.rb
    class Money
      attr_reader :amount
      protected :amount
      def initialize(amount)
        @amount = amount
      end
      def ==(obj)
        return obj.amount.equal?(@amount)
      end
    end

第八，九，十，十一次迭代（消除子类，很巧妙的一步）

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'money'

    class TestMoney &lt; Test::Unit::TestCase
      def testMultiplication
        five = Money.dollar(5)
        assert_equal(Money.dollar(10), five.times(2))
        assert_equal(Money.dollar(15), five.times(3))
      end

      def testFrancMultiplication
        five = Money.franc(5)
        assert_equal(Money.franc(10), five.times(2))
        assert_equal(Money.franc(15), five.times(3))
      end

      def testEquality
        assert(Money.dollar(5) == Money.dollar(5))
        assert(Money.dollar(5) != Money.dollar(6))
        assert(Money.franc(5) != Money.dollar(5))
      end

      def testCurrency
        assert_equal("USD", Money.dollar(1).currency)
        assert_equal("CHF", Money.franc(1).currency)
      end
    end

    # file money.rb
    class Money
      attr_reader :amount, :currency
      protected :amount

      def initialize(amount, currency)
        @amount = amount
        @currency = currency
      end

      def self.dollar(amount)
        return Money.new(amount, "USD")
      end

      def self.franc(amount)
        return Money.new(amount, "CHF")
      end

      def times(multiplier)
        return Money.new(@amount*multiplier, @currency)
      end

      def plus(addend)
        return Money.new(@amount + addend.amount, currency)
      end

      def ==(obj)
        return obj.amount.equal?(@amount) &amp;&amp; (obj.currency == @currency)
      end
    end

最后的一部分
最后是完成不同货币之间的计算，引入了两个新的对象负责处理汇率的Bank和货币相加的Sum对象。

由于Ruby的动态性无须让Sum和Money实现同一接口，反正原书中的Expression对象也是为了Sum和Money对象可以通信。或许可以把Sum简化掉，有空时再想想。

    # file tc_doller.rb
    $:.unshift File.join(File.dirname(__FILE__), "..", "src")
    require 'test/unit'
    require 'money'
    require 'bank'
    require 'sum'

    class TestMoney &lt; Test::Unit::TestCase
      def testDollarMultiplication
        five = Money.dollar(5)
        assert_equal(Money.dollar(10), five.times(2))
        assert_equal(Money.dollar(15), five.times(3))
      end

      def testFrancMultiplication
        five = Money.franc(5)
        assert_equal(Money.franc(10), five.times(2))
        assert_equal(Money.franc(15), five.times(3))
      end

      def testEquality
        assert(Object.new != Money.dollar(1))
        assert(Money.dollar(5) == Money.dollar(5))
        assert(Money.dollar(5) != Money.dollar(6))
        assert(Money.franc(5) != Money.dollar(5))
      end

      def testCurrency
        assert_equal("USD", Money.dollar(1).currency)
        assert_equal("CHF", Money.franc(1).currency)
      end

      def testSimpleAddition
        five = Money.dollar(5)
        sum = five.plus(Money.dollar(5))
        bank = Bank.new()
        reduced = bank.reduce(sum, "USD")
        assert_equal(Money.dollar(10), reduced)
      end

      def testReduceSum
        sum = Sum.new(Money.dollar(3), Money.dollar(4))
        bank = Bank.new()
        result = bank.reduce(sum, "USD")
        assert_equal(Money.dollar(7), result)
      end

      def testReduceMoney
        bank = Bank.new
        result = bank.reduce(Money.dollar(1), "USD")
        assert_equal(Money.dollar(1), result)
      end

      def testReduceMoneyDiffentCurrency
        bank = Bank.new
        bank.addRate("CHF", "USD", 2)
        result = bank.reduce(Money.franc(2), "USD")
        assert_equal(Money.dollar(1), result)
      end

      def testIndentityRate
        bank = Bank.new
        bank.addRate("USD", "CHF", 0.5)
        assert_equal(1, bank.rate("USD", "USD"))
        assert_equal(0.5, bank.rate("USD", "CHF"))
        assert_equal(2, bank.rate("CHF", "USD"))
      end

      def testMixedAddition
        fiveBucks = Money.dollar(5)
        tenFrancs = Money.franc(10)
        bank = Bank.new
        bank.addRate("CHF", "USD", 2)
        result = bank.reduce(fiveBucks.plus(tenFrancs), "USD")
        assert_equal(Money.dollar(10), result)
      end

      def testSumTimes
        fiveBucks = Money.dollar(5)
        tenFrancs = Money.franc(10)
        bank = Bank.new
        bank.addRate("CHF", "USD", 2)
        sum = Sum.new(fiveBucks, tenFrancs).times(2)
        result = bank.reduce(sum, "USD")
        assert_equal(Money.dollar(20), result)
      end
    end

    # file money.rb
    class Money
      attr_reader :amount, :currency

      def initialize(amount, currency)
        @amount = amount
        @currency = currency
      end

      def self.dollar(amount)
        return Money.new(amount, "USD")
      end

      def self.franc(amount)
        return Money.new(amount, "CHF")
      end

      def times(multiplier)
        return Money.new(@amount*multiplier, @currency)
      end

      def plus(addend)
        return Sum.new(self, addend)
      end

      def ==(obj)
        return obj.amount.equal?(@amount) &amp;&amp; (obj.currency == @currency)
      end

      def reduce(bank, to)
        rate = bank.rate(@currency, to)
        return Money.new(@amount / rate, to)
      end
    end

    # file bank.rb
    class Bank
      attr_accessor :rates
      @@rates = {}

      def reduce(source, to)
        return source.reduce(self, to)
      end

      def addRate(from, to, rate)
        @@rates["#{from}-#{to}"] = rate
        @@rates["#{to}-#{from}"] = 1 / rate
      end

      def rate(from, to)
        return 1 if(from == to)
        return @@rates["#{from}-#{to}"]
      end
    end

    # file sum.rb
    class Sum
      attr_reader :augend, :addend

      def initialize(augend, addend)
        @augend = augend
        @addend = addend
      end

      def reduce(bank, to)
        amount = augend.reduce(bank, to).amount + addend.reduce(bank, to).amount
        return Money.new(amount, to)
      end

      def times(multiplier)
        return Sum.new(augend.times(multiplier), addend.times(multiplier))
      end
    end
