#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'cgi'
require 'shellwords'

class String
  def clipboard(clipboard=false)
    registers = %w{primary}
    registers << "clipboard" if clipboard
    registers.each do |reg| 
      system %Q{echo -n #{Shellwords.escape(self)} | xclip -selection #{reg} }
    end
    puts "copied to #{registers.join(' and ')}"
  end
end

# some pubs done here at BYU are not captured by the university affiliation,
# but those are ones done with Dan Ventura
QUERY = "(Prince JT[Author]) AND (Brigham Young University[Affiliation] OR Ahn NG[Author] OR Marcotte EM[Author] OR Ventura D[Author])"

opt = OpenStruct.new({})
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <option>"
  op.on("-q", "--query", "print and clipboard the pubmed query") {|v| opt.query = v }
  op.on("-l", "--link", "print and clipboard the url link") {|v| opt.link = v }
  op.on("-c", "--clipboard", "also copy to clipboard (not just primary)") {|v| opt.clipboard = v }
end
parser.parse!

if opt.to_h.size == 0
  puts "need at least one option"
  puts parser
  exit
end

if opt.query
  QUERY.clipboard(opt.clipboard)
  puts QUERY
end

if opt.link
  url = "http://www.ncbi.nlm.nih.gov/pubmed/?term=" + CGI.escape(QUERY)
  url.clipboard(opt.clipboard)
  puts url
end
