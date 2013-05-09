#!/usr/bin/env ruby

require 'tempfile'
require 'fileutils'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} *.svg"
  puts "rewrites files to be correct!"
  exit
end

ARGV.each do |file|
  tmp = Tempfile.new(File.basename(file))
  string = IO.read(file)
  tmp.print string.gsub(/(color:)(.*?)(;\s* stroke:)currentColor/) { $1+$2+$3+$2 }
  tmp.close
  FileUtils.cp tmp.path, file
end
