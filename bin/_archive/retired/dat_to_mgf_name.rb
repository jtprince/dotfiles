#!/usr/bin/env ruby

if ARGV.size == 0
  puts "usage: #{File.basename($0)} <file>.dat ..."
  puts "output: renames <file>.dat to <mgf_basename>.dat"
  puts "(based on FILE= line in header)"
  exit
end

ARGV.each do |file|
  mgf_basename = nil
  IO.foreach(file) do |line|
    if md=line.match(/^FILE=(.*?)\.\w$/)
      mgf_basename = md[1]
      break
    end
  end
  if mgf_basename
    File.rename(file, mgf_basename + ".dat")
  end
end
