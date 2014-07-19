#!/usr/bin/ruby

require 'optparse'

begin
  reply = `enscript --help`
  raise "bad reply" unless reply =~ /Usage: enscript/
rescue
  puts "You may not have enscript installed: "
  puts "sudo aptitude install enscript"
  puts "sudo pacman -S enscript"
  exit
end

DEFAULT_MARGIN = 0.75
$DRY = false

opt = { 
  :word_wrap => '--word-wrap',
  :header => '--no-header',
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <file>.txt ... -- [other enscript options]"
  op.separator "outputs: <file>.pdf"
  op.separator "[requires: enscript and ps2pdf]"
  op.separator ""
  op.on("-m", "--margin <Inches>", Float, "the margin (#{DEFAULT_MARGIN} default)") {|v| opt[:margin] = v }
  op.on("--margins <l,r,t,b>", Array, "margins in inches (#{DEFAULT_MARGIN} default)") {|v| opt[:margins] = v }
  op.on("-f", "--font <Courier10>", "font to use, e.g. Times-Roman12") {|v| opt[:font] = v }

  op.separator ""
  op.separator "by default --word-wrap and --no-header are supplied"
  op.separator "remove these options if you are supplying your own in these areas:"
  op.on("--no-wrap", "remove #{opt[:word_wrap]}") {|v| opt[:word_wrap] = '' }
  op.on("-h", "--header", "remove #{opt[:header]}") {|v| opt[:header] = '' }

  op.on("--dry", "just print the commands") {|v| $DRY = true; $VERBOSE = 3 }
  op.on("-v", "--verbose", "verbose") {|v| $VERBOSE = 3 }
end

enscript_args = []
if (x = ARGV.index('--'))
  files = ARGV[0,x]
  enscript_args = ARGV[x+1..-1]
else
  files = ARGV
end
files ||= []

opts.parse!(files)

if files.size == 0
  puts opts
  exit
end


def run(cmd)
  puts cmd if $VERBOSE
  unless $DRY
    reply = `#{cmd} 2>&1`
    print reply if reply && reply.size > 0 && $VERBOSE
  end
end

# 1 PostScript point = 0.0138888889 inches

# let margins override margin
margins = Array.new(4,DEFAULT_MARGIN)
if opt[:margin]
  margins = Array.new(4,opt[:margin])
end
if opt[:margins]
  opt[:margins].each_with_index do |m,i|
    margins[i] = m
  end
end
opt[:margins] = "--margins=#{margins.map! {|v| v*72 }.join(":")}"
opt.delete(:margin)

if opt[:font]
  font_string = "-f #{opt[:font]}"
end

files.each do |file|
  base_file = file.chomp(File.extname(file))
  ps_file = base_file + '.ps'
  pdf_file = base_file + '.pdf'
  run "enscript #{enscript_args.join(" ")} #{opt.values.join(" ")} #{file} #{font_string} -o #{ps_file}"
  run "ps2pdf #{ps_file}"

  if [ps_file, pdf_file].all? {|file| File.exist?(file) }
    File.unlink ps_file
  end
end




