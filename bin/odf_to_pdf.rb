#!/usr/bin/env ruby

require 'shellwords'
require 'optparse'

unless `which unoconv`.size > 0
  abort "sudo apt-get install unoconv"
end

if ARGV.size == 0
  prog = File.basename(__FILE__)
  puts "usage: #{prog} [OPTS] <file>.od[t|s|p] ..."
  puts ""
  puts "output: <file>.pdf"
  puts ""
  puts "options: --<Option>=<Value>"
  puts "    MUST use '=' notatation"
  puts "see http://wiki.openoffice.org/wiki/API/Tutorials/PDF_export"
  puts "    --verbose  talk about it"
  puts ""
  puts "example:"
  puts "    #{prog} --MaxImageResolution=300 --Quality=88 letter.odt"
  exit
end

(opts, filenames) = ARGV.partition {|arg| arg[0,2] == '--' }
(verbose, opts) = opts.partition {|opt| opt[2..-1] == "verbose" }
verbose = (verbose.size > 0)
opts.map! {|opt| "-e #{opt[2..-1]}" }

filenames.each do |file|
  cmda = []
  cmda << "unoconv"
  cmda << "-f pdf"
  cmda << Shellwords.escape(file)
  cmda << "> /dev/null 2>&1" unless verbose
  cmda.push(*opts)
  cmd = cmda.join(" ")
  puts(cmd) if verbose
  system cmd
end
