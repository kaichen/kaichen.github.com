# (The MIT License)
# 
# Copyright © 2012-2013 Felix Ren-Chyan Chern
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the ‘Software’), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


require 'digest/md5'

GRAPHVIZ_DIR = File.expand_path('../../source/images/graphviz', __FILE__)
FileUtils.mkdir_p(GRAPHVIZ_DIR)

module Jekyll
  class GraphvizBlock < Liquid::Block

    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      non_markdown = /(&amp|&lt|&nbsp|&quot|&gt|<\/p>|<\/h.>)/m
      code = super
      # Used for debug..
      # fd = IO.sysopen "/dev/tty", "w"
      # ios = IO.new(fd,"w")
      # ios.puts code
      unless non_markdown.match(code)
        local_svg = File.join(GRAPHVIZ_DIR, "g-#{Digest::MD5.hexdigest(code)}.svg")
        web_svg = "/images/graphviz/g-#{Digest::MD5.hexdigest(code)}.svg"

        unless File.exist?(local_svg)
          puts local_svg
          puts code
          IO.popen("dot -Tsvg -o #{local_svg}", 'r+') do |pipe|
            pipe.puts(code)
            pipe.close_write
          end
        end
        "<img src='#{web_svg}'>"
      end 
    end
  end
end

Liquid::Template.register_tag('graphviz', Jekyll::GraphvizBlock)
