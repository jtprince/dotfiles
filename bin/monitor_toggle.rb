#!/usr/bin/env ruby

monitors = `xrandr`.each_line.map {|l| l[/^(.*)\s+connected/,1] }.compact

cmds = []
[[0,1], [1,0]].each do |prim, sec|
  cmds << ['xrandr', '--output', monitors[prim], '--mode', '1024x768', '--same-as', monitors[sec] ].join(" ")
end

puts "enter a number: "

gets.chomp

