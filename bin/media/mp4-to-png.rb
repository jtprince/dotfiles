#!/usr/bin/env ruby

require 'fileutils'
require 'shellwords'
filenames = ARGV.dup


if filenames.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mp4 ..."
  puts "output: <file>/<file>-%05d.png"
  exit
end

ARGV.each do |filename|
  basename = filename.chomp(File.extname(filename))
  system "ffmpeg -i #{Shellwords.escape(filename)} #{Shellwords.escape(basename)}-%05d.png"
  FileUtils.mkdir basename
  FileUtils.mv Dir.glob("#{basename}-*.png"), basename
end
