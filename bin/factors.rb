#!/usr/bin/env ruby

require 'optparse'
require 'set'

$PAIR = false
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} [OPTS] <NUM> ..."
  op.separator "outputs the factors on the next line"
  op.separator "<NUM>: <factor> <factor> ..."
  op.on("--pair", "pair up the factors") { $PAIR = true }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

ARGV.each do |num_s|
  found = Set.new
  pairs = []
  num = num_s.to_i
  (num/2).downto(2) do |x|
    next if found.include?(x)
    if num % x == 0
      other = num / x
      found << x
      found << other
      pairs << [x, other]
    end
  end
  if $PAIR
    puts "#{num}: #{pairs.inspect}"
  else
    puts "#{num}: #{found.to_a.sort.join(' ')}"
  end
end
