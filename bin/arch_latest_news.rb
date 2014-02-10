#!/usr/bin/env ruby

require 'nokogiri'
require 'open-uri'

# finds the latest piece of arch news (helpful if you want to check *before*
# you do an update!

page = open('https://www.archlinux.org/news/') {|io| io.read }
doc = Nokogiri::HTML(page) {|cfg| cfg.noblanks.nonet }
first_row_n = doc.xpath(%Q{//table[@id='article-list']//tr[@class='odd']}).first
table_data = first_row_n.xpath('td').map &:text

puts table_data[0,2].join(": ")

