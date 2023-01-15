---
layout: article
title: Shoulda教程索引
date: 2008-05-18 11:11
---
终于把这个框架的文档翻译完了。最后一篇的缩进真是搞死我了，如果wp的编辑器更加强些就好了。

* [Shoulda教程之一—基本的should语句](/2008/05/10/shoulda-tutor1)
* [Shoulda教程之二—上下文](/2008/05/10/shoulda-tutor2)
* [Shoulda教程之三—测试ActiveRecord模型](2008/05/11/shoulda-tutor3)
* [Shoulda教程之四—测试控制器](/2008/05/18/shoulda-tutor4)

其实看到Shoulda这个框架之后我会有很多思考，思考之前的BDD或TDD是不是太麻烦了，比如每次Fun Test都是要些mock Model，然后才能测试每次每次都是在重复，而每次页面的测试（Rspec里才有分离出来的测试）每次都要先构造出页面中要调用的对象，再assigns页面要调用到的元素之后再测试。整个过程非常繁琐，虽然这样可以很细粒度地测试到整个应用，但一点也不DRY（或许我的水平还不够）。

再抱怨一点，很多有名的Rails开源应用（如Beast，Redmind，Typo等等）很多都还未迁移到Rspec，虽然他们的项目目录中很多都有了spec这个目录，可是一般都是空的。想看到的Rspec的用于集成测试的Stroy框架的实例也没有，这个只能在教程中看到。Rspec的教程也太少，Rdoc中基本没有什么解释，代码里也是，如果对一些东西不知道怎么用就要去看代码，有些代码只是包装了Rails中的assist方法的还要去查Rails的方法代码（如果对Rails的一些assist不熟的话）。虽然这个过程可以看很多代码，学到更多，可是也太费时间了。

最后如果能把Shoulda的一些强大的宏移植到Rspec那就好了。当然，我会继续研究Shoulda源码，还要下一步要看看merb。

翻译完最后生成PDF在这里可以下载：http://download.csdn.net/source/458857
