#!/usr/bin/env ruby

if ARGV[0] == 'import'
  `gphoto2 --auto-detect`
  `gphoto2 --get-all-files`
  exit
end

class Pixmap
  def self.sum(filename)
    return File.open(filename) do |io|
      3.times { io.gets } # header
      io.each.map {|line| line.chomp.split(/\s+/).map(&:to_i).reduce(:+) }.reduce(:+)
    end
  end
end


ARGV.each do |file|
  ext = File.extname(file)
  base = file.chomp(ext)
  if ext == '.CR2'
    ppm = base + ".ppm"
    system "convert #{file} -compress none #{ppm}"
    file = ppm
  end
  puts "#{base}: #{Pixmap.sum(file)}"
end
