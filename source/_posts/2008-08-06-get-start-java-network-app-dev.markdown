--- 
layout: post
title: Get Start Java Network App Dev
---
如果你要开发一个Java的network app，有很多不错的opensource project帮助你开始开发。

比较基础和底层的话可以试试HttpClient，<a href="http://hc.apache.org">hc.apache.org</a>，按照它官方的教程，六步走。这个框架提供了Http访问的能力，加上Java的multithread能力，虽然效率不及noblocking io那么高但胜在文档资料多。这个一个初学者的好起点。

高级点的就是mina，<a href="http://mina.apache.org">mina.apache.org</a>，一个高性能高扩展能力的network app框架。基于Java的nio，并发能力得以保证，并在比较高层次进行封装。不过这个东西文档不多是弱点。值得一提的是Logo，so Cool。

当你的network app需要大量的数据处理时，使用hadoop是个不错解决方案，<a href="http://hadoop.apache.org">hadoop.apache.org/</a>。这个MapReduce实现，非常著名，不用我废话了:P Hbase是Hadoop的一个子项目，是Bigtable的实现。Hbase有Ruby的客户端，Hbase-ruby。

另hypertable也是一个值得注意的Bigtable实现，<a href="http://www.hypertable.org/">hypertable.org</a>。

现在的Network app常常需要有搜索功能，这时就需要Lunece，Solr，Nutch啦。Lunece也是不用介绍的。Solr很多人也熟悉，一个企业级搜索服务器，是Lunece的的扩展，提供了web管理界面等。Netch，一个通用型的Web搜索引擎，其实就一大Crawler，他的存储基于hadoop，原dadoop是其子项目。

以上的项目好像基本上都是Apache的Project，现在的Apache项目都有Wiki了，以前貌似没有，进步了。

这就是我最近开发Crawler遇到的几个Java Framework。
