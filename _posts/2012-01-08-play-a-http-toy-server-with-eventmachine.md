---
layout: post
title: Play a HTTP toy server with EventMachine
---
![EventMachine](http://www.faconneurs.enligne-fr.com/__/logos_clients/event_machine.JPG)

[EventMachine](https://github.com/eventmachine/eventmachine/wiki)是Ruby社区的[Reactor模式](http://en.wikipedia.org/wiki/Reactor_pattern)的实现。

所谓`Reactor`模式，通过运行一个事件循环，将输入分发给对应的处理器，处理过程全权交给处理器，从而实现同时处理多个输入，是实现高并发的利器。几乎每个语言都有对应的实现，比如Pythong的[Twisted](http://twistedmatrix.com/trac/)，最近很火的[Node.js](nodejs.org/)。

这次我们通过实现一个简单的HTTP File server来探索EventMachine。

<!-- more -->

通过Rubygems可以安装它：

{% highlight sh %}
$ gem install eventmachine
{% endhighlight %}

### Beginning Sample

我们先从一个简单的例子入手，以下代码实现了这样的一个服务器，打印发过来数据，并返回`Yike`。

{% highlight ruby %}
require 'eventmachine'

module TcpSample
  def receive_data(data)
    puts "[#{Time.now}] receive #{data}"
    send_data "Yike\n"
  end
end

EM.run do
  %w{INT TERM}.each{ |s| Signal.trap s, &proc{EM.stop_event_loop} }
  port = ENV["PORT"] || 8001
  host = ENV["HOST"] || "127.0.0.1"
  EM.start_server host, port, TcpSample
  puts "Server start on #{host}:#{port}"
end
{% endhighlight %}

来解释几个EventMachine的API：

* [EM.run](http://eventmachine.rubyforge.org/EventMachine.html#M000461) 这个方法初始化并启动一个事件循环。
* [EM.stop_event_loop](http://eventmachine.rubyforge.org/EventMachine.html#M000469) 这个方法顾名思义就是停止事件循环。在这段代码中我们注册了两个Signal，INT和TERM，用来在命令行用Ctrl-C停止程序。
* [EM.start_server](http://eventmachine.rubyforge.org/EventMachine.html#M000470) 启动一个TCP服务器并监听传入参数的host和port，最后一个传入的参数是具体的行为逻辑实现，可以是Module或者是Class。

代码中TcpSample module就是具体的Connection逻辑实现，只要实现几个由EventMachine Connection约定的方法，比如收发数据的`receive_data`和`send_data`。EventMachine会在运行过程事件被触发时回调Connection里的方法。具体关于EventMachine::Connection的文档请点击[这里](http://eventmachine.rubyforge.org/EventMachine/Connection.html)。

我们可以用telnet来测试它：

{% highlight sh %}
$ telnet 127.0.0.1 8001
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
hey
Yike
{% endhighlight %}

第一个简单的例子就这样演示完成了，继续下一步。

### Toy File Server

接着步入正题，实现HTTP File Server。一句话来解释HTTP服务器做的事情，就是解析来自客户的Request，然后依照请求生成Response。这里的演示代码如题目所示，只是个Toy，按照请求返回静态文件。

首先需要接受并解析Request。EventMachine已经附带了[好几种Protocol的解析](http://eventmachine.rubyforge.org/EventMachine/Protocols.html)，其中包括实现了HTTP的[HeaderAndContentProtocol](http://eventmachine.rubyforge.org/EventMachine/Protocols/HeaderAndContentProtocol.html)。注意这里的各种Protocol实现都是继承第一个例子中讲到EventMachine::Connection，并为各自的协议包装了一个`receive_xxx`的回调方法，HeaderAndContentProtocol的回调方法名为`receive_request`。我们的HTTP Toy要做的就是继承`HeaderAndContentProtocol`，在`receive_request`方法中实现File Server的逻辑。

{% highlight sh %}
class HTTPToy < EM::P::HeaderAndContentProtocol
  def receive_request headers, content
    #TODO ...
  end
end
{% endhighlight %}

先来完成HTTP Headers的解析：

{% highlight sh %}
REGEX = /\A(?<request_method>\w+) (?<full_path>\S+) HTTP\/(?<version>[\d.]+)\Z/
def parse_request(data)
  {}.tap do |req|
    matched = REGEX.match(headers.shift)
    req["request_method"] = matched[:request_method]
    req["full_path"] = matched[:full_path]
    req["http_version"] = matched[:version]
  end
end
{% endhighlight %}

接着实现Callback方法`receive_request`，主要的逻辑是查找文件和拼装Response并返回：

{% highlight sh %}
def receive_request headers, content
  @request = parse_headers(headers)
  filename = "." + @request["full_path"]
  if @request["full_path"] == "/"
    filename = "./index.html"
  end
  if File.exists?(filename) && File.file?(filename)
    serve_file filename
  else
    respond_not_found
  end
ensure
  close_connection_after_writing
end

def serve_file(filename)
  extname = File.extname(filename)
  send_headers "Content-Type" => {
                 "html" => "text/html",
                 "js" => "application/x-javascript",
                 "css" => "text/css"
               }(extname)
  send_data File.read(filename)
end

def send_headers(more = {})
  request["status"] = more.delete('status') || "200 OK"
  headers = "HTTP/1.1 #{request['status']}\r\n"
  more = {
    # the magic string "+8000" means my life is at HARD MODE
    "Date" => Time.now.strftime("%a, %d %b %Y %H:%m:%S +8000"),
    "Server" => "my-http-toy"
  }.merge(more)
  if more.any?
    more.each{ |k, v| headers << "#{k}: #{v}\r\n" }
  end
  send_data headers + "\r\n"
end
{% endhighlight %}

以上代码的`close_connection_after_writing`方法也是EventMachine的API之一，文档在[这里](http://eventmachine.rubyforge.org/EventMachine/Connection.html#M000286)。这个方法会等待`send_data`的完成再把与客户端之间的连接关闭。上述大段代码的作用就是读文件并用`send_data`返回。

把它跑起来并通过浏览器可以测试一下它：

![screenshot](http://dl.dropbox.com/u/1080383/screenshot-my-http-toy.png)

查看完整的实现代码请点击[这里](http://gist.github.com/1580890)。

### Benchmark

最后来对比异步IO和同步的IO效率相差有多大，和本文实现的简单http file server对比的是Rack。用Rack来做对比是因为它几乎是最小最快的HTTP File server实现。代码如下：

{% highlight sh %}
# file: config.ru
run Rack::File.new(Dir.pwd)
{% endhighlight %}

压力测试用的是[HTTPerf](http://www.hpl.hp.com/research/linux/httperf/)，作为测试Fixture的是一个名为index.html的小文件（47B）。

Rack的File middleware在并发超过350的情况就歇菜了：

{% highlight sh %}
$ rackup ./config.ru -p 8002
$ httperf --rate=350 --timeout=5 --num-conns=350 --port=8002 --uri=/index.html

Total: connections 350 requests 350 replies 347 test-duration 1.978 s

Connection rate: 177.0 conn/s (5.7 ms/conn, <=26 concurrent connections)
Connection time [ms]: min 2.1 avg 68.5 max 1272.6 median 13.5 stddev 245.5
Connection time [ms]: connect 63.6
Connection length [replies/conn]: 1.000

Request rate: 177.0 req/s (5.7 ms/req)
Request size [B]: 72.0
{% endhighlight %}

350个并发的请求用了接近2秒的时间，速度是177个连接每秒。接着再来测试我们的HTTPToy：

{% highlight sh %}
$ ruby ./httptoy.rb 8001
$ httperf --rate=600 --timeout=5 --num-conns=600 --port=8001 --uri=/index.html

Total: connections 600 requests 600 replies 600 test-duration 1.000 s

Connection rate: 600.1 conn/s (1.7 ms/conn, <=17 concurrent connections)
Connection time [ms]: min 0.4 avg 2.8 max 25.9 median 0.5 stddev 3.9
Connection time [ms]: connect 0.2
Connection length [replies/conn]: 1.000

Request rate: 600.1 req/s (1.7 ms/req)
Request size [B]: 72.0
{% endhighlight %}

**完胜**，和前面的差距不是一星半点，一秒内响应600个连接。如果继续提高并发数，到了700以上我们的HTTPToy也会出现不稳定的情况（崩溃或连接失败）。

### Conclusion

EventMachine应用的场景和Node.js基本一样，IO密集的高并发场景，比如

* Web Socket服务端，https://github.com/igrigorik/em-websocket
* 并发的HTTP Client，https://github.com/igrigorik/em-http-request
* Proxy，https://github.com/igrigorik/em-proxy

在生产环境中大量使用EventMachine公司就是[PostRank](www.postrank.com/)，这个公司基于EventMachine开发了大量的框架和库，有兴趣可以点击[igrigorik](https://github.com/igrigorik)和[postrank-labs](https://github.com/postrank-labs)的Github帐号。

最后谈下EventMachine缺点，和其它的Reactor模式实现一样，对付CPU密集的应用不行，而且使用的库全部都必须是异步，不然会把Main Event Loop阻塞（其后果是处理速度大大降低）。而像Node.js程序里出现了大量Callback的情况，在EventMachine上会好一点。

本文中的运行环境是Mac OSX Lion，Ruby 1.9.3-p0。
