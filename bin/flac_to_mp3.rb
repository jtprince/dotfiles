#!/usr/bin/env ruby

require 'shellwords'

class String
  def shell_escape() Shellwords.escape(self) end
end

#LAME_OPTS = "--preset extreme -q0"
LAME_OPTS = "--preset standard -q0"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.flac ..."
  puts "output: <file>.mp3"
  puts "using lame opts: #{LAME_OPTS}"
  puts "[retains tag info]"
  exit
end


tag_convert = {
  tt: "TITLE",
  tl: "ALBUM",
  ta: "ARTIST",
  tn: "TRACKNUMBER",
  tg: "GENRE",
  ty: "DATE",
  tc: "COMMENT",
}

ARGV.each do |file|
  tag_opts = {}
  tag_convert.each do |key,val|
    flactag = `metaflac --show-tag=#{val} #{file.shell_escape}`.strip
    if flactag.size > 0
      tag_opts[key] = flactag.split("=",2).last.strip
    end
  end
  tag_opts['tc'] = [tag_opts['tc'], "lame opts: #{LAME_OPTS}"].compact.join("; ")
  tag_flags = tag_opts.map {|key, val| "--#{key} #{val.shell_escape}" }

  mp3name = file.chomp(File.extname(file)) + ".mp3"
  cmd = "flac -dc #{file.shell_escape} | lame #{LAME_OPTS} #{tag_flags.join(" ")} --id3v2-only - #{mp3name.shell_escape}"
  system cmd
end
