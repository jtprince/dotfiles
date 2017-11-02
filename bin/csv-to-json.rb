#!/usr/bin/env ruby

require 'csv'
require 'json'

filename = ARGV.shift

if filename.nil?
  puts "usage: #{File.basename(__FILE__)} <filename>.csv"
  puts "outputs lines of json to stdout"
  exit
end

table = CSV.table(filename)
table.each do |row|
  puts JSON.dump(row.to_h)
end
