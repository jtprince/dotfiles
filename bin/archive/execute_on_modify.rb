#!/usr/bin/env ruby

# requires rb-inotify (will only work on linux)
require 'rb-inotify'

substitute = '{{}}'
div = '--'

if ARGV.size < 2
  prog = File.basename(__FILE__)
  puts "usage: #{prog} <file> <command>"
  puts "usage: #{prog} <file> ... #{div} <command>"
  puts "executes the command when a file is modified"
  puts "substitutes \"#{substitute}\" with the name of the file modified"
  exit
end

files, command = 
  if ARGV.include?(div)
    dash_i = ARGV.index {|arg| arg == div }
    files = ARGV[0...dash_i]
    command = ARGV[(dash_i+1)..-1]
    [files, command]
  else
    [[ARGV.shift], ARGV.to_a]
  end

notifier = INotify::Notifier.new

files.each do |file|
  notifier.watch(file, :modify) do |event|
    command.map! do |arg|
      arg.gsub(substitute, event.absolute_name)
    end
    system *command
  end
end

notifier.run
