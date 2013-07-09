#!/usr/bin/env ruby

require 'shellwords'

class String
  def shell_escape() Shellwords.escape(self) end
end

LAME_OPTS = "--preset standard -q0"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.flac ..."
  puts "output: <file>.mp3"
  puts "using lame opts: #{LAME_OPTS}"
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
    data = `metaflac --show-tag=#{val} #{file.shell_escape}`.split("=",2).last.strip
    ["--#{key}", data.shell_escape]
  end
  mp3name = file.chomp(File.extname(file)) + ".mp3"
  cmd = "flac -dc #{file.shell_escape} | lame #{LAME_OPTS} #{tag_opts.join(" ")} --id3v2-only - #{mp3name.shell_escape}"
  system cmd
end
