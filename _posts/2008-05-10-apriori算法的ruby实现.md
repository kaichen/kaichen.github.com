--- 
layout: article
title: Apriori算法的Ruby实现
date: 2008-05-10 11:11
---
Apriori的算法实现，上课用到了。老师从网上找了一个300多行代码的Ruby实现，太复杂了，改了一下，太麻烦，自己重写过。

下面是实现代码

    #!/usr/bin/ruby -w
    # Apriori 算法实现
     
    class Apriori
      attr_accessor :date_set, :min_sup, :lv1_item_set

      # 从指定文件中得到整个事务集
      def get_data_set(input_file)
        raise "Error: File #{input_file} does not exist" unless File.exists?(input_file)
        content = ''
        open(input_file) {|f| content = f.read}
        content.inject([]) {|set, l| set &lt;= item.size
          @lv1_item_set.each do |i1| # 第一级项集
            if (item | i1).size &gt; item.size &amp;&amp; intersection?(date, (item | i1))
              candidacy_set.push((item | i1).sort).uniq!  # 候选集生成
            end
          end
        end
        candidacy_set.sort
      end

      # 从候选集产生频繁集
      def create_frequent_item_set(candidacy_set)
        frequent_item_set = Hash.new(0)
        candidacy_set.each do |e|
          @date_set.each { |date| frequent_item_set[e] += 1 if intersection?(date, e)}
        end
        return frequent_item_set.delete_if {|k, v| v = @min_sup }
        # 输出第一级项集
        open(output_file, "w") do |f|
          @lv1_item_set.each { |e| f.puts e + " : " + @hash[e].to_s }
        end
        # 迭代生成候选集
        result = []
        until(result.empty?) do
          # ......
        end
      end
    end
