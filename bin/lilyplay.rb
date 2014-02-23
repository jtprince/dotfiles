#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.ly"
  puts "runs lilypond on file and plays midi output"
  exit
end

midifiles = ARGV.map do |file|
  ext = File.extname(file)
  base = file.chomp(ext)
  system "lilypond", file
  midifile = base + ".midi"
  system "timidity", midifile
end
