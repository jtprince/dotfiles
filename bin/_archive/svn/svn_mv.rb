#!/usr/bin/ruby -w

if ARGV.size < 2
  puts <<END
  usage: svn_mv.rb file1 ... destination
  moves multiple files (with 'svn mv') to a destination
END
end

dest = ARGV.pop;
ARGV.each do |file|
  call = "svn mv #{file} #{dest}" 
  puts call
  system call
end
