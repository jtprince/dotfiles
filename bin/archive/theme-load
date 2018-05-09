#!/usr/bin/env ruby

require 'shellwords'

theme_dir = '/usr/share/themes/'
if ARGV.size == 0
  puts "usage: #{File.basename($0)} <theme>.zip"
  puts "installs to #{theme_dir}"
  exit
end

ARGV.each do |zipfile|
  archive_name = 
    if File.extname(zipfile) =~ %r{.zip$}
      reply = `unzip #{Shellwords.escape(zipfile)}`
      archive_name = nil
      reply.each_line do |line| 
        line.chomp!
        if md = line.match(/creating: ([^\/]+)/)
          archive_name = md[1]
          break
        end
      end
    else
      abort 'not handling yet'
    end
  if archive_name 
    puts "extracted the theme: #{archive_name}" 
  else
    abort 'could not find archive name!'
  end

  cmd = "sudo mv #{Shellwords.escape(archive_name)} #{theme_dir}" 
  puts cmd
  system cmd
end
