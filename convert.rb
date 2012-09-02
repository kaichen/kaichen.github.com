#!/usr/bin/env ruby

require "uri"
require "fileutils"

Dir.chdir("_posts") do
  Dir.foreach(".") do |f|
    next unless f.include?("%")

    FileUtils.mv File.join(Dir.pwd, f), File.join(Dir.pwd, URI.decode(f))
  end
end
