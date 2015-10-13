#!/usr/bin/env ruby

windowid, number = ARGV

unless windowid
  abort "usage: #{File.basename(__FILE__)} <windowid> [numtimes]"
end

number ||= 30
number = number.to_i

PAUSE = 0.3

def xdo(*actions)
  `xdotool #{actions.join(" ")}`
  sleep PAUSE
end

def key(name)
  xdo 'key', name
end

xdo 'windowfocus', windowid

date = Time.now.strftime("%Y-%m-%d")
playlist = "/home/jtprince/spotify-#{date}.playlist"

number.times do
  key 'Menu'
  4.times { key 'Down' }
  key 'KP_Enter'

  `xclip -o >> #{playlist}`
  `echo "" >> #{playlist}`
  #key 'Escape'
  key 'Down'
end

