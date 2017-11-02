#!/usr/bin/env ruby

# run like this:
#  flake8 . | flake8-fix-blank-lines.rb

Flake8Error = Struct.new(:filename, :row, :col, :code, :text) do
  def blank_line_data
    parts = self.text.split(/\s+/)
    [parts[1].to_i, parts[-1].to_i]
  end
end

errors = ARGF.map do |line|
  if line.size > 0
    file_and_loc, error_code, error_desc = line.chomp.split(' ', 3)
    filename, row, col = file_and_loc.split(':')
    Flake8Error.new(filename, row.to_i, col.to_i, error_code, error_desc)
  end
end.compact

blank_line_errors = errors.select {|error| error.code == 'E302' }


BLANK_LINE = "\n"

blank_line_errors.each do |error|
  lines = IO.readlines(error.filename)
  expected, found = error.blank_line_data
  # right now we only do insertions (just need to figure out deletions)
  if expected > found
    num_insertions = expected - found
    to_insert = BLANK_LINE * num_insertions
    lines.insert(error.row - 1, to_insert)
    File.write(error.filename, lines.join)
  else
    puts "Don't yet handle deletions, sorry!"
    p error.text
  end
end
