#!/usr/bin/env ruby

require 'shellwords'

lame_opts = "--preset standard -q0"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.flac ..."
  puts "output: <file>.mp3"
  puts "using lame opts: #{lame_opts}"
  puts "[retains tag info]"
  exit
end


tag_convert = {
  :tt => "TITLE",
  :tl => "ALBUM",
  :ta => "ARTIST",
  :tn => "TRACKNUMBER",
  :tg => "GENRE",
  :ty => "DATE",
}

ARGV.each do |file|
  tag_opts = tag_convert.flat_map do |key,val|
    # comes out as TITLE=<the title>
    data = `metaflac --show-tag=#{val} #{Shellwords.escape(file)}`.split("=",2).last.strip
    ["--#{key}", Shellwords.escape(data)]
  end
  mp3name = file.chomp(File.extname(file)) + ".mp3"
  cmd = "flac -dc #{Shellwords.escape(file)} | lame #{lame_opts} #{tag_opts.join(" ")} --id3v2-only - #{Shellwords.escape(mp3name)}"
  system cmd
end


#tag_convert = {:tt=>"TITLE",:tl=>"ALBUM",:ta=>"ARTIST",:tn=>"TRACKNUMBER",:tg=>"GENRE",:ty=>"DATE"}
#ARGV.each do |f| 
#  tgs = tag_convert.map {|k,v| "--#{k} "+`metaflac --show-tag=#{v} #{f}`.split("=",2).last}.join(" ")
#  `flac -dc #{f} | lame --preset standard -q0 #{tgs} --add-id3v2 - #{f.sub(/.flac$/i,".mp3")}`
#end
