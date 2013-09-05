#!/usr/bin/env ruby

require 'shellwords'
home = ENV['HOME']

source = home + '/Dropbox/481-Fall2013/discussions'
destination = '/media/jtprince/8GB_BLUE/481-Fall2013/discussions'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} regex|all"
  exit
end

def run_verify(cmd)
  puts "Run the following:"
  puts cmd
  puts "  [Y]?"
  reply = gets.chomp
  if reply == '' || reply.upcase == 'Y'
    system cmd
  else
    puts "exiting!"
  end
end

base = "rsync -arzv --delete"
arg = ARGV.shift

if arg == 'all'
  puts "syncing all"
  cmd = [base, Shellwords.escape(source), Shellwords.escape(destination.sub('discussions',''))].join(' ')
  run_verify cmd
else
  topics = Dir[source + "/*"]
  regex = /#{arg}/
  dir = topics.find {|topic| File.basename(topic)[regex] }
  cmd = [base, Shellwords.escape(dir), destination + "/"].join(" ")
  run_verify cmd
end


