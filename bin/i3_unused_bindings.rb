#!/usr/bin/env ruby

config = ENV["HOME"] + "/.config/i3/config"

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} used|unused [config]"
  puts "usage: #{File.basename(__FILE__)} <anything_else=>unused>"
  puts "outputs list of used/unused bindings"
  puts "default config: #{config}"
  exit
end

type = ARGV[0] == 'used' ? :used : :unused
config = ARGV[1] || config

config_s = IO.read(config)
config_lines = IO.readlines(config)

search_and_replace = config_s.scan(%r{^set (\$\w+) ([^\s]+)})

bindings = config_lines.select {|line| line =~ /^bindsym/ }
bindings.map! do |line|
  line.chomp!
  line = search_and_replace.inject(line) do |str, pair|
    str.gsub(*pair)
  end
  line[/^bindsym (.*)/,1]
end

(mod_shift, others) = bindings.partition {|binding| binding =~ /^Mod4\+Shift/ }
(mod_lines, others) = others.partition {|binding| binding =~ /^Mod4/ }

puts "Mod+<letter> available:"
('a'..'z').each do |let|
  taken = mod_lines.any? do |mod| 
    mod.split(' ').first.split('+').last == let
  end
  puts let unless taken
end

puts "Mod+Shift+<letter> available:"
('A'..'Z').each do |let|
  taken = mod_shift.any? do |mod| 
    mod.split(' ').first.split('+').last == let
  end
  puts let unless taken
end