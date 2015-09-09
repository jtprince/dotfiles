#!/usr/bin/env ruby

require 'terminal-table'
require 'csv'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.csv"
  puts "assumes first row is header row"
  puts "converts to pandoc grid table style"
  exit
end

csvfile = ARGV.shift

rows = CSV.read(csvfile)
rows[0][1] = rows[0][1] + "               "

table = Terminal::Table.new do |t|
  t << rows.shift
  rows.each do |row|
    t << :separator
    t << row
  end
end

lines = table.to_s.split("\n")
lines[2] = lines[2].gsub('-', '=')

puts lines.join("\n")
