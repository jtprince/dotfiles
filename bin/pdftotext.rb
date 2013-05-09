#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.pdf ..."
  puts "output: <file>.txt ..."
  puts 
  puts "uses pdftotext and passes all options to it"
  puts "-layout is a great option to use"
end

(opts, args) = ARGV.partition {|arg| arg =~ /^\-/ }

args.each do |file|
  system "pdftotext", *opts, file
end
