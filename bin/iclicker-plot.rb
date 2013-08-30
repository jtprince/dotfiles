#!/usr/bin/env ruby

require 'gnuplot'
require 'csv'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.csv"
  exit
end

file = ARGV.shift
rows = CSV.read(file)

letter_to_count = {}
rows.group_by(&:last).each do |letter, row|
  letter_to_count[letter] = row.size
end

i = (1..letter_to_count.size).to_a
x = letter_to_count.keys
y = letter_to_count.values

Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.data = [ 
      Gnuplot::DataSet.new( [i, x,y] ) do |ds|
        ds.with = "boxes"
      end
    ]
  end
end


