#!/usr/bin/env ruby

require 'optparse'

opt = {}
opts = OptionParser.new do |op|
  banner = "usage: #{File.basename(__FILE__)} [-r] i3|wmii|metacity"
  op.on("-r", "--replace", "will try to replace the current manager and not just gconf") {|v| opt[:replace] = v }
end
opts.parse!

if ARGV.size != 1
  puts opts
  exit
end

cmds = []
wm = ARGV.shift
cmds << "gconftool-2 -s /desktop/gnome/session/required_components/windowmanager #{wm} --type string"

show_desktop_background = (wm == 'metacity')
cmds.push( "gconftool-2 -s /apps/nautilus/preferences/show_desktop --type bool #{show_desktop_background}", "gconftool-2 -s /desktop/gnome/background/draw_background --type bool #{show_desktop_background}" )

puts "EXECUTING:"
cmds.each do |cmd|
  puts cmd
  system cmd
end

if opt[:replace]
  replacement = 
    case wm
    when 'wmii' ; 'metacity'
    when 'metacity' ; 'wmii'
    end

  system "killall #{replacement}"
  system wm
end
