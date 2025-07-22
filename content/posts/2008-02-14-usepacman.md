--- 
tags: ['posts']
title: Pacman in ArchLinux
date: 2008-02-14
---

pacman是什么，就是和apt-get之于Ubuntu一样，pacman就是Arch的apt-get。
<!--more-->
熟悉一下几个pacman的几个常用命令
<code>pacman -S packagename #安装软件包
pacman -R packagename #删除软件包
pacman -Syu #升级系统中的所有包
pacman -Ss package #查询软件包
pacman -Qs package #查询已安装的包
pacman -Sw package #下载但不安装包
pacman -U /path/package.pkg.tar.gz #安装本地包
pacman -Scc #清理包缓存
pacman -Sf pacman #重新安装包</code>

其实要容易记的话可以自己在bashrc里配置一下alias就好。

再说说包下载的提速。。。
修改一下/etc/pacman.conf，把下面这句的注释去掉：

    XferCommand = /usr/bin/wget -c --passive-ftp -c %u

这样就可以使用wget来下载包。

也可以用aria2，在配置文件中加上这句：

    XferCommand = /usr/bin/aria2c -s 4 -m 2 -d / -o %o %u

-s后面是连接的服务器数量，-m是线程数。

wiki中提供了<a href="http://wiki.archlinux.org/index.php/Improve_Pacman_Performance">另一个脚本</a>，是用aria2下载的。

在wiki中还<a href="http://wiki.archlinux.org/index.php/Colored_Pacman_output">提供了几个包查询彩色输出的脚本</a>。

pacman也有GUI前端，不过我还没有见过用过，过几天回学校就会用上的。

> Java interfaces:
>
>    * jacman A nice Java-based interface.
>
> GTK2/Gnome interfaces:
>
>    * gtkpacman Pygtk gui to ArchLinux pacman. An -svn version is available as well (gtkpacman-svn).
>    * alunn Tray notifications of new updates and news from Arch front page.
>    * guzuta Yet another PyGTK frontend.
>    * pacmon-svn Tray applet that notifies the user of available pacman updates.
>
> KDE/Qt interfaces:
>
>    * pacmanager-svn Qt4 package manager based on pacman.
>    * kpacupdate Pacman update notification tool for the KDE system tray.

之后就慢慢研究一下启动加载的模块，然后在编译一下内核，Arch好好玩。。。
