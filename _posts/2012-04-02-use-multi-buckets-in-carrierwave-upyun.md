---
layout: post
title: 在carrierwave-upyun中配置多个不同的buckets
---

# 背景

[carrierwave](https://github.com/jnicklas/carrierwave/)是RubyOnRails社区中比较
流行的文件上传插件，[carrierwave-upyun](https://github.com/nowa/carrierwave-upyun)
是集成[upyun](https://github.com/nowa/carrierwave-upyun)服务的插件。

# 把不同类型的文件存放到upyun不同的bucket上

使用upyun时有个常见的需求就是把不同类型的图片分开放到不同的bucket当中，但在
carreirwave-upyun的文档当中并没有提到这点，只是给出了怎么配置全局参数的例子：

{% highlight ruby %}
CarrierWave.configure do |config|
  config.storage = :upyun
  config.upyun_username = "xxxxxx"
  config.upyun_password = 'xxxxxx'
  config.upyun_bucket = "my_bucket"
  config.upyun_bucket_domain = "my_bucket.files.example.com"
end
{% endhighlight %}

# 解决

而实际上，可以这么去做：

{% highlight ruby %}
class CoverUploader < CarrierWave::Uploader::Base
  storage :upyun
  self.upyun_bucket = "my-covers"
end
class AttachementUploader < CarrierWave::Uploader::Base
  storage :upyun
  self.upyun_bucket = "my-attachements"
end
{% endhighlight %}

这样简单地在Uploader里assign一下就可以解决问题。

# 为什么以上的解决方法行得通？

Carreirwave的各种Configuration都是通过这里的`add_config`方法加入的。代码可以看以下的链接

[https://github.com/jnicklas/carrierwave/blob/master/lib/carrierwave/uploader/configuration.rb#L75-L94](https://github.com/jnicklas/carrierwave/blob/master/lib/carrierwave/uploader/configuration.rb#L75-L94)

`add_config`为每个Uploader实例添加了直接访问Class variable的方法，Uploader中
的各种Configuration 项（比如这里的`upyun_bucket`）都是存储在Uploader的Class
中。

而所有默认的Configuration项都是存储在`CarrierWave::Uploader::Base`，所以在我们
自定义的Uploader可以通过`add_config`为我们加入的[`self.#{config_item}=`](https://github.com/jnicklas/carrierwave/blob/master/lib/carrierwave/uploader/configuration.rb#L98-L92)
去修改Configuration项。

也就是说Carrierwave一早就实现了这样的机制让不同的Uploader天生可以具有配置能力。
