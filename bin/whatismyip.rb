#!/usr/bin/ruby -w


if ARGV[0] && ARGV[0][0] == 'l'
  if `uname -r` =~ /ARCH/
    reply = `ip addr`.split("\n")
    addr_lines = reply.select do |line|
      line =~ /inet /
    end
    addr_lines.each do |line|
      puts line.split('/').first.strip.split(' ').last
    end
  else
    puts "can't parse this distro ip addr yet"
  end
else
  require 'open-uri'
  url = 'http://bot.whatismyipaddress.com'
  open(url) {|x| puts x.read }
end
