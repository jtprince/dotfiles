#!/usr/bin/ruby -w

require 'optparse'

$VERBOSE = false

def run(cmd)
  puts "RUNNING: #{cmd}" if $VERBOSE
  reply = `#{cmd}`
  print reply if $VERBOSE
  reply
end

opt = {
  mthd: :gvim,
  lang: :ruby,
}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} file.ext ..."
  op.separator "output: file.ext.html"
  op.separator ""
  op.separator "uses *#{opt[:mthd]}* for syntax highlighting by default"
  op.separator ""
  op.on("-v", "--vim", "use current vim syntax highlighting") {|v| opt[:mthd] = :vim }
  op.on("-b", "--bkg <light/dark>", "sets background") {|v| opt[:bkg] = v }
  # should add support for these in future:
  # coderay
  # ultraviolet
  op.separator ""
  op.on("-p", "--pygmentize", "use pygmentize") {|v| opt[:mthd] = :pygmentize }
  op.on("-f", "--fragment", "just the fragment") {|v| opt[:fragment] = true }
  op.on("-s", "--style <style>", "use pygmentize style or vim colorscheme") {|v| opt[:style] = v }
  op.on("--stdout", "send html to stdout") {|v| opt[:stdout] = v }
  op.on("-l", "--lang <ruby>", "use that language lexer") {|v| opt[:lang] = v }
  op.separator ""
  op.on("-r", "--replace", "replace extension with .html") {|v| opt[:replace] = v }
  op.on("--pdf", "convert to pdf") {|v| opt[:pdf] = v }
  op.on("--verbose", "talk about it") { $VERBOSE = true }
end

opts.parse!

if ARGV.size == 0
  puts opts
  exit
end

ARGV.each do |file|
  outfile = (opt[:replace] ? file.chomp(File.extname(file)) : file) + ".html"
  case m=opt[:mthd]
  when :vim, :gvim
    # I don't seem to be able to set the font on here
    #+"set guifont=Deja\\ Vu\\ Sans\\ Mono\\ 10"
    cmd = [%Q{#{m} -f +"syn on" +"let html_use_css = 1"}]
    cmd << %Q{+"set background=#{opt[:bkg]}"} if opt[:bkg]
    cmd << %Q{+"colorscheme #{opt[:style]}"} if opt[:style]
    cmd << %Q{+"run! syntax/2html.vim" +"w #{outfile}" +"wq" +"q" #{file}}
    run cmd.join(" ")
  when :pygmentize
    args = []
    args << "-f html"
    args << '-O encoding=utf-8'
    args << '-O full' unless opt[:fragment]
    args << '-O style='+opt[:style] if opt[:style]
    args << "-l #{opt[:lang]}"
    (args << "-o '#{outfile}'") unless opt[:stdout]
    args << "'#{file}'"
    print run("pygmentize #{args.join(' ')}")
  end

  if opt[:pdf]
    run "html_to_pdf.rb '#{outfile}'"
    File.unlink outfile
  end
end



