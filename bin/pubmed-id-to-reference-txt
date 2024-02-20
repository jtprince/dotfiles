#!/usr/bin/env ruby

require 'shellwords'
require 'optparse'
require 'ostruct'

begin
  require 'bio'
rescue
  puts "\n*** You need the 'bio' gem to run #{File.basename(__FILE__)}! ***"
  puts "     %        gem install bio"
  puts "(or) %   sudo gem install bio"
end

Bio::NCBI.default_email = "abc@efg.com"

opt = OpenStruct.new(abstract: true, browser: true)
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <pubmed ID> ..." 
  op.separator "outputs simpler reference and copies to clipboard for pasting"
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

def prep_authors(authors)
  authors.map! {|author| author.sub(', ', ' ') }
  authors.join(", ")
end

pubmed_base_url = "http://www.ncbi.nlm.nih.gov/pubmed/"

if __FILE__ == $0
  pmids = ARGV.dup

  entries = Bio::PubMed.efetch(pmids)
  medline_entries = entries.map {|entry| Bio::MEDLINE.new(entry) }

  lines = medline_entries.map do |entry|
    "#{prep_authors(entry.authors)} “#{entry.title}” #{entry.journal} (#{entry.year}) #{entry.volume}:#{entry.pages}."
  end

  puts lines.join("\n")

  to_copy = lines.join("\n")
  # copy text to clipboard (depends on persistent xclip)
  %w{clipboard primary}.each do |reg| 
    system %Q{echo -n #{Shellwords.escape(to_copy)} | xclip -selection #{reg} }
  end
end


