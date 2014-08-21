#!/usr/bin/env ruby

require 'tempfile'
require 'optparse'

unless `which wkhtmltopdf`.size > 0
  abort 'need wkhtmltopdf to run!'
end

$VERBOSE = true

CSS =<<HERE
h1 {
  font-size: 18pt;
  margin-left: -20px;
}
h2 {
  font-size: 14pt;
  margin-left: -10px;
}
h3 {
  font-size: 12pt;
}
h4 {
  font-size: 11pt;
}
body {
  margin-left: 20px;
  font-family: sans serif;
}
code {
  font-family: mono;
}
pre {
  font-family: mono;
  margin-left: 20px;
}
HERE


opt = {
  :margin => 0.8,
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <file>.html ..."
  op.separator "output: <file>.pdf ..."
  op.on("-c", "--css <file>", "css file to use") {|v| opt[:css] = v }
  op.on("--nocss", "don't do any css") {|v| opt[:nocss] = v }
  op.on("-m", "--margin <margin>", Float, "margins (in inches) to use") {|v| opt[:margin] = v }
end

opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

cssfile = opt[:css]
unless cssfile
  unless opt[:nocss]
    csstmpfile = Tempfile.new('css')
    csstmpfile.write(CSS)
    csstmpfile.close
    cssfile = csstmpfile.path
  end
end

m = opt[:margin]
ARGV.each do |file|
  base = file.chomp(File.extname(file))
  ss = "--user-style-sheet '#{cssfile}'" unless opt[:nocss]
  cmd = "wkhtmltopdf #{ss} -s Letter  -B #{m}in -T #{m}in -L #{m}in -R #{m}in '#{file}' '#{base + ".pdf"}'"
  cmd << " > /dev/null 2>&1" unless $VERBOSE
  puts cmd
  reply = `#{cmd}`
  puts reply if $VERBOSE
end

csstmpfile.unlink if csstmpfile
