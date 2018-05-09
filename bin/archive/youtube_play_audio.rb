#!/usr/bin/env ruby

require 'optparse'
require 'shellwords'

class String
  def esc
    Shellwords.escape(self)
  end
end

LIMIT = 13 

TMP_DIR = '/tmp'

def to_key(key)
  # 11 is the correct length
  key.size > 11 ? key[/v=(.*)/,1] : key
end

Song = Struct.new(:info, :key, :play_url) do
  BASE_URL = "http://www.youtube.com/watch?v="
  def url
    BASE_URL + key
  end
end

def prep_comment(comment)
  if comment =~ /\A\#/
    comment.sub(/\A\#\s+/,'')
  else
    ''
  end
end

class PlaylistReader
  # returns an array of songs
  def read(filename)
    lines = IO.readlines(filename).map(&:chomp)
    songs = []
    lines.each_cons(2) do |comment, key|
      next if key =~ /^\#/ || key !~ /\w/
      songs << Song.new(prep_comment(comment), to_key(key))
    end
    songs
  end

  # takes either a youtube key or a url and returns the key
end

playlist_extensions = %w(.m3u .playlist .playline)

opt = {
  :start => 0,
  :loop => 5,
}
opts = OptionParser.new do |op|
  prog = File.basename(__FILE__)
  op.banner = "usage: #{prog} <ID|URI> ..."
  op.separator "   or: #{prog} <PLAYLIST(ID|URL)> ..."
  op.separator "   or: #{prog} <file>.yt.m3u ..."
  op.separator "limited to first #{LIMIT} videos"
  op.on("-l", "--loop <i>", Integer, "loop that many times (default: #{opt[:loop]})") {|v| opt[:loop] = v }
  op.on("-p", "--playlist", "treat the ids as playlist ids") {|v| opt[:playlist] = v }
  op.on("--list", "treat the args as playlist filenames") {|v| opt[:list] = v }
  op.on("-s", "--start <start_num>", Integer, "start from that track") {|v| opt[:start] = v }
  op.on("--ignore-limit", "just play the whole thing") {|v| opt[:ignore_limit] = true }
  op.on("-d", "--dry", "just print the commands and exit") {|v| opt[:dry] = v ; $VERBOSE = 5 }
  op.on("-v", "--verbose", "be loud") { $VERBOSE = 5 }
  op.separator "if file ends in #{playlist_extensions.join(', ')} then treats as playlist"
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

songs = ARGV.each_with_object([]) do |arg, songs|
  if arg.include?('playlist?') || opt[:playlist]
    urls = `youtube_scrape_playlist_urls.rb '#{arg}'`.chomp.split(/\s+/)
    songs.push(  *urls.map {|url| Song.new(nil, to_key(url)) }  )
  else
    if opt[:list] || (arg =~ /\.(m3u)$/)
      songs.push(*PlaylistReader.new.read(arg))
    else
      songs << Song.new(nil, to_key(arg))
    end
  end
end

puts "starting from track: #{opt[:start]}"

limit = opt[:ignore_limit] ? (songs.size - opt[:start]) : LIMIT
songs_chopped = songs[opt[:start],limit]

num_missing = songs.size - songs_chopped.size
puts "not using #{num_missing} tracks because reached limit (#{limit})" if num_missing > 0

songs_chopped.each do |song| 
  cmd = "youtube-dl -gf 34 --cookies /tmp/cookie.txt '#{song.url}'"
  puts cmd if $VERBOSE
  song.play_url = `#{cmd}`.chomp  # we still need to do this even if dry
end

# cleanup urls:
songs = songs.select do |song| 
  song.play_url.include?('http')
end

no_video = "-vo null"
if ARGV[0] =~ /\.v3u$/
  no_video = ""
end

cmd = "mplayer #{no_video} -cookies -cookies-file /tmp/cookie.txt -loop #{opt[:loop]} " + 
  songs.map(&:play_url).map(&:esc).join(" ")
puts cmd if $VERBOSE
system cmd unless opt[:dry]
