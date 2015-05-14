#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} logout|lock"
  exit
end

case ARGV.shift
when 'logout'
  system "gnome-session-save --logout &"
when 'lock'
  system "gnome-screensaver-command --lock &"
end
