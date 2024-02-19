#!/usr/bin/env ruby

require 'trollop'

parser = Trollop::Parser.new do
  banner "usage: #{File.basename(__FILE__)} <file>.mid ..."
  banner "output: <file>.mp3"
  opt :var, "4=medium=165, 2=standard=190, 0=extreme=245", :short => :V, :default => 4
end

opts = parser.parse(ARGV)

if ARGV.size == 0
  parser.educate
  exit
end

ARGV.each do |midi_fn|
  mp3_fn = midi_fn.sub(/\.midi?$/i, '.mp3')
  cmd = "timidity -Ow -o - '#{midi_fn}' | lame -V #{opts[:var]} - '#{mp3_fn}'"
  puts "executing: #{cmd}"
  system cmd
end
