#!/usr/bin/env ruby

require 'nokogiri'

unless ARGV.size >= 1
  puts "usage: #{File.basename(__FILE__)} xml_file ..."
  exit
end


ARGV.each do |file|
  File.open(file) do |io|
    begin
      Nokogiri::XML(io) {|cfg| cfg.strict }
    rescue Nokogiri::XML::SyntaxError => e
      puts "#{file}: ERROR! #{e}"
    else
      puts "#{file}: Well Formed"
    end
  end
end
