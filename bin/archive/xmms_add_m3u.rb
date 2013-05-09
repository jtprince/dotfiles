#!/usr/bin/ruby

require 'xmms'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} file.m3u ..."
  puts "adds the contents of the files to the current playlist"
  exit
end

remote = Xmms::Remote.new

ARGV.each do |file|
  IO.readlines(file).grep(/\w/).each do |line|
    remote.add_url line.chomp
  end
end
