#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} branch"
  exit
end

branch_name = ARGV.shift

cmd = "git branch --track #{branch_name} origin/#{branch_name}"
puts cmd
system cmd
cmd = "git co #{branch_name}"
puts cmd
system cmd
