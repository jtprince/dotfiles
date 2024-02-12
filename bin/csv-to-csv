#!/usr/bin/env ruby

require 'shellwords'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.csv ..."
  puts "output: <file>.csv"
  puts
  puts "The transformation cleans up lots of crappy csv."
  exit
end

ARGV.each do |filename|
  system "libreoffice --headless --infilter=CSV:44,34,76,1 --convert-to csv #{Shellwords.escape(filename)}"
end
