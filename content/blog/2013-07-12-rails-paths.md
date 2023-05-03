---
title: "Rails Paths"
date: 2013-07-12
comments: true
tags: ["Ruby on Rails", "Ruby"]
category: "inspect-rails"
---

前面的章节提到Rails Engine实现了Rails中著名的[Convention over Configuration][1]，其目的就在于统一有序地组织各种方面的代码。


> 本文是[Inspect Rails](/inspect-rails)的一部分，[Inspect Rails](/inspect-rails)是由我正在编写的讲解Rails内部实现与设计的一本书，欢迎阅读

而这个事情主要关心的就是加载路径，也就是让Rails能在对应的路径下找到相应的代码。Rails Engine对目录的配置代码主要如下：

```ruby
# railties/lib/rails/engine/configuration.rb
paths = Rails::Paths::Root.new(@root)
  paths.add "app",                 eager_load: true, glob: "*"
  paths.add "app/assets",          glob: "*"
  paths.add "app/controllers",     eager_load: true
  paths.add "app/helpers",         eager_load: true
  paths.add "app/models",          eager_load: true
  paths.add "app/mailers",         eager_load: true
  paths.add "app/views"
  paths.add "app/controllers/concerns", eager_load: true
  paths.add "app/models/concerns",      eager_load: true
  paths.add "lib",                 load_path: true
  paths.add "lib/assets",          glob: "*"
  paths.add "lib/tasks",           glob: "**/*.rake"
  paths.add "config"
  paths.add "config/environments", glob: "#{Rails.env}.rb"
  paths.add "config/initializers", glob: "**/*.rb"
  paths.add "config/locales",      glob: "*.{rb,yml}"
  paths.add "config/routes.rb"
  paths.add "db"
  paths.add "db/migrate"
  paths.add "db/seeds.rb"
  paths.add "vendor",              load_path: true
  paths.add "vendor/assets",       glob: "*"
paths
```

Rails Application的`paths`是这样的:

```ruby
# railties/lib/rails/application/configuration.rb
@paths ||= begin
  paths = super
  paths.add "config/database",    with: "config/database.yml"
  paths.add "config/environment", with: "config/environment.rb"
  paths.add "lib/templates"
  paths.add "log",                with: "log/#{Rails.env}.log"
  paths.add "public"
  paths.add "public/javascripts"
  paths.add "public/stylesheets"
  paths.add "tmp"
  paths
end
```

## 根目录

目录结构配置是在Rails Engine定义的，这里最终得到的paths是每个Engine的根目录，而`Rails.root`是来自最顶层的Rails Application的根目录。这里Rails对根目录的判断，在Engine和Application的不一样，Application是通过检查存在`config.ru`文件的目录，而Engine只是查找存在`lib`目录的目录。

## 路径集合

在上面的配置代码里的`paths.add`会做两件事情，一是将传进来的字符串定义为**一组路径**，二是将对应的字符串作为这组路径的默认目录。这个Paths里的每一项。比如，在配置完成之后`paths["app/models"]`可以将这组路径里的所有目录都取回来。

也就是说每一组路径都是一个集合，而有些特殊的路径里只有一个文件，比如`paths["config/database"]`。在Rails内部在查找对应目录或文件的时候，都是通过这个`paths`去查找，而不是硬编码相对目录位置。

另外可以看到`paths.add`方法除了目录之外，还会接受一些选项

- eager_load: 是否使用预加载
- glob: 目录内的文件查找通配符
- with: 指定为唯一的文件
- load_path: 作为`require`或`load`时候可以查找到的路径

在了解完目录与加载的事实之后，你会知道Rails其实并不能控制你把Model放到`app/controllers`或其他地方下，它处理的只是把某些目录设置为查找代码的加载路径。

[0]: https://github.com/rails/rails/blob/4-0-stable/activesupport/lib/active_support/dependencies.rb
[1]: http://en.wikipedia.org/wiki/Convention_over_configuration
