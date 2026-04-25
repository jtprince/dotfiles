#!/usr/bin/ruby

require 'rumai'

include Rumai

client_ids.each do |id|
  c = Client.new(id)
  puts "*************************************"
  puts "id: #{id}"
  puts "props: #{c.props.read}"
end
puts "*************************************"
