#!/usr/bin/env ruby

if(ARGV.size != 3) then
  puts "Usage: #{$0} <glob> <regex> <new_string>"
  exit 1
end

glob_path, exp_search, exp_replace = ARGV[0], ARGV[1], ARGV[2]
Dir.glob(glob_path).each do |file|
  buffer = File.new(file,'r').read.gsub(/#{exp_search}/,exp_replace)
  File.open(file,'w') {|fw| fw.write(buffer)}
end
