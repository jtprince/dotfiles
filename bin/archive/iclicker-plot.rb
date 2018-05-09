#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'gnuplot'
require 'csv'
require 'stringio'

time_s = Time.now.strftime("%Y-%m-%d")
ext = "-#{time_s}.csv"

opt = OpenStruct.new
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <file>.csv"
  op.on("-s", "--save", "append the supplied csv file to <file>#{ext}") {|v| opt.save = v }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

file = ARGV.shift

if opt.save
  base = file.chomp(File.extname(file))
  outfile = base + ext
  File.open(outfile, 'a') do |out|
    out.puts "---"
    out.puts IO.read(file)
  end
end

rows = CSV.read(file)

letter_to_count = {
  "A" => 0,
  "B" => 0,
  "C" => 0,
  "D" => 0,
  "E" => 0,
}

rows.group_by(&:last).each do |letter, row|
  letter_to_count[letter] = row.size
end

x_position = (1..letter_to_count.size).to_a
letter = letter_to_count.keys
counts = letter_to_count.values

Gnuplot.open do |gp|

  Gnuplot::Plot.new(gp) do |plot|

    plot.boxwidth "0.95 relative"
    plot.style "fill solid 1.00 noborder"
    plot.yrange "[0:*]"
    plot.ylabel "number of votes"

    plot.data = [ 
      Gnuplot::DataSet.new( [x_position, counts, letter] ) do |ds|
        ds.with = "boxes"
        ds.notitle
        ds.using = "1:2:xticlabels(3)"
        ds.linecolor = %Q{rgb "#00FF00"}
      end
    ]
  end
end


