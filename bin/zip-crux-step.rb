#!/usr/bin/env -S ruby -W0

def is_src_dir?(dir)
  File.basename(dir) == 'src'
end

def is_action_wrapper_dir?(dir)
  File.basename(dir).start_with?("_")
end

# assumes you are in src dir
def get_directory_above_src()
  Dir.pwd.split('/')[-2]
end

# Assumes in the action wrapper dir
# Always positions location in the action wrapper directory at finish
def make_zip_file
  action_dir = File.basename(Dir.pwd)
  begin
    Dir.chdir("src")
  rescue Exception => exc
    puts "==> Error in #{action_dir}: Missing the 'src' directory!"
    return nil
  end

  begin
    raise "Couldn't find the src directory! (cd into it or give arg!)" unless is_src_dir?(Dir.pwd)

    if Dir["_*.json"].size > 1
      raise "Multiple feed definition files!"
    end

    if Dir["_*.json"].size == 0
      raise "Missing feed definition file!"
    end

    if Dir["*.json"].size >= 2
      raise "Will not run with 2 or more .json files in src dir!"
    end

    if Dir["*.*"].size > 2
      raise "More than two files in your src dir!"
    end

    zip_filename =  "#{get_directory_above_src}.zip"
    `zip #{zip_filename} *.*`

    full_zipfilename = File.join(Dir.pwd, zip_filename)
    `mv #{full_zipfilename} ../`

    parts = full_zipfilename.split('/')
    new_filename = parts.reverse.reject {|part| part == 'src' }.reverse.join("/")
    new_filename
  rescue Exception => exc
    puts "==> Error in #{action_dir} #{exc}"
    nil
  ensure
    Dir.chdir("../")
  end
end


paths = ARGV.to_a.dup

zip_files = []
if paths.size == 0
  if is_action_wrapper_dir?(Dir.pwd) || is_src_dir?(Dir.pwd)
    if is_src_dir?(Dir.pwd)
      Dir.chdir("../")
    end
    zip_files << make_zip_file
  else
    # populate paths with all action directories
    paths = Dir["_*"].select {|fn| File.directory?(fn) }
  end
end

paths.each do |path|
  Dir.chdir(path) do
    zip_files << make_zip_file
  end
end

zip_files.compact.each do |zip_file|
  puts "CREATED: #{zip_file}"
end
