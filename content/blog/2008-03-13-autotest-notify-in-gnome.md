--- 
tags: ['posts']
title: autotest in Gnome"
date: 2008-03-13
---

autotest是个方便的测试工具，ZenTest的组件之一，对Rspec支持很好。

在Peedcode的教学视频中很多时候看到作者用autotest时，测试结果会以桌面系统Notify的形式通知用户，每次看到都觉得好羡慕。其实在Gnome环境下的同学不用羡慕，因为在Gnome下也可以，把你<strong>Home目录下的.autotest</strong>文件（附件有），加入以下代码，并把附件中的图片文件放到Home下（把<strong>dot改为.</strong>）。<!--more-->

    require 'rnotify'
    require 'gtk2'

    module Autotest::RNotify
      class Notification
        attr_accessor :verbose, :image_root, :tray_icon, :notification,
                      :image_pass, :image_pending, :image_fail

        def initialize(timeout = 5000,
                       image_root = "#{ENV['HOME']}/.autotest_images" ,
                       verbose = false)
        self.verbose = verbose
        self.image_root = image_root

        puts 'Autotest Hook: loading Notify' if verbose
        Notify.init('Autotest') || raise('Failed to initialize Notify')

        puts 'Autotest Hook: initializing tray icon' if verbose
        self.tray_icon = Gtk::StatusIcon.new
        tray_icon.icon_name = 'face-monkey'
        tray_icon.tooltip = 'RSpec Autotest'

        puts 'Autotest Hook: Creating Notifier' if verbose
        self.notification = Notify::Notification.new('X', nil, nil, tray_icon)
        notification.timeout = timeout

        Thread.new { Gtk.main }
        sleep 1
        tray_icon.embedded? || raise('Failed to set up tray icon')


      def notify(icon, tray, title, message)
        notification.update(title, message, nil)
          notification.pixbuf_icon = icon
          tray_icon.tooltip = "Last Result: #{message}"
          tray_icon.icon_name = tray
          notification.show
        end

        def passed(title, message)
          self.image_pass ||= Gdk::Pixbuf.new("#{image_root}/pass.png", 48,48)
          notify(image_pass, 'face-smile', title, message)
        end

        def pending(title, message)
          self.image_pending ||= Gdk::Pixbuf.new("#{image_root}/pending.png",48,48)
          notify(image_pending, 'face-plain', title, message)
        end

        def failed(title, message)
          self.image_fail ||= Gdk::Pixbuf.new("#{image_root}/fail.png", 48,48)
          notify(image_fail, 'face-sad', title, message)
        end

        def quit
          puts 'Autotest Hook: Shutting Down...' if verbose
          #Notify.uninit
          Gtk.main_quit
        end
      end
      Autotest.add_hook :initialize do |at|
        @notify = Notification.new
      end
      Autotest.add_hook :ran_command do |at|
        results = at.results.last
        puts "the results is #{results}"
        unless results.nil?
          output = results[/(\d+)\s+example?,\s*(\d+)\s+failures?(,\s*(\d+)\s+peding)?/]
          if $~[2].to_i &gt; 0
            @notify.failed("Tests Failed", output)
          elsif $~[4].to_i &gt; 0
            @notify.pending("Tests Pending", output)
          else
            unless at.tainted
              @notify.passed("All Tests Passed", output)
            else
              @notify.passed("Tests Passed", output)
            end
          end
        end
      end

      Autotest.add_hook :quit do |at|
        @notify.quit
      end
    end


ohoh～～我们来看看效果怎样，在任意一个加入rspec on rails插件的Project下（当然是写了spec的）执行autotest：
<a href='http://redworld.blog.ubuntu.org.cn/2008/03/13/autotest-notify-in-gnome/notifypng/' rel='attachment wp-att-67' title='notify.png'><img src='http://redworld.blog.ubuntu.org.cn/files/2008/03/notify.png' alt='notify.png' /></a>

是不是很有趣呢？当然这个依赖于库ruby-gnome2，ruby-libnotify，都是用各自Linux发行班的包管理软件可以轻松得到的，比如我的arch就是，yaourt ruby-gnome2 ruby-libnotify。这个其实也可以用在unit test下，不过需要修改Autotest.add_hook :ran_command中的正则。

Ruby一个可爱的地方就是配置文件也是代码，代码还是代码。autotest的扩展性真好，这也是得益于Ruby的哲学，要修改一个类的行为就打开它，定义它，很优雅。Code is the best firend of Programmer 。

参考资料：
http://www.ikhono.net/2007/12/16/gnome-autotest-notifications

<a href='http://redworld.blog.ubuntu.org.cn/2008/03/13/autotest-notify-in-gnome/dot_autotest_imageszip/' rel='attachment wp-att-66' title='dot_autotest_images.zip'>dot_autotest_images.zip</a>
