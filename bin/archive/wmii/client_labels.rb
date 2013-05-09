#!/usr/bin/ruby


see = %w(label props tags)

`wmiir ls /client/`.split("\n").select {|v| v =~ /^0x/ }.each do |id|
  id = id.chop
  puts "********* #{id} *********"
  see.each do |cat|
    guy = "/client/#{id}/#{cat} :  "
    puts(guy + `wmiir read #{guy}`)
  end
end

