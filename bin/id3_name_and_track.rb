#!/usr/bin/env ruby

require 'optparse'

opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [-t] [-n] <file>.mp3 ..."
  op.on("-t", "--title", "sets the title from the filename") {|v| opt[:title] = v }
  op.on("-n", "--track", "sets the track from the ORDER given") {|v| opt[:track] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

if opt[:title]
  ARGV.each do |filename|
    system "id3v2 -t #{filename.sub('.mp3', '')} \"#{filename}\""
  end
end

if opt[:track]
  ARGV.each_with_index do |filename,i|
    track_num = i+1
    system "id3v2 -T #{track_num.to_s} \"#{filename}\""
  end
end
