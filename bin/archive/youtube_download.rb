#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'optparse'
require 'open-uri'
require 'cgi'

basic_escape = {
  ' ' => '20',
  '<' => '3C',
  '>' => '3E',
  '#' => '23',
  '%' => '25',
  '{' => '7B',
  '}' => '7D',
  '|' => '7C',
  '\\' => '5C',
  '^' => '5E',
  '~' => '7E',
  '[' => '5B',
  ']' => '5D',
  '`' => '60',
  ';' => '3B',
  '/' => '2F',
  '?' => '3F',
  #':' => '3A',
  '@' => '40',
  '=' => '3D',
  '&' => '26',
  '$' => '24',
  '"' => '22',
}
Escape = {}
basic_escape.each do |k,v|
  Escape[k] = '%' + v
end

def url_escape(string)
  new_string = string.dup
  new_string.gsub!('%', Escape['%'])
  Escape.each do |char,repl|
    next if char == '%'
    new_string.gsub!(char,repl)
  end
  # gets unicode beasties:
  new_string = new_string.unpack("U*").collect {|s| (s > 127 ? "%#{sprintf("%X",s)}" : s.chr) }.join("")
  new_string
end

$mp3 = nil
opts = OptionParser.new do |op|
  op.banner = "USAGE: #{File.basename(__FILE__)} 'youtube_url' ..."
  op.separator "downloads the link as an flv file"
  op.separator ""
  op.separator "EXAMPLE: #{File.basename(__FILE__)} 'http://www.youtube.com/watch?v=wpe3yTYpWKg'"
  op.separator "(single quotes surrounding link are good for crazy characters in the url)"
  op.separator ""
  op.separator "OPTIONS:"
  op.on("-m", "--mp3", "extracts the mp3 with ffmpeg") {|v| $mp3 = v }
end

opts.parse!

if ARGV.size < 1
  puts opts.to_s
  exit
end

if $mp3
  ## check for player
  ffmpeg_cmd = 'ffmpeg'
  begin
    got_usage = false
    2.times do
      if `#{ffmpeg_cmd}`.match(/usage:/)
        got_usage = true
        break
      end
      ffmpeg_cmd << '.exe'
    end
    ffmpeg_cmd = nil unless got_usage
  rescue
    ffmpeg_cmd = nil
  end

  unless ffmpeg_cmd
    puts "ffmpeg must be installed on your computer for extracting audio"
    puts "exiting"
    exit
  end
end



ARGV.each do |youtube_url|
  form_page = 'http://www.techcrunch.com/ytdownload3.php'
  # youtube_url = 'http://www.youtube.com/watch?v=bpgKC5nWVFg'

  agent = WWW::Mechanize.new
  agent.user_agent_alias = 'Mac Safari'
  page = agent.get(form_page)
  search_form = page.forms.first
  search_form.field('url').value = youtube_url
  search_results = agent.submit(search_form)
  url = search_results.iframes.first.src.split("\n").first.sub(/';$/,'')
  url_sanitized = url.gsub(/title=([^&]+)/) do |v|
    'title=' + url_escape(Regexp.last_match[1])
  end

  filename_base = url.match(/title=([^&]+)/)[1].gsub(' ','_').gsub(/[^A-Za-z0-9_\\-]/,'')[0..50]
  video_filename = filename_base + '.flv'

  #p url
  #p url_sanitized

  puts "downloading link: #{url_sanitized}"
  open(url_sanitized) do |input|
    $stdout.flush
    File.open(video_filename, 'wb') {|out| out.print(input.read) }
    puts "video saved: #{video_filename}"
    $stdout.flush
  end


  if $mp3
    mp3_file = filename_base + '.mp3'
  `#{ffmpeg_cmd} -i #{video_filename} -ab 128 -ar 44100 #{mp3_file}`
  puts "extracted audio: #{mp3_file}"
  end
end

