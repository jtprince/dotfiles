#!/usr/bin/env ruby

require 'tempfile'
require 'fileutils'
require 'prawn'
require 'optparse'
# also requires pdftk

nn_ext = ".namenumber"
opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <file>.pdf ..."
  op.separator "output: <file>#{nn_ext}.pdf ..."
  op.on("-e", "--nopdfext", "don't stamp with pdf extension") {|v| opt[:nopdfext] = v }
  op.on("-n", "--nonumber", "do not number pages") {|v| opt[:nonumber] = v }
  op.on("-t", "--text <String>", "use this string instead of the filename") {|v| opt[:text] = v }
  op.on("--overwrite", "overwrite original file") {|v| opt[:overwrite] = v }
  op.on("--ow", "(same thing)") {|v| opt[:overwrite] = v }
end
opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

TOP_MARGIN = 18
RIGHT_MARGIN = 20
JUSTIFY = :right
FONT_SIZE = 8 
COLOR = '777777'

ARGV.each do |file|
  fileappears = opt[:nopdfext] ? file.chomp(File.extname(file)) : file
  ext = File.extname(file)
  base = file.chomp(ext)
  stampfile = base + ".STAMP_TMP.pdf"
  outfile = base + nn_ext + ext
  data = `pdftk '#{file}' dump_data output`
  num_pages = data[/NumberOfPages: (\d+)/,1].to_i
  page_count = 1

  Prawn::Document.generate(stampfile, :right_margin => RIGHT_MARGIN, :top_margin => TOP_MARGIN) do |pdf| 
    pdf.fill_color  COLOR
    pdf.stroke_color  COLOR
    loop do
      text = opt[:text] || fileappears
      ntext = opt[:nonumber] ? text : (text + " (#{page_count} of #{num_pages})")
      pdf.text(ntext, :align => JUSTIFY, :size => FONT_SIZE)
      break if page_count >= num_pages
      pdf.start_new_page
      page_count += 1
    end
  end

  cmd = "pdftk '#{file}' multistamp '#{stampfile}' output #{outfile}"
  print `#{cmd}`
  if opt[:overwrite]
    FileUtils.mv outfile, file
    puts "overwrote: #{file}"
  else
    puts "wrote: #{outfile}"
  end
  File.unlink stampfile
end
