#!/usr/bin/env ruby

require 'shellwords'
require 'optparse'

class String
  def esc
    return Shellwords.escape(self)
  end
end

opt = {
  :export_dpi => 300,
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] <file>.svg[z] ..."
  op.separator "outputs: <file>.pdf"
  op.on("-t", "--text-to-path", "convert text to paths") {|v| opt[:text_to_path] = true }
  op.on("-d", "--export-dpi <#{opt[:export_dpi]}>", "rasterizes at this dpi") {|v| opt[:export_dpi] = v }
  op.on("-p", "--png", "export as png") {|v| opt[:png] = v }
  op.on("-b", "--bkg <color>", "export bkg color") {|v| opt[:bkg] = v }
  op.on("--dry", "just print out the command") {|v| opt[:dry] = v }
end

opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

def run(cmd, opt)
  puts cmd
  unless opt[:dry]
    system cmd
  end
end

def build_conversion_cmd(file, outfile, opt)
  outflag =
  args = [
    "inkscape",
    file.esc,
    opt[:text_to_path] ? "-t" : nil,
    outfile =~ /\.svg$/ ? nil : "-d #{opt[:export_dpi]}",
    opt[:bkg] ? "-b #{opt[:bkg]}" : nil,
    "--export-filename", outfile.esc,
  ]
  return args.compact.join(" ")
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  ext =
    if opt[:png]
      '.png'
    else
      '.pdf'
    end

  outfile = base + ext

  outfile_for_conversion = opt[:linkify] ? outfile.sub(".pdf", ".linkify.pdf") : outfile

  cmd = build_conversion_cmd(file, outfile_for_conversion, opt)
  run cmd, opt
end
