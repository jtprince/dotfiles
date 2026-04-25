#!/usr/bin/ruby


#volume, pitch, duration
def note(*vals)
  system "xset b #{vals.join(' ')}"
  print "\007"
end

`xset b on`

(0..1000).to_a.each do |v|
  note(99, 1.0+Math.sin(v.to_f)*100, 1000)
end

`xset b off`
