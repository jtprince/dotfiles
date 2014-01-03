#!/usr/bin/env ruby

require 'shellwords'

# http://ocaoimh.ie/2005/09/18/converting-raw-to-jpeg-in-linux/

# also consider the -a option...

if ARGV.size == 0
  puts "usage: #{File.basename($0)} <file>.cr2 ..."
  puts "output: <file>.jpg"
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  jpg = base + '.jpg'
  system "dcraw -c -h #{Shellwords.escape(file)} | ppmtojpeg > #{Shellwords.escape(jpg)}"
  puts "#{file} -> #{jpg}"
end
