#!/usr/bin/env ruby

require 'optparse'

opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <branch>"
  op.separator "(expects you to be in your top git directory)"
  op.separator ""
  op.separator "options:"
  op.on("-r", "--read-only", "just reads the remote branches and exits") do
    puts `git branch -r`
    exit
  end
end

if ARGV.size == 0
  puts opts
  exit
end

branch = ARGV.shift

puts `git fetch`
puts `git checkout --track -b #{branch} origin/#{branch}`
