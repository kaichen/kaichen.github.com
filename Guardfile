# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'coffeescript', :input => '_assets', :output => 'assets'

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'sass', :input => '_assets', :output => 'assets'
