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
  op.on("--link", "assumes svglinkify.py magenta box links") {|v| opt[:linkify] = v }
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
    if outfile =~ /\.pdf$/
      "-A"
    elsif outfile =~ /\.png$/
      "-e"
    end
  args = [
    "inkscape",
    "-f", file.esc,
    opt[:text_to_path] ? "-t" : nil,
    outfile =~ /\.svg$/ ? nil : "-d #{opt[:export_dpi]}",
    opt[:bkg] ? "-b #{opt[:bkg]}" : nil,
    outflag, outfile.esc,
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

  if opt[:linkify]
    svg_outfile = base + ".linkify.svg"
    if file =~ /\.svgz/
      run "gunzip < #{file.esc} > #{svg_outfile}", opt
    else
      svg_outfile = file
    end
    linkify_cmd = ["svglinkify.py", svg_outfile, outfile_for_conversion, outfile].join(" ")
    run linkify_cmd, opt
    if svg_outfile =~ /\.linkify.svg$/
      File.unlink(svg_outfile) if File.exist?(svg_outfile)
    end
    File.unlink(outfile_for_conversion) if File.exist?(outfile_for_conversion)
  end
end
