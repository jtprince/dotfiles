#!/usr/bin/env ruby

Flake8Error = Struct.new(:filename, :row, :col, :code)

errors = ARGV.map do |line|
  p line
  if line.size > 0
    file_and_loc, error_code, error_desc = lines.split(' ', 3)
    Flake8Error.new(*file_and_loc.split(':'), error_code)
  end
end.compact

p errors
