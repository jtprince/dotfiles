#!/usr/bin/env ruby

require 'optparse'
require 'nokogiri'
require 'open-uri'

def sanitize_filename(filename)
  filename.gsub(/[^0-9A-Za-z.\-]+/, '_')
end

# returns all hrefs and the title
def get_all_hrefs_and_title(page)
  doc = Nokogiri::HTML(open(page))
  links = doc.css('a')
  href_text_pairs = links.map do |link| 
    title = link.xpath("//span").map {|node| node['title video-title yt-uix-tooltip'] }.compact.first
    # still working this out....
    [link.attribute('href').to_s, link.text]
  end
  href_text_pairs = href_text_pairs.uniq.sort.delete_if {|pair| pair.first.empty? }
  #hrefs = links.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if {|href| href.empty?}
  title = doc.css('h1').text
  [href_text_pairs, title]
end

base = 'http://www.youtube.com/playlist?list='

opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <URL|PLAYLIST_ID>"
  op.separator "outputs video IDs, all on one line"
  op.on("-f", "--file", "write to <playlist title>.yt.m3u ", "one per line") {|v| opt[:output] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

url = ARGV.shift
unless url.match(/youtube.com/)
  url = base + url
end

(href_text_pairs, title) = get_all_hrefs_and_title(url)

pairs_with_urls = href_text_pairs.select {|pair| pair.first =~ (/watch\?.*index=\d+/) }
id_with_text = pairs_with_urls.map! {|pair| [pair.first.match(/v=([^\&]+)/)[1], pair.last] }

(opt[:output] = sanitize_filename(title)) if opt[:output]

if opt[:output]
  out = opt[:output] + ".yt.m3u"
  STDERR.puts "writing to #{out}"
  File.open(out,'w') do |out|
    id_with_text.each do |pair|
      #out.puts "# #{pair.last}"
      out.puts pair.first
    end
  end
else
  puts id_with_text.map(&:first).join(' ')
end
