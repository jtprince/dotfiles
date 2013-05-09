#!/usr/bin/env ruby

begin
  require 'rdiscount'
rescue LoadError
  error_msg
  abort 'You need to install rdiscount to use this guy!' if error_msg
end

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mkd ..."
  puts "outputs <file>.html"
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  system "rdiscount '#{file}' > #{base + '.html'}"
end
