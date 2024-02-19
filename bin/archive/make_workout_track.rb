#!/usr/bin/env ruby


class Activity
  attr_accessor :text, :duration

  def self.from_line(line)
    text, duration_str = line.split(" | ")
    duration = duration_str.to_i
    self.new(text, duration)
  end

  def initialize(text, duration)
    @text = text
    @duration = duration
  end
end

lines = DATA.read.split("\n")
activities = lines.map do |line|
  Activity.from_line(line)
end

# convert to mp3 on fly before querying for size and combining
filename_to_duration = activities.each_with_index.map do |activity, index|
  filename = "#{index.to_s.rjust(3, "0")}-espeak.wav"
  `espeak "#{activity.text}" -w #{filename}`
  [filename, `sox --i -D #{filename} 2>&1`.strip.to_f]
end.to_h

# need to create exactly the right amount of silence to plug gaps:
#
# To generate silence for 5.6 seconds:
# sox -n -r8000 -b16 -c1 silence.wav trim 0.0 5.6



__END__
jumping jacks. Go! | 30
Rest. | 10
wall sit. Go! | 30
Rest. | 10
push ups. Go! | 30
Rest. | 10
ab crunches. Go! | 30
Rest. | 10
step ups. Go! | 30
Rest. | 10
squats. Go! | 30
Rest. | 10
tricep dips. Go! | 30
Rest. | 10
plank. Go! | 30
Rest. | 10
high knees. Go! | 30
Rest. | 10
lunges. Go! | 30
Rest. | 10
pushup rotations. Go! | 30
Rest. | 10
left side plank. Go! | 15
right side plank. Go! | 15
