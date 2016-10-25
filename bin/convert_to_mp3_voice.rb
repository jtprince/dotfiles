#!/usr/bin/env ruby

require "shellwords"

ARGV.each do |file|
  basename = file.chomp(File.extname(file))
  mp3_file = basename + ".mp3"
  cmd = "ffmpeg -i #{Shellwords.escape(file)} -acodec mp3 -ac 1 -q:a 9 #{Shellwords.escape(mp3_file)}"
  system cmd
end
