#!/usr/bin/env ruby

require 'csv'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.csv ..."
  puts "output: <file>.tsv"
  puts "doesn't escape tabs or anything fancy for the tsv side"
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  output = base + ".tsv"
  File.open(output,'w') do |out|
    CSV.open(file) do |csv|
      csv.each do |row|
        out.puts row.join("\t")
      end
    end
  end
  puts "wrote: #{output}"
end
