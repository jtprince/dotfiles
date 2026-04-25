#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{$0} <file>.pdf ..."
  puts "outputs: <file>.rotated.pdf ..."
  exit
end

ARGV.each do |file|
  ext = File.extname(file)
  base = file.chomp(ext)
  cmd = "pdftk '#{file}' cat 1-endE output '#{base + ".rotated" + ext}'"
  print `#{cmd}`
end

