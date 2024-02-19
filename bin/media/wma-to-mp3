#!/usr/bin/ruby

require 'optparse'

$preset = 'medium'
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] <file>.wma"
  op.on("-p", "--preset <type>", "type: medium|standard|extreme|insane", "(default: #{$preset})") {|v| $preset = v}
  op.separator "outputs: <file>.mp3"
end

opts.parse!

if ARGV.size != 1
  puts opts.to_s
  exit
end

puts "using preset: #{$preset}"
file = ARGV.shift
wav = file.sub(/\.wma$/i,'.wav')
mp3 = wav.sub(/\.wav$/, '.mp3')

`mplayer #{file} -ao pcm:waveheader:file=#{wav} -vc null -vo null`

`lame --preset #{$preset} #{wav} #{mp3}`
File.unlink wav

