#!/usr/bin/env ruby

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  pdffile = base + ".pdf"
  system "ps2pdf '#{file}'"
  system "rotate_pdf.rb #{pdffile}"
  rotated_pdffile = base + ".rotated" + ".pdf"
  system "mv '#{rotated_pdffile}' '#{pdffile}'"
end
