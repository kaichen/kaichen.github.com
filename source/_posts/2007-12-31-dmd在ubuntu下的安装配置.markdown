--- 
layout: post
title: 安装配置DMD
---
D语言是下一个主流静态语言霸主的强有力候选人。DMD是D语言的一个编译器。<!--more-->
到下面的地址下载dmd，后解压。（其中dmd/src/dmd是dmd的源码，dmd/sample/d是d语言的几个简单示例。）

<http://www.digitalmars.com/d/dcompiler.html>

* 安装配置文件，复制`dmd/bin/dmd.conf`到`/usr/local/bin`下。
* 为dmd/bin下的这几个文件添加执行权限，dmd,dumpobj,obj2asm,rdmd。
* 安装编译器，复制上面的几个文件到 /usr/local/bin
* 安装lib，复制`dmd/lib/libphobos2.a` 到 /usr/local/lib
* 安装源码，复制dmd/src/phobos到/usr/local/src
* 安装man，复制dmd/man/man1下的所有文件到/usr/local/man/man1下。

这样就OK了。

dmd.conf也可以放在/etc下不过要把lib和src的路径改为绝对路径，原文件中的路径是用%@P%来标示当前路径。

测试一下编译，没有报找不到文件就OK了。

其实D语言也是红色的。。。D语言应该是接任 Java和C#的下个静态语言王者。现在几个主流的编辑器都支持D语言，比如vim，emacs，scite。

dmd中带的几个例子中有几个是只能在windows下运行的，有点不爽。

D语言的几个资源：

* <http://www.digitalmars.com/d/index.html>
* <http://www.dnaic.com/d/doc/d/index.html>
* <http://www.dsource.org>
