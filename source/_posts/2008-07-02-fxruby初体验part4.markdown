---
layout: post
title: FxRuby Part4
---
之前的：FxRuby初体验<a href="http://redworld.blog.ubuntu.org.cn/2008/07/01/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart1/">Part1</a>，<a href="http://redworld.blog.ubuntu.org.cn/2008/07/01/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart2/">Part2</a>，<a href="http://redworld.blog.ubuntu.org.cn/2008/07/02/fxruby%e5%88%9d%e4%bd%93%e9%aa%8cpart3/">Part3</a>。

到了PictureBook的V0.4了。这个版本算是基本的功能都做足了，包括了加上了相册选择，相册持久化等等。

    #album_list_view.rb
    require 'fox16'

    include Fox

    class AlbumListView &lt; FXList
      attr_reader :album_list
      def initialize(p, opts)
        super(p, :opts =&gt; opts)
      end
      def switcher=(sw)
        @switcher = sw
      end

      def add_album(album)
        appendItem(album.title)
        AlbumView.new(@switcher, album)
      end

      def album_list=(albums)
        @album_list = albums
        @album_list.each_album do |album|
          add_album(album)
        end
      end
    end

    #picture_book.rb
    $KCODE = "U"
    require 'fox16'
    require 'yaml'

    include Fox

    require 'album'
    require 'album_list'
    require 'photo'
    require 'photo_view'
    require 'album_view'
    require 'album_list_view'

    class PictureBook &lt; FXMainWindow
      def initialize(app)
        super(app, "Picture Book" , :width =&gt; 600, :height =&gt; 400)
        add_menu_bar
        begin
          @album_list = YAML.load_file("picturebook.yml" )
        rescue
          @album_list = AlbumList.new
          @album_list.add_album(Album.new("My Photos" ))
        end
        splitter = FXSplitter.new(self,
          :opts =&gt; SPLITTER_HORIZONTAL|LAYOUT_FILL)
        @album_list_view = AlbumListView.new(splitter, LAYOUT_FILL)
        @switcher = FXSwitcher.new(splitter, :opts =&gt; LAYOUT_FILL)
        @switcher.connect(SEL_UPDATE) do
          @switcher.current = @album_list_view.currentItem
        end
        @album_list_view.switcher = @switcher
        @album_list_view.album_list = @album_list
      end


      def create
        super
        show(PLACEMENT_SCREEN)
      end

        def add_menu_bar
          # 创建一个菜单栏的实例
          menu_bar = FXMenuBar.new(self, LAYOUT_SIDE_TOP|LAYOUT_FILL_X)
          # 创建一个菜单栏项
          file_menu = FXMenuPane.new(self)
          FXMenuTitle.new(menu_bar, "文件" , :popupMenu =&gt; file_menu)
          # 下面是一个创建菜单栏项和所关联动作的绑定
          import_cmd = FXMenuCommand.new(file_menu, "导入..." )
          import_cmd.connect(SEL_COMMAND) do
            dialog = FXFileDialog.new(self, "导入图片" )
            dialog.selectMode = SELECTFILE_MULTIPLE
            dialog.patternList = ["JPEG Images (*.jpg, *.jpeg)" ]
            if dialog.execute != 0
              import_photos(dialog.filenames)
            end
          end
          new_album_command = FXMenuCommand.new(file_menu, "New Album..." )
          new_album_command.connect(SEL_COMMAND) do
            album_title = FXInputDialog.getString("My Album" , self, "New Album" , "Name:" )
            if album_title
              album = Album.new(album_title)
              @album_list.add_album(album)
              @album_list_view.add_album(album)
              AlbumView.new(@switcher, album)
            end
          end
         exit_cmd = FXMenuCommand.new(file_menu, "退出" )# 一个简单的退出项
         exit_cmd.connect(SEL_COMMAND) do
          store_album_list
          exit
        end
      end

      def import_photos(filenames)
        filenames.each do |filename|
          photo = Photo.new(filename)
          current_album.add_photo(photo)
          current_album_view.add_photo(photo)
        end
        current_album_view.create
      end

      def current_album_view
        @switcher.childAtIndex(@switcher.current)
      end

      def current_album
        current_album_view.album
      end

      def store_album_list
        File.open("picturebook.yml" , "w" ) do |io|
          io.write(YAML.dump(@album_list))
        end
      end

    end

    if __FILE__ == $0
      FXApp.new do |app|
        PictureBook.new(app)
        app.create
        app.run
      end
    end

剩下的晚上再写。。。
