#!/usr/bin/env ruby

DIR = ENV["HOME"] + "/Dropbox/Documents/Journal"

FILENAME = "Journal.txt"
ZIPNAME= FILENAME + ".zip"
PASSWORD = "ptjl"  # <- I only want minimal security for this

def save!
  # encrypt and delete unencrypted
  Dir.chdir(DIR) do 
    if File.exist?(FILENAME)
      if system("zip -P #{PASSWORD} #{ZIPNAME} #{FILENAME}") && File.exist?(ZIPNAME)
        File.unlink(FILENAME)
      end
    else
      abort "#{FILENAME} does not exist!"
    end
  end
end

def write!
  system "unzip -P #{PASSWORD} #{ZIPNAME}"
  system "gvim + #{FILENAME}"
  puts "Encrypt now? [Enter=yes]"
  if gets.chomp == ''
    save!
  end
end

Dir.chdir(DIR) do
  puts "changing to #{DIR}"

  case ARGV[0]
  when "-h", "--help"
    puts "usage: #{File.basename($0)}"
    puts "    unzips and opens #{FILENAME} for writing"
    puts "    asks to encrypt on exit"
    puts ""
    puts "usage: #{File.basename($0)} -s|s|save"
    puts "    zips #{FILENAME} into #{ZIPNAME} and deletes #{FILENAME}"
  when "-s", "s", "save"
    save!
  else
    write!
  end
end
