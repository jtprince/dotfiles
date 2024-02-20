#!/usr/bin/ruby

# creates a macro that can be run, using my current key strokes, to rotoscope a panel of images
# right now, it works like this:
#   Open up a bunch of gimp images (10-20)
#   line them all up in a column (using wmii)
#   use the paths tool to create a selection of the blade for each image
#     make a rectangular bounding box by clicking 4 times
#     (you don't need to close the box)
#     then use the shortcut for path to selection (Shift-V)
#     to create a selection
#
# run this script to generate your macro (may have this run the macro)
#
# position your terminal just above your panel of images to be scoped
# !! make sure that you have already run the rotoscoping script once
# so that Ctrl-F will repeat the script
#
#

# move down a window (Alt-j)
# repeat the last script Ctrl-f
# save the image (Ctrl-S, enter)
# close the window (Shift-Alt-c)
commands =<<HERE
KeyStrPress Alt_L
KeyStrPress j
KeyStrRelease j
KeyStrRelease Alt_L
Delay 1
KeyStrPress Control_L
KeyStrPress f
KeyStrRelease f
KeyStrRelease Control_L
Delay 3
KeyStrPress Control_L
KeyStrPress s
KeyStrRelease s
KeyStrRelease Control_L
Delay 2
KeyStrPress Return
KeyStrRelease Return
Delay 2
KeyStrPress Control_L
KeyStrPress w
KeyStrRelease w
KeyStrRelease Control_L
Delay 4
HERE

output = 'script-save.macro'

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <count>"
  puts "creates a macro to execute last script, save the image and close"
  puts "output: #{output}"
  exit
end

count = ARGV.shift.to_i
File.open(output, 'w') do |out|
  count.times { out.puts commands }
end

sleep(1)

system "cat #{output} | xmacroplay -d 10 :0"



