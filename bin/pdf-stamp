#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <background>.pdf <file>.pdf ..."
  puts "creates a *BACKGROUND* (not stamp) of the background image"
  puts "outputs: <file>.BKG.pdf"
  exit
end

background = ARGV.shift

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  cmd = "pdftk '#{file}' background '#{background}' output #{base + '.BKG.pdf'}"
  puts "executing: #{cmd}"
  system cmd
end
