#!/usr/bin/env ruby
# encoding: UTF-8

require 'cgi'
require 'tempfile'
require 'optparse'

def cmd(string)
  puts "executing: #{string}"
  `#{string}`
end

def html_docify(fragments, style_code="")
  %Q{<html><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />} + 
    %Q{<style type="text/css">} +
    style_code +
    "</style><body>" +
    fragments.join("\n") + 
    "</body></html>"
end

opt = {
  :exclude => [],
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <topdir>"
  op.separator "[note that the style sheet is embedded in this script]"
  op.on("-e", "--exclude <file>", "which files to exclude (multi-use)") {|v| opt[:exclude] << File.expand_path(v) }
  #op.on("--verbose", "talk about it") {|v| $VERBOSE = 5 }
end

opts.parse!

if ARGV.size != 1
  puts opts
  exit
end

topdir = ARGV.shift
project = File.basename(File.expand_path(topdir))

asterisk = %w(❄ ✺ ❅ ✽ ✾ ✿ ❁ ❃ ❋ ❀).sample

Dir.chdir topdir do |dir|

  tree_output = `tree`

  txt = []
  txt << (asterisk * 70)
  txt << ""
  txt << "✯ #{project} ✯"
  txt << ""
  txt << (asterisk * 70)

  txt << ""
  txt = txt.map {|l| l + "\n" }.join

  tree_output = txt + tree_output

  files = Dir.glob("**/*").reject {|fn| File.directory?(fn) }
  files.reject! {|file| opt[:exclude].include?(File.expand_path(file)) }

  html_blocks = files.map do |file|
    (text_file = "-l text") if File.extname(file) =~ /\.te?xt/
    name = %Q{<br/><div class="filename">#{file}</div>}
    pdffile = file + ".pdf"
    name + cmd("htmlize.rb #{text_file} -p -f --stdout '#{file}'")
  end

  tree_tmpfile = "treetmp.tmp"
  File.write(tree_tmpfile, tree_output)
  tree_html = cmd "htmlize.rb -p -f -l text --stdout #{tree_tmpfile}"
  File.unlink(tree_tmpfile)

  html_file = "#{project}.html"
  File.write(html_file, html_docify([tree_html, *html_blocks], DATA.read))

  ### GOING TO bREAK CAUSE NO SYNTAX YET 
  cmd "html_to_pdf.rb #{html_file} --nocss"

  File.unlink html_file
end


__END__
.filename { font-weight: bold; margin-left: -5px; margin-top: 15px; font-family: arial; }

.highlight .hll { background-color: #ffffcc }
.highlight  { background: #f8f8f8; }
.highlight .c { color: #408080; font-style: italic } /* Comment */
.highlight .err { border: 1px solid #FF0000 } /* Error */
.highlight .k { color: #008000; font-weight: bold } /* Keyword */
.highlight .o { color: #666666 } /* Operator */
.highlight .cm { color: #408080; font-style: italic } /* Comment.Multiline */
.highlight .cp { color: #BC7A00 } /* Comment.Preproc */
.highlight .c1 { color: #408080; font-style: italic } /* Comment.Single */
.highlight .cs { color: #408080; font-style: italic } /* Comment.Special */
.highlight .gd { color: #A00000 } /* Generic.Deleted */
.highlight .ge { font-style: italic } /* Generic.Emph */
.highlight .gr { color: #FF0000 } /* Generic.Error */
.highlight .gh { color: #000080; font-weight: bold } /* Generic.Heading */
.highlight .gi { color: #00A000 } /* Generic.Inserted */
.highlight .go { color: #808080 } /* Generic.Output */
.highlight .gp { color: #000080; font-weight: bold } /* Generic.Prompt */
.highlight .gs { font-weight: bold } /* Generic.Strong */
.highlight .gu { color: #800080; font-weight: bold } /* Generic.Subheading */
.highlight .gt { color: #0040D0 } /* Generic.Traceback */
.highlight .kc { color: #008000; font-weight: bold } /* Keyword.Constant */
.highlight .kd { color: #008000; font-weight: bold } /* Keyword.Declaration */
.highlight .kn { color: #008000; font-weight: bold } /* Keyword.Namespace */
.highlight .kp { color: #008000 } /* Keyword.Pseudo */
.highlight .kr { color: #008000; font-weight: bold } /* Keyword.Reserved */
.highlight .kt { color: #B00040 } /* Keyword.Type */
.highlight .m { color: #666666 } /* Literal.Number */
.highlight .s { color: #BA2121 } /* Literal.String */
.highlight .na { color: #7D9029 } /* Name.Attribute */
.highlight .nb { color: #008000 } /* Name.Builtin */
.highlight .nc { color: #0000FF; font-weight: bold } /* Name.Class */
.highlight .no { color: #880000 } /* Name.Constant */
.highlight .nd { color: #AA22FF } /* Name.Decorator */
.highlight .ni { color: #999999; font-weight: bold } /* Name.Entity */
.highlight .ne { color: #D2413A; font-weight: bold } /* Name.Exception */
.highlight .nf { color: #0000FF } /* Name.Function */
.highlight .nl { color: #A0A000 } /* Name.Label */
.highlight .nn { color: #0000FF; font-weight: bold } /* Name.Namespace */
.highlight .nt { color: #008000; font-weight: bold } /* Name.Tag */
.highlight .nv { color: #19177C } /* Name.Variable */
.highlight .ow { color: #AA22FF; font-weight: bold } /* Operator.Word */
.highlight .w { color: #bbbbbb } /* Text.Whitespace */
.highlight .mf { color: #666666 } /* Literal.Number.Float */
.highlight .mh { color: #666666 } /* Literal.Number.Hex */
.highlight .mi { color: #666666 } /* Literal.Number.Integer */
.highlight .mo { color: #666666 } /* Literal.Number.Oct */
.highlight .sb { color: #BA2121 } /* Literal.String.Backtick */
.highlight .sc { color: #BA2121 } /* Literal.String.Char */
.highlight .sd { color: #BA2121; font-style: italic } /* Literal.String.Doc */
.highlight .s2 { color: #BA2121 } /* Literal.String.Double */
.highlight .se { color: #BB6622; font-weight: bold } /* Literal.String.Escape */
.highlight .sh { color: #BA2121 } /* Literal.String.Heredoc */
.highlight .si { color: #BB6688; font-weight: bold } /* Literal.String.Interpol */
.highlight .sx { color: #008000 } /* Literal.String.Other */
.highlight .sr { color: #BB6688 } /* Literal.String.Regex */
.highlight .s1 { color: #BA2121 } /* Literal.String.Single */
.highlight .ss { color: #19177C } /* Literal.String.Symbol */
.highlight .bp { color: #008000 } /* Name.Builtin.Pseudo */
.highlight .vc { color: #19177C } /* Name.Variable.Class */
.highlight .vg { color: #19177C } /* Name.Variable.Global */
.highlight .vi { color: #19177C } /* Name.Variable.Instance */
.highlight .il { color: #666666 } /* Literal.Number.Integer.Long */
