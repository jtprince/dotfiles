#!/usr/bin/env ruby

files = ARGV

ABSOLUTE_BASE = "https://faenrandir.github.io/a_careful_examination"
NEW_EXT = ".permanentlinks.md"

if files.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.md"
  puts "output: <file>#{NEW_EXT}"
  puts
  puts "replaces all '{{ \"/<link>/\" | relative_url }}' with:"
  puts ABSOLUTE_BASE + "/<link>/"

  exit
end

RELATIVE_URL_REGEX = /{{ ['"]([^}]+)['"] \| relative_url }}/

files.each do |file|
  text = IO.read(file)
  replaced_text = text.gsub(RELATIVE_URL_REGEX) do |inside|
    url_path = inside[RELATIVE_URL_REGEX, 1]
    ABSOLUTE_BASE + url_path
  end

  base = file.chomp(File.extname(file))
  outfile = base + NEW_EXT
  File.write(outfile, replaced_text)
end
