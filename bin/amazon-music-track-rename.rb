#!/usr/bin/env ruby

files = ARGV

if files.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mp3 ..."
  puts "output: '3 - whatever' --> '003-whatever'"
  puts "output: '15 - whatever' --> '015-whatever'"
  exit
end

files.each do |orig|
  track, content = orig.split(/ ?- ?/, 2)
  track = "0" + track if track.size == 2
  track = "00" + track if track.size == 1
  newname = track + '-' + content
  if orig != newname
    File.rename(orig, newname)
  end
end
