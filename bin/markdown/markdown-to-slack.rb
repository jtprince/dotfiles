#!/usr/bin/env ruby

# gem install redcarpet
require 'redcarpet'

class SlackRenderer < Redcarpet::Render::Base
  @@list_cnt = 0

  def block_quote(quote)
    %(\n    #{quote}\n)
  end

  def block_code(code, language)
    %(```\n#{code}```)
  end

  def block_html(raw_html)
    raw_html
  end

  def footnotes(content)
    "footnotes:\n#{content}"
  end

  def footnote_def(content, number)
    "#{number}. #{content}"
  end

  def header(text, header_level)
    hyphenation = "-" * (header_level-1)
    %(\n*#{hyphenation}> #{text} <#{hyphenation}*\n)
  end

  def hrule()
    %(\n#{"-"*40}\n)
  end

  def list(contents, list_type)
    @@list_cnt = 0
    "\n#{contents}\n"
  end

  def list_item(text, list_type)
    case list_type
    when :ordered
      @@list_cnt += 1
      "#{@@list_cnt}. #{text}"
    when :unordered
      "* #{text}"
    else
      abort "unrecognized list_type #{list_type}"
    end
  end

  def paragraph(text)
    "\n#{text}\n"
  end

  def table(header, body)
    "#{header}\n#{body}"
  end

  def table_row(content)
    content
  end

  def table_cell(content, alignment)
    "|#{content}|"
  end

  def autolink(link, link_type)
    link
  end

  def codespan(code)
    "`#{code}`"
  end

  def double_emphasis(text)
    "*#{text}*"
  end

  def emphasis(text)
    "*_#{text}_*"
  end

  def image(link, title, alt_text)
  end

  def linebreak()
    "\n"
  end

  def link(link, title, content)
    content + " (#{link})"
  end

  def raw_html(raw_html)
    raw_html
  end

  def triple_emphasis(text)
    "_*#{text}*_"
  end

  def strikethrough(text)
    "~#{text}~"
  end

  def superscript(text)
    text
  end

  def underline(text)
    "\_#{text}\_"
  end

  def highlight(text)
    ">#{text}<"
  end

  def quote(text)
    "“#{text}”"
  end

  def footnote_ref(number)
    number
  end

end

markdown = Redcarpet::Markdown.new(SlackRenderer, fenced_code_blocks: true)

ARGV.each do |filename|
  contents = IO.read(ARGV.shift)
  puts markdown.render(contents)
end
