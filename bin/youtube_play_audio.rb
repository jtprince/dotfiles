#!/usr/bin/env ruby

require 'optparse'

BASE_URL = "http://www.youtube.com/watch?v="
LIMIT = 13 

TMP_DIR = '/tmp'

# returns a list of edl files
def generate_edls(pedl, original_playlist_urls)
  lines = IO.readlines(pedl).select {|line| line =~ /\w/ }
  index_to_edl_array = {}
  edls = Array.new(original_playlist_urls.size)
  last_valid_edl_ar = nil
  while (line = lines.shift)
    if md=line.match(/^>\s*(.*)\s*/)
      last_valid_edl_ar = 
        if md[1] =~ /[^0-9]/
          index_to_edl_array[ original_playlist_urls.index {|v| v.include?(md[1]) } ]  = []
        else
          index_to_edl_array[ md[1].to_i ] = []
        end
    else
      last_valid_edl_ar << line
    end
  end
  index_to_file_array = {}
  index_to_edl_array.each do |index, lines|
    file = TMP_DIR + "/youtube_play_audio_#{index}.edl"
    index_to_file_array[index] = file
    File.write(file, lines.join)
  end
  original_playlist_urls.each_with_index.map do |url, index|
    index_to_file_array[index]
  end
end


playlist_extensions = %w(.m3u .playlist .playline)

opt = {
  :start => 0,
  :loop => 5,
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <ID|URI> ..."
  op.separator "   or: #{File.basename(__FILE__)} <PLAYLIST(ID|URL)>"
  op.separator "limited to first #{LIMIT} videos"
  op.on("-l", "--loop <i>", Integer, "loop that many times (default: #{opt[:loop]})") {|v| opt[:loop] = v }
  op.on("-p", "--playlist", "treat the id as a playlist id") {|v| opt[:playlist] = v }
  op.on("--list", "treat the arg as playlist filename", "(one line or many)") {|v| opt[:list] = v }
  op.on("-s", "--start <start_num>", Integer, "start from that track") {|v| opt[:start] = v }
  op.on("--ignore-limit", "just play the whole thing") {|v| opt[:ignore_limit] = true }
  op.on("-d", "--dry", "just print the commands and exit") {|v| opt[:dry] = v ; $VERBOSE = 5 }
  op.on("-e", "--pedl <file>", "reads a playlist edit decision list file") {|v| opt[:pedl] = v }
  op.separator "                      > [zeroBasedIndex|uniqueIdentifier]"
  op.separator "                      <start> <stop> <0|1>"
  op.on("-v", "--verbose", "be loud") { $VERBOSE = 5 }
  op.separator "if file ends in #{playlist_extensions.join(', ')} then treats as playlist"
end
opts.parse!


if ARGV.size == 0
  puts opts
  exit
end

uris = 
  if ARGV.first.include?('playlist?') || opt[:playlist]
    `youtube_scrape_playlist_urls.rb '#{ARGV.first}'`.chomp.split(/\s+/)
  else
    ARGV
  end

if opt[:list] || (ARGV.first =~ /\.(v3u|m3u|playlist|playline)$/)
  lines = uris.map do |file| 
    chomped_lines = IO.readlines(file).map(&:chomp)
    chomped_lines.reject {|line| line =~ /^\#/ || line !~ /\w/ }
  end.flatten
  uris = 
    if lines.size == 1 && lines.first.include?(" ")
      lines.first.split(/\s+/)
    else
      lines
    end
end

uris = uris.map do |uri|
  uri = (BASE_URL + uri) unless uri.match(/^http/)
  uri.chomp
end

puts "starting from track: #{opt[:start]}"

limit = opt[:ignore_limit] ? (uris.size - opt[:start]) : LIMIT
uris_chopped = uris[opt[:start],limit]

num_missing = uris.size - uris_chopped.size
puts "not using #{num_missing} tracks because reached limit (#{limit})" if num_missing > 0

urls = uris_chopped.map do |uri| 
  cmd = "youtube-dl -gf 34 --cookies /tmp/cookie.txt '#{uri}'"
  puts cmd if $VERBOSE
  `#{cmd}`.chomp  # we still need to do this even if dry
end

# cleanup urls:
urls = urls.select do |url| 
  url.include?('http')
end
urls.map! {|url| "'" + url + "'" }

if opt[:pedl]
  # replace with a mapped array to the filenames
  opt[:pedl] = generate_edls(opt[:pedl], uris)
  urls = urls.zip(opt[:pedl]).map do |url, edl|
    if edl
      "-edl #{edl} #{url}"
    else
      url
    end
  end
end

no_video = "-vo null"
if ARGV[0] =~ /\.v3u$/
  no_video = ""
end

cmd = "mplayer #{no_video} -cookies -cookies-file /tmp/cookie.txt -loop #{opt[:loop]} "  + urls.join(" ")
puts cmd if $VERBOSE
system cmd unless opt[:dry]


if opt[:pedl]
  #opt[:pedl].each {|f| File.unlink(f) }
end
