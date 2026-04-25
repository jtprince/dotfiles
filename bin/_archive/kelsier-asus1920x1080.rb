#!/usr/bin/env ruby


device_lines = `xrandr`.split("\n").select {|line| line =~ /^\w.*connected/ }

# with kelsier, the devices show up as eDP-1 or sometimes as eDP1
devices = device_lines.map {|line| line.split(/\s/).first }

dp_devices = devices.select {|device| device =~ /^DP-?\d/ }
dp3 = dp_devices.pop


def off(device)
  "--output #{device} --off"
end

def on(device, resolution)
    "--output #{device} --primary --mode #{resolution} --pos 0x0 --rotate normal"
end

cmd = [
  'xrandr',
  on(dp3, "1920x1080"),
  off(devices.first),
  *dp_devices.map {|dp_device| off(dp_device) }
].join(' ')

`#{cmd}`

`randomise-bkg`
`xmodmap ~/.config/xmodmap`
