#!/usr/bin/env ruby

edp1_resolution = '3840x2160'

def off(device)
  "--output #{device} --off"
end

def on(device, resolution)
    "--output #{device} --primary --mode #{resolution} --pos 0x0 --rotate normal"
end

device_lines = `xrandr`.split("\n").select {|line| line =~ /^\w.*connected/ }

# with kelsier, the devices show up as eDP-1 or sometimes as eDP1
devices = device_lines.map {|line| line.split(/\s/).first }
edp1_device = devices.first

dp_devices = devices.select {|device| device =~ /^DP-?\d/ }

cmd = [
  'xrandr',
  on(edp1_device, edp1_resolution),
  *dp_devices.map {|dp_device| off(dp_device) }
].join(' ')

`#{cmd}`

`randomise-bkg`
`xmodmap ~/.config/xmodmap`
