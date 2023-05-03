--- 
tags: ['posts']
title: FxRuby Part3
date: 2008-07-02
---
之前的：FxRuby初体验<a href="http://redworld.blog.ubuntu.org.cn/2008/07/01/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart1/">Part1</a>，<a href="http://redworld.blog.ubuntu.org.cn/2008/07/01/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart2/">Part2</a>。

这个V0.3的PictureBook添加了相册视图，也就是把相片都放到其中。看看下面的代码吧，我把每次都贴上完整的代码，方便大家复制粘帖:-)

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
      MAX_WIDTH = 200
      MAX_HEIGHT = 200
      def initialize(p, photo)
        super(p, nil)
        load_image(photo.path)
      end
      def load_image(path)
        File.open(path, "rb" ) do |io|
          self.image = FXJPGImage.new(app, io.read)
          scale_to_thumbnail
        end
      end
      def scaled_width(width)
        [width, MAX_WIDTH].min
      end
      def scaled_height(height)
        [height, MAX_HEIGHT].min
      end
      def scale_to_thumbnail
        aspect_ratio = image.width.to_f/image.height
        if image.width &gt; image.height
          image.scale(
            scaled_width(image.width),
            scaled_width(image.width)/aspect_ratio,
            1
          )
        else
          image.scale(
            aspect_ratio*scaled_height(image.height),
            scaled_height(image.height),
            1
          )
        end
      end
    end
      
    #album_view.rb
    require 'photo_view'
    class AlbumView &lt; FXMatrix
      attr_reader :album
      def initialize(p, album)
        super(p, :opts =&gt; LAYOUT_FILL|MATRIX_BY_COLUMNS)
        @album = album
        @album.each_photo { |photo| add_photo(photo) }
      end
      def add_photo(photo)
        PhotoView.new(self, photo)
      end
      def layout
        self.numColumns = [width/PhotoView::MAX_WIDTH, 1].max
        super
      end
    end
      
    #picture_book.rb
    require 'fox16'
    include Fox
    require 'album'
    require 'album_view'
    require 'photo'
    class PictureBook &lt; FXMainWindow
      def initialize(app)
        super(app, "Picture Book" , :width =&gt; 600, :height =&gt; 400)
        add_menu_bar
        @album = Album.new("My Photos" )
        @album_view = AlbumView.new(self, @album)
      end
      def add_menu_bar
        menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
        file_menu = FXMenuPane.new(self)
        FXMenuTitle.new(menu_bar, "File" , :popupMenu =&gt; file_menu)
        import_cmd = FXMenuCommand.new(file_menu, "Import..." )
        import_cmd.connect(SEL_COMMAND) do
          dialog = FXFileDialog.new(self, "Import Photos" )
          dialog.selectMode = SELECTFILE_MULTIPLE
          dialog.patternList = ["JPEG Images (*.jpg, *.jpeg)" ]
          if dialog.execute != 0
            import_photos(dialog.filenames)
          end
        end
        exit_cmd = FXMenuCommand.new(file_menu, "Exit" )
        exit_cmd.connect(SEL_COMMAND) do
          exit
        end
      end
      def import_photos(filenames)
        filenames.each do |filename|
          photo = Photo.new(filename)
          @album.add_photo(photo)
          @album_view.add_photo(photo)
        end
        @album_view.create
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

这里相对于上个版本的改动的地方有，PictureBook增加了菜单栏，增加了一个视图AlbumView，PhotoView实例的创建放在了AlbumView中，PhotoView中增加了图片的缩略图操作。

菜单栏的创建也听挺麻烦的，先创建<a href="http://www.fxruby.org/doc/api/classes/Fox/FXMenuBar.html">FXMenuBar的</a>实例，然后是创建<a href="http://www.fxruby.org/doc/api/classes/Fox/FXMenuTitle.html">FXMenuTitle</a>和<a href="http://www.fxruby.org/doc/api/classes/Fox/FXMenuPane.html">FXMenuPane</a>的实例，FXMenuTitle是FXMenuBar的下级元素，就是菜单栏的每一段，FXMenuPane是FXMenuTitle的弹出菜单。然后要创建<a href="http://www.fxruby.org/doc/api/classes/Fox/FXCommand.html">FXMenuCommand</a>，它是FXMenuPane的下级元素，实例化后就要用connect方法给出的代码块将其绑定到一定的行为上。

File&gt;Importd这个动作是打开一个文件对话框<a href="http://www.fxruby.org/doc/api/classes/Fox/FXDialogBox.html">FXFileDialog</a>让你选择文件，然后用filenames方法获得选择得到的文件的数组。退出的菜单项很简单，就是一个exit方法。

在PhotoView中的图片操作功能是从FXImageFrame继承得到的，这个能力和接口很像RMagic。 AlbumView 是<a href="http://www.fxruby.org/doc/api/classes/Fox/FXMatrix.html">FXMatrix</a>的实例，FXMatrix是一种布局管理器，它以行列的方式来对组件进行布局。好像布局管理器的基类就是<a href="http://www.fxruby.org/doc/api/classes/Fox/FXPacker.html">FXPacker </a>，可以通过重写它的Layout方法来改变布局流。像这里就改变了FXMatrix的行数。

接着书中作者又改了一下，因为FXMatrix不能够在图片太多的情况下全部显示，会产生因为图片过多导致产生很多行，然后让超出主窗体的图片行无法看见，所以作者又对AlbumView换了一个布局管理器。

    #album_view.rb
    require 'photo_view'
    class AlbumView &lt; FXScrollWindow
      attr_reader :album
      def initialize(p, album)
        super(p, :opts =&gt; LAYOUT_FILL)
        @album = album
        FXMatrix.new(self, :opts =&gt; LAYOUT_FILL|MATRIX_BY_COLUMNS)
        @album.each_photo { |photo| add_photo(photo) }
      end
      def layout
        contentWindow.numColumns = [width/PhotoView::MAX_WIDTH, 1].max
        super
      end
      def add_photo(photo)
        PhotoView.new(contentWindow, photo)
      end
    end

<a href="http://www.fxruby.org/doc/api/classes/Fox/FXScrollWindow.html">FXScrollWindow</a>是另一种布局管理器，它只是多了滚动条。其中还是包含了一个FXMatrix。
