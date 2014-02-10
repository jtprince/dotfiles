#!/usr/bin/env ruby

begin
  require 'redcarpet'
rescue LoadError
  abort 'You need to install redcarpet to use this guy!'
end
# see http://stackoverflow.com/questions/373002/better-ruby-markdown-interpreter
# (and read the Updates!)

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.mkd ..."
  puts "outputs <file>.html"
  exit
end

def wrap_in_html_body(text)
  "<html><body>" + 
    text + 
  "</body><html>"
end

# explain options:
# https://github.com/vmg/redcarpet 

ARGV.each do |file|
  base = file.chomp(File.extname(file))
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
                                     #autolink: true, 
                                     #space_after_headers: true, 
                                     #fenced_code_blocks: true, 
                                     #tables: true,
                                     #superscript: true,
                                     #hard_wrap: true, 
                                     #quote: true,
                                    )

  html = wrap_in_html_body markdown.render(IO.read(file, encoding: 'UTF-8'))
  File.write(base + '.html', html)
end
