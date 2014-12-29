#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'

opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [-t] [-n] <file>.mp3 ..."
  op.on("-t", "--title", "sets the title from the filename") {|v| opt[:title] = v }
  op.on("-n", "--track", "sets the track from the ORDER given") {|v| opt[:track] = v }
  op.on("-a", "--album <String>", "sets the album") {|v| opt[:album] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

ARGV.each_with_index do |filename, i|
  fname_esc = Shellwords.escape(filename)
  options = []
  if opt[:title]
    options << ['-s', fname_esc.sub('.mp3', '')].join
  end
  if opt[:track]
    track_num = i+1
    options << ['-t', track_num].join
  end
  if opt[:album]
    options << ['-A', opt[:album]].join
  end
  cmd = "id3tag #{options.join(' ')} #{fname_esc}"
  puts cmd
  system cmd
end
