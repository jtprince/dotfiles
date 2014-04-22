#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'
require 'ostruct'

EXT_SUB = ".SUBSECTION"
EXT_FINAL = ".pdf"

opt = OpenStruct.new( ext: EXT_SUB + EXT_FINAL )
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)}  PDFTK_RANGE <file>.pdf ..."
  op.separator "output: <file>#{opt.ext} ..."
  op.separator "(goes to end of file if no stop provided)"
  op.on("-r", "--range", "include the range in the extension") {|v| opt.range = v }
end
parser.parse!

if ARGV.size < 2
  puts parser
  exit
end

range = ARGV.shift

files = ARGV

files.each do |file|
  base = file.chomp(File.extname(file))
  ext = EXT_SUB 
  ext << "_#{range}" if opt.range
  ext << EXT_FINAL
  outfile = base + ext
  cmd = "pdftk A=#{Shellwords.escape(file)} cat A#{range} output #{Shellwords.escape(outfile)}"
  system cmd
end

