#!/usr/bin/env ruby

require 'open-uri'
require 'nokogiri'
require 'thread/pool'  # gem install thread

# <a href="http://media2.ldscdn.org/assets/general-conference/april-2013-general-conference/2013-04-1010-president-thomas-s-monson-64k-eng.mp3?download=true" class="audio-mp3" title="mp3" type="audio/mpeg">mp3</a>

def url_to_filename(url)
  url.split('/').last.split('?').first
end

EXCLUDE = %w{
session
sustaining-of-church-officers
statistical-report
general-young-women-meeting
}

pages = {
  april2013: 'http://www.lds.org/general-conference/sessions/2013/04?lang=eng'
}

key = ARGV.shift
if key.nil?
  puts "usage: #{File.basename(__FILE__)} april2013"
  exit
end

doc = Nokogiri(open(pages[key.to_sym]))
doc.remove_namespaces!


pool = Thread.pool(4)

download = {}
doc.xpath("//a[@class='audio-mp3']").each do |node|
  url = node[:href]
  save_to = url_to_filename(url)
  unless EXCLUDE.any? {|keyphrase| save_to.include?(keyphrase) }
    download[url] = save_to
  end
end

pool = Thread.pool(4)

download.each do |url,save_to|
  pool.process do
    puts save_to
    open(url, 'rb') do |io|
      File.write(save_to, io.read)
    end
  end
end

pool.shutdown
