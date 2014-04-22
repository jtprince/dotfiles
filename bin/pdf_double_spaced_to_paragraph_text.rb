#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'
require 'ostruct'

opt = OpenStruct.new
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <file>.pdf ..."
  op.separator "output: <file>.txt ..."
  op.on("-f", "--formfeed", "remove the formfeed lines") {|v| opt.formfeed = v }
  op.on("-k", "--kill <regexp>", "kill any line with regex") {|v| opt.kill = Regexp.new(v) }
  op.on("-s", "--sentencesplit", "split out lines on sentences") {|v| opt.sentencesplit = v }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  textfile = base + ".txt"
  `pdftotext -layout #{Shellwords.escape(file)}`
  lines = IO.readlines(textfile)

  if opt.formfeed
    lines.select! {|line| line !~ /\f/ }
  end

  text = lines.join
  text.gsub!("\n\n", " ")

  lines = text.split("\n")
  if opt.kill
    lines.select! {|line| line !~ opt.kill }
  end
  text = lines.join("\n")

  if opt.sentencesplit
    text.gsub!(/\.(\d+)?\s+/, ".\n") 
  end

  File.write(textfile, text)
  #File.unlink textfile
end
