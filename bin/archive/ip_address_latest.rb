#!/usr/bin/ruby -s

require 'open-uri'

def ip_address
  string = open("http://www.whatismyip.com/automation/n09230945.asp") {|fh| fh.read }
  string
end

if $g
  file = 'tech200_ip_address.txt'
  new_name = '/tmp/new_name.txt'
  `scp jtprince@bluemoon.colorado.edu:~/#{file} #{new_name}`
  puts IO.readlines(new_name).first.chomp
else

  hn = `hostname`.chomp

  file = "/tmp/#{hn}_ip_address.txt"
  File.open(file, 'w') do |out|
    out.print(ip_address)
  end
  `scp #{file} jtprince@bluemoon.colorado.edu:~/`
end
