--- 
layout: article
title: FxRuby part2
date: 2008-07-01 11:11
---
接上一篇：<a href="http://redworld.blog.ubuntu.org.cn/2008/07/01/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart1/">FxRuby初体验Part1</a>

本书的入门例子是个相册管理的桌面应用，名曰Picture Book。这个例子书中用了5 Chapter（2－6）来讲，基本讲到了常用的Gui组件。

不废话现在来看看代码，下面是第一个版本的Picture Book App：

    #photo.rb
    class Photo
      attr_reader :path
      def initialize(path)
        @path = path
      end
    end
     
    #album.rb
    class Album
      attr_reader :title
      def initialize(title)
        @title = title
        @photos = []
      end
      def add_photo(photo)
        @photos &lt;&lt; photo
      end
      def each_photo
        @photos.each { |photo| yield photo }
      end
    end
     
    #album_list.rb
    class AlbumList
      def initialize
        @albums = []
      end
     
      def add_album(album)
        @albums &lt;&lt; album
      end
      def remove_album(album)
        @albums.delete(album)
      end
      def each_album
        @albums.each { |album| yield album }
      end
    end
     
    #photo_view.rb
    class PhotoView &lt; FXImageFrame
       def initialize(p, photo)
          super(p, nil)
          load_image(photo.path)
       end
       def load_image(path)
          File.open(path, "rb" ) do |io|
            self.image = FXJPGImage.new(app, io.read)
          end
       end
    end
     
    #picturebook.rb
    require 'fox16'
    include Fox
    require 'photo'
    require 'photo_view'
    class PictureBook &lt; FXMainWindow
      def initialize(app)
        super(app, "Picture Book" , :width =&gt; 600, :height =&gt; 400)
        photo = Photo.new("shoe.jpg" )
        photo_view = PhotoView.new(self, photo)
      end
      def create
        super
        show(PLACEMENT_SCREEN)
      end
    end
    if __FILE__ == $0
      FXApp.new do |app|
        PictureBook.new(app)
        app.create
        app.run
      end
    end

这是个V0.1的版本。不过你从中看出这个应用写得很MVC。

Model部分就是Photo，Album，AlbumList三个，Controller部分（当然它还没有细化）就是PictureBook，View部分就是PhotoView。就是如此清晰的结构，我想如果是正在学着什么MFC的可怜人儿们看到了之后会把那本什么深入浅出MFC扔了吧。

对比那个HelloWorld，这堆代码除了多了几个普通的Ruby Class（扮演Model的那几个）外，就是多了一个继承自<a href="http://www.fxruby.org/doc/api/classes/Fox/FXImageFrame.html">FXImageFrame</a>的PhotoView，还有在FXMainWindow的构造方法中多了对PhotoView的实例化，实例化时将其自身挂钩到PictureBook（构造方法的第一个参数）。之后在App实例化后会实例化MainWindow，接着实例化MainWindow包含的组件，比如PhotoView这个FxImageFrame。PhotoView中对图片的包装是这样的，它先读入Photo的路径，然后用<a href="http://www.fxruby.org/doc/api/classes/Fox/FXImage.html">FxImage</a>组件对图片进行包装，然后保存为自己的一个实例变量image中。

PictureBook的第一个版本就是这样。

接着下一篇讲下个版本和下下篇讲下下个版本，然后就介绍完了。
