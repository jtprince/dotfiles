#!/usr/bin/env ruby

files = ARGV

if files.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mp3 ..."
  puts "confirms that all tracks are present"
  exit
end

previous = nil
files.each_with_index do |orig, index|
  track, content = orig.split(/ ?- ?/, 2)
  num = track.to_i
  if previous && num != previous + 1
    puts "something off between #{previous} and #{num}"
  end
  previous = num
end
