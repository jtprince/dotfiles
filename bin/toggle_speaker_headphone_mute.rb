#!/usr/bin/env ruby

require 'pp'
# I really shouldn't be having to do this, but I still have issues sometimes

# give it the hash of info
def channel_muted?(hash)
  !!hash['Front Left'].match( /\[off\]\Z/ )
end

# returns a hash of mixer info
def mixer_info
  reply = `amixer -c0`
  lines = reply.split("\n")
  controls = {}
  latest_control = nil
  lines.each do |line|
    if line =~ /\A[^\s]/
      latest_control = line
      controls[line] = {}
    else
      data = line.split(":").map(&:strip)
      data << nil unless data.size == 2
      controls[latest_control].store(*data)
    end
  end
  controls
end

mixer = mixer_info
mixer_by_simple_names = Hash[ mixer.map {|k,v| [ k[/'([^']+)'/,1], v ] }  ]

# mute headphone
`amixer -c0 set Headphone 0% unmute`  # needs to be unmuted for some reason

`amixer -c0 set PCM 100% unmute`

`amixer -c0 set Master 50% unmute`

`amixer -c0 set Speaker 100% unmute`

pp mixer_by_simple_names
