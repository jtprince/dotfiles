#!/usr/bin/env ruby

require 'csv'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.tsv ..."
  puts "output: <file>.csv"
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  output = base + ".csv"
  CSV.open(output, 'w') do |csv|
    IO.foreach(file) do |line|
      csv << line.chomp.split("\t")
    end
  end
  puts "wrote: #{output}"
end
