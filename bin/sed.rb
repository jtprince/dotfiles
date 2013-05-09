#!/usr/bin/env ruby

#SEARCH = /require ['"]ms\//
#REPLACE = "require 'mspire/"

SEARCH = /module MS/
REPLACE = "module Mspire"

ext = ".sed.rb.tmp"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} file ..."
  puts "modifies the given files given search and replace"
  puts "(this is for tough jobs hard to specify on the commandline)"
  puts "currently, you are doing this replacement (per line): "
  puts ""
  puts "SEARCH: #{SEARCH.inspect}"
  puts "REPLACE: #{REPLACE.inspect}"
end

ARGV.each do |file|
  puts "#{file}"
  st = File.stat(file)
  tmpfile = file + ext
  if File.exist?(tmpfile) then puts("Tempfile #{tmpfile} already exists! Delete it or move it before running again."); exit end
  #File.open(tmpfile, "wb") do |out|
  File.open(tmpfile, "w") do |out|
    File.open(file) do |infile|
      infile.each_line do |line|
        out.print( line.gsub(SEARCH, REPLACE) ) 
      end
    #out.print( fh.binmode.read.gsub(/\r/, '') )
    end
  end
  File.delete file
  File.rename(tmpfile, file)
  File.chmod(st.mode, file) 
  File.chown(st.uid, st.gid, file) 
end
