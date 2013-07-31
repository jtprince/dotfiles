#!/usr/bin/env ruby

require 'bio'
Bio::NCBI.default_email = "abc@efg.com"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <pubmed ID> ..." 
  puts "output: <bibtex formatted text>"
  puts "note: retrieves them all at once to be good citizen to pubmed"
  exit
end

entries = Bio::PubMed.efetch(ARGV)
entries.each do |entry|
  medline = Bio::MEDLINE.new(entry)
  reference = medline.reference
  puts
  puts reference.bibtex
end


