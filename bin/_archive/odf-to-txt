#!/usr/bin/env ruby

require_relative "odf_to_other"

if ARGV.size == 0
  usage '.txt'
  exit
end

(filenames, opts, verbose) = parse_argv(ARGV)

ext = "txt"

filenames.each do |file|
  cmd = convert_cmd(file, ext, opts, verbose)
  puts(cmd) if verbose
  system cmd
end
