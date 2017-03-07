#!/usr/bin/ruby

require 'find'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} path1 ..."
  puts "finds all 'TODO' tags recursively in paths and prints to STDOUT"
  puts "(avoids .git directories)"
  exit
end


paths = ARGV.to_a

Find.find(*paths) do |path|
  if path =~ /\.git/ then Find.prune end
  unless File.directory?(path)
    IO.readlines(path).each do |line|
      if m = line.match(/TODO:? ?/)
        puts "#{path}: #{m.post_match}"
      end
    end
  end
end

