#!/usr/bin/ruby

require 'optparse'

$IND = false
$TYPE = 'mp3'
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <mount|dev>"
  op.separator "     example of mount: /media/cdrom"
  op.separator "     example of dev: /dev/dvd   or   /dev/sr0"
  op.separator ""
  op.on("-i", "--individual", "extract each chapter as separate track") {|v| $IND = true }
  op.on("-t", "--type <wav|mp3>", "type to extract (default: #{$TYPE})") {|v| $TYPE = v }
end

opts.parse!

if ARGV.size == 0
  puts opts.to_s
  exit
end

abort "need 'lsdvd' installed!" unless `lsdvd`.match( /Disc Title/m ) 
abort "need 'transcode' installed!" unless `transcode`.match( /transcode .h/m )

loc = ARGV.shift

titles = `lsdvd #{loc}`.split("\n").select do |line|
  line =~ /^Title: / 
end

title_hashes = titles.map do |title|
  hash = {}
  title.split(", ").select do |keyval|
    if keyval =~ /^Title: (\d+)/ 
      hash[:title] = $1.dup
    elsif keyval =~ /Chapters: (\d+)/
      hash[:chapters] = $1.dup
    end
  end
  hash
end

type_hash = { 'mp3' => 'raw', 'wav' => 'wav' }

transc = Proc.new do |loc, trackcode, trackname| 
  cmd = "transcode -i #{loc} -x dvd -T #{trackcode} -a 0 -y #{type_hash[$TYPE]} -m #{trackname}.#{$TYPE}"
  puts "EXECUTING: #{cmd}"
  puts `#{cmd}`
end

ANGLE = 1

title_hashes.each do |title_hash|
  title_string = "title#{title_hash[:title]}"
  title_num = title_hash[:title].to_i
  if $IND
    num_chaps = title_hash[:chapters].to_i
    (1..num_chaps).each do |chap|
      transc.call(loc, "#{title_num},#{chap},#{ANGLE}", "#{title_string}_ch#{sprintf("%.2d",chap)}")
    end
  else
    transc.call(loc, "#{title_num},-1", title_string)
  end
end
