#!/usr/bin/ruby

normal_file_permissions = 0644
normal_dir_permissions = 0755

require 'optparse'
require 'find'

$dirs = false
$files = false
$recurse = false
$save_exec = false
$skip_exec = false

opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] files"
  op.on("-d", "--dir", "755 (rwxr-x-r-x) only for directories") {|v| $dirs = true }
  op.on("-f", "--files", "644 (rw-r---r--) only for directories") {|v| $files = true }
  op.on("-r", "--recurse", "recurses if encountering a subdirectory") {|v| $recurse = true }
  #op.on("-X", "--save-exec", "don't change executable status") {|v| $save_exec = true }
  op.on('-s', "--skip-exec", "just skips executable files") {|v| $skip_exec = true }
end

opts.parse!

if (!$dirs && !$files) or ARGV.size == 0
  puts opts.to_s
  exit
end

files = ARGV.to_a

if $recurse
  new_file_list = []
  files.each do |file|
    new_file_list << file
    if FileTest.directory? file
      Find.find(file) do |path|
        new_file_list.push(path) unless path == '.'
      end
    end
  end
  files = new_file_list
end
  
(dirs, files) = files.partition {|file| FileTest.directory? file }

if $dirs
  File.chmod(normal_dir_permissions, *dirs)
end

if $files
  if $save_exec
    raise NotImplementedError
  end
  if $skip_exec
    (executables, normal_files) = files.partition {|file| File.stat(file).executable? }
    files = normal_files  
  end
  File.chmod(normal_file_permissions, *files)
end







