#!/usr/bin/ruby

require 'optparse'

opts = OptionParser.new do |op|
end

opts.parse!


now = Time.now.strftime("%Y-%m-%d")

if ARGV.size != 4
  puts "usage: #{File.basename(__FILE__)} url base_file cron_code minutes"
  puts ""
  puts "sets up a cron job to record for so many minutes."
  puts "records the stream to \"base_file-YYYY-MM-DD.mp3\" via a wav"
  puts ""
  puts "example:"
  puts "#{File.basename(__FILE__)} \"mms://live.cumulusstreaming.com/KSOO-AM\" \\"
  puts "\"$HOME/Music/DR_LAURA/show cron_code minutes\" \"5 22 * * 1-5\" 175"
  puts "*   *   *   *   *  command to be executed"
  puts "|   |   |   |   |"
  puts "|   |   |   |   +----- day of week (0 - 6) (Sunday=0)"
  puts "|   |   |   +------- month (1 - 12)"
  puts "|   |   +--------- day of month (1 - 31)"
  puts "|   +----------- hour (0 - 23)"
  puts "+------------- min (0 - 59)"
  exit
end






