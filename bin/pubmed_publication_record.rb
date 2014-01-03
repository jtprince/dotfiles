#!/usr/bin/env ruby

require 'bio'
require 'optparse'
require 'ostruct'
require 'nokogiri'
require 'ascii_charts'

Bio::NCBI.default_email = "abc@def.ghi.com"

# to get all my publicatios: (Prince JT[Author]) AND (Brigham Young University[Affiliation] OR Ahn NG[Author] OR Marcotte EM[Author])

opt = OpenStruct.new
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} 'query' ..."
  op.on("-t", "--treat-as <String>", "treat main query as query[<String>]") {|v| opt.treat_as = "[" + v + "]" }
  op.on("-a", "--affiliation <String>", "use affiliation for all") {|v| opt.affiliation = v }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

ARGV.each do |query|
  query = query.dup
  query << opt.treat_as if opt.treat_as
  query << " #{opt.affiliation}[affiliation]" if opt.affiliation
  pmids = Bio::PubMed.esearch(query)
  entries = Bio::PubMed.efetch(pmids)
  medline_entries = entries.map do |entry|
    Bio::MEDLINE.new(entry)
  end
  medline_entries.each do |entry|
    puts "===================="
    puts [:pmid, :ti, :ta].map {|k| entry.send(k) }.join("\n")
  end

  by_year = medline_entries.group_by(&:year)
  years = (2008..2013).map(&:to_s)
  num_pubs = years.map do |year| 
    entries = by_year[year]
    entries ? entries.size : 0
  end
  years = years.map(&:to_i)
  total_pubs = num_pubs.reduce(:+)

  puts "=" * 60
  puts query
  puts AsciiCharts::Cartesian.new([years, num_pubs].transpose).draw
end

