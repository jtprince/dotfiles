#!/usr/bin/env ruby

# DO NOT DELETE, RENAME, or MOVE since relied on by other scripts

require 'shellwords'

unless `which unoconv`.size > 0
  puts "sudo apt-get install unoconv"
  puts "sudo pacman -S unoconv"
  exit
end

def usage(ext='.pdf')
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
end

def convert_cmd(file, ext, opts, verbose=false)
  # ext = 'pdf'
  cmda = []
  cmda << "unoconv"
  cmda << "-f #{ext}"
  cmda << Shellwords.escape(file)
  cmda << "> /dev/null 2>&1" unless verbose
  cmda.push(*opts)
  cmda.join(" ")
end

# returns [filenames, opts, verbose]
def parse_argv(argv)
  (opts, filenames) = argv.partition {|arg| arg[0,2] == '--' }
  (verbose, opts) = opts.partition {|opt| opt[2..-1] == "verbose" }
  verbose = (verbose.size > 0)
  opts.map! {|opt| "-e #{opt[2..-1]}" }
  [filenames, opts, verbose]
end
