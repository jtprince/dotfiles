#!/usr/bin/ruby

abort "usage: randomise_file.rb <file>" if ARGV.size != 1

## shuffle routine modified from "Programming in Ruby" by Dave Thomas and Andy Hunt

# get the lines:
lines = IO.readlines(ARGV[0])

# pick a random line, remove it, and print it
lines.size.times do
  print lines.delete_at(rand(lines.size))
end


