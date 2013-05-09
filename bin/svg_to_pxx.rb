#!/usr/bin/env ruby

require 'optparse'

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
end

opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  (ext, out_flag) = 
    if opt[:png]
      ['.png', '-e']
    else
      ['.pdf', '-A']
    end
  outfile = base + ext
  cmds = []
  cmds << "inkscape"
  cmds << "-f" << "'#{file}'"
  cmds << "-t" if opt[:text_to_path]
  cmds << "-d" << opt[:export_dpi] 
  (cmds << "-b" << opt[:bkg])  if opt[:bkg]
  cmds << out_flag << outfile
  cmd = cmds.join(" ")
  puts cmd
  system cmd
end
