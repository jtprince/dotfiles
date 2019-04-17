#!/usr/bin/env ruby


ARGV.each do |dir|
  no_trailing_slash = dir.sub(/\/$/, '')
  next if no_trailing_slash.include?('/')
  if File.directory?(no_trailing_slash)
    Dir.chdir(no_trailing_slash) do |inside|
      puts "------INSIDE #{no_trailing_slash}------"
      Dir.glob('*.*').each do |file|
        if file.start_with?(no_trailing_slash)
          puts "xxxx - ALREADY starts with #{no_trailing_slash}: #{file} xxxx"
          next
        end
        new_name = [no_trailing_slash, file].join('__')
        puts "--> #{file} RENAMING #{new_name}"
        File.rename(file, new_name)
      end
    end
  end
end
