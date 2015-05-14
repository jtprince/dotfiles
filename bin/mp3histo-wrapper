#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mp3 ..."
  puts "outputs to STDOUT and <file>.histo"
  puts "(requires mp3hist)"
  exit
end

ARGV.each do |file|
  reply = `mp3histo #{file}`
  sum = 0
  frames = 0
  reply.each_line do |line|
    (bitrate, framecnt) = line.split(']')
    br = bitrate[1..-1].to_i
    fc = framecnt.split(' ').first.to_i
    sum += ( br * fc )
    frames += fc
  end
  p sum
  p frames
  avg = sum.to_f / frames
  puts avg
end

