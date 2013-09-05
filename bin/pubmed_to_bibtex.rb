#!/usr/bin/env ruby

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

def escape(string)
  { 
    "&" => "\\&",
    "%" => "\\%",
    "{" => "\\{",
    "}" => "\\}",
  }.inject(string) do |st, (k,v)|
    st.gsub(k) {v}
  end
end

# if file is nil, then uses normal stdout
def bib_append(file=nil, &block)
  if file
    orig_stdout = $stdout
    $stdout = File.open(file,'a')
    reply = block.call
    $stdout.close
    $stdout = orig_stdout
    reply
  else
    block.call
  end
end

opt = OpenStruct.new
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <pubmed ID> ..." 
  op.separator "output: <bibtex formatted text>"
  op.separator "note: retrieves them all at once to be good citizen to pubmed"
  op.separator "      uses 'firstAuthorLastName+year' as default label"
  op.separator ""
  op.on("-b", "--bib-append [file]", "append to the first .bib file in pwd (or given)") {|v| opt.bib_append = v || :first }
  op.on("-a", "--abstract", "include the abstract") {|v| opt.abstract = v }
  op.on("-l", "--label <String>", "use the specified label") {|v| opt.label = v }
  op.on("--pmid-label", "use PMID as label (overrides -l)") {|v| opt.pmid_label = v }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

type = 'article'
entries = Bio::PubMed.efetch(ARGV)
entries.each do |entry|
  medline = Bio::MEDLINE.new(entry)
  reference = medline.reference

  extra = {}
  unless opt.label
    first_author_last_name = reference.authors.first.split(",").first
    opt.label = first_author_last_name + reference.year
  end
  opt.label = nil if opt.pmid_label

  extra['pmid'] = reference.pubmed
  extra['abstract'] = escape(reference.abstract) if opt.abstract

  if opt.bib_append
    bibfile = (opt.bib_append==:first) ? Dir["*.bib"].sort.first : opt.bib_append
    warn "no bibfile found! writing to STDOUT" unless bibfile
  end
  bib_append(bibfile) do
    puts
    puts reference.bibtex(type, opt.label, extra)
  end
end


