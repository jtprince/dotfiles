#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'yaml'

opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTS] <file> ..."
  op.separator "replaces spaces with underscores"
  op.on("-c", "--close-gaps", "__ => _, _-_ => -") {|v| opt[:close_gaps] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

ARGV.each do |file|
  newfilename = file.gsub(/\s/, '_')
  if opt[:close_gaps]
    newfilename.gsub!(/_+/,'_')
    newfilename.gsub!('_-_','-')
  end
  if newfilename != file
    FileUtils.mv file, newfilename
    puts "renaming: #{file} ==> #{newfilename}"
  else
    puts "no spaces: #{file}"
  end
end
