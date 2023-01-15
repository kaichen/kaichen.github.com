require "front_matter_parser"
require "yaml"
require "pstore"

# patch for class not found error
class YAML::Store < PStore
  def load(content)
    table = YAML.unsafe_load(content)
    if table == false
      {}
    else
      table
    end
  end
end

Dir["_posts/*.md"].sort.each do |file|
  puts "processing #{file}"
  parsed = FrontMatterParser::Parser.parse_file(file)
  if parsed.front_matter['date'].nil?
    date = file[/(\d{4}-\d{2}-\d{2})/, 0]
    puts "Missing date in #{file}, add #{date}"

    title = parsed.front_matter['title']
    content = File.read(file)
    content.gsub!(/^(title: .*)$/, "title: #{title}\ndate: #{date} 11:11")
    File.open(file, "w") {|file| file.puts content }
  end
end
