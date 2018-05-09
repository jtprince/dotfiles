#!/usr/bin/env ruby

# run like this:
#  flake8 . | flake8-fix-blank-lines.rb

Flake8Error = Struct.new(:filename, :row, :col, :code, :text) do
  # E301, E302
  def blank_line_data
    parts = self.text.split(/\s+/)
    [parts[1].to_i, parts[-1].to_i]
  end

  # E303
  def too_many_blank_lines
    self.text.split(' ').last.gsub(/[\(\)]/,'').to_i
  end
end

errors = ARGF.map do |line|
  if line.size > 0
    file_and_loc, error_code, error_desc = line.chomp.split(' ', 3)
    filename, row, col = file_and_loc.split(':')
    Flake8Error.new(filename, row.to_i, col.to_i, error_code, error_desc)
  end
end.compact

errors_by_filename = errors.group_by(&:filename)

BLANK_LINE = "\n"

#FIX = ['E301', 'E302', 'E303', 'F401']
FIX = ['F401']

def fix_e301(error, lines)
  expected, found = error.blank_line_data
  if expected > found
    num_insertions = expected - found
    to_insert = BLANK_LINE * num_insertions
    lines.insert(error.row - 1, to_insert)
  end
  lines
end

def fix_e302(error, lines)
  fix_e301(error, lines)
end

def fix_e303(error, lines)
  num_to_delete = error.too_many_blank_lines
  num_to_delete.times do
    lines.delete_at(error.row - 2)
  end
  lines
end

def fix_f401(error, lines)
  lines.delete_at(error.row - 1)
  lines
end

errors_by_filename.each do |filename, errors|
  errors_to_fix = errors.select {|error| FIX.include?(error.code) }.sort_by(&:row).reverse
  if errors_to_fix.size > 0
    lines = IO.readlines(filename)
    puts "#{filename}: (#{errors_to_fix.size})"
    errors_to_fix.each do |error|
      puts "#{error.code} at row #{error.row}"
      lines = send('fix_' + error.code.downcase, error, lines)
    end
    File.write(filename, lines.join)
  end
end
