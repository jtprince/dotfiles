#!/usr/bin/ruby

require 'open-uri'
require 'nokogiri'
require 'bluecloth'

urlbase = 'http://www.uniprot.org/uniprot/'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} UniprotID ..."
  exit
end

class NilClass
  def text
    nil
  end
end

# returns a hash from evidence code to pmid
# e.g., EC1 => 19819884
def get_key_to_pmid(entry_node)
  hash = {}
  entry_node.xpath('./evidence').each do |node| 
    pubmed_id = 
      if att = node['attribute']
        if md = att.match(/^PubMed=(.*)/)
          Integer(md[1])
        end
      end
    evidence_key = node['key']
    hash[evidence_key] = pubmed_id
  end
  hash
end

Comment = Struct.new(:text, :pmids)

class CommentSection
  attr_accessor :type
  attr_accessor :comments
  def initialize(node, key_to_pmid)
    @type = node['type']
    @comments = node.xpath('./text').map do |child|
      pmids = child['evidence'].split(' ').map {|key| key_to_pmid[key] }
      Comment.new(child.text, pmids)
    end
  end
end

SPECIAL_SECTIONS = ["subcellular location"]
VALID_COMMENT_SECTIONS = ["function", "subunit", "subcellular location", "tissue specificity", "disease", "miscellaneous", "similarity"]


ARGV.each do |id|
  doc = Nokogiri::XML.parse(open(urlbase + id + '.xml'), nil, nil, Nokogiri::XML::ParseOptions::STRICT |  Nokogiri::XML::ParseOptions::NOBLANKS)
  doc.remove_namespaces!
  entry = doc.xpath('./uniprot/entry').first
  key_to_pmid = get_key_to_pmid(entry)

  entry.xpath('./protein/recommendedName/fullName').text

  comment_node = entry.xpath('./comment[@type="tissue specificity"]')


  html = Markdown.new(md_text).to_html
end
