#!/usr/bin/ruby

require 'optparse'
require 'date'
require 'fileutils'

dest = '/media/EXTERNAL_80GB/FORTIUS_BACKUP/'

unless `groups` =~ /root/
  abort "you must be root to run this!"
end

opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} [OPTIONS] test|go"
end

opts.parse!

if ARGV.size != 1
  puts opts.to_s
  exit
end

no_tar = %w(DIGITAL_CAMERA IMAGES_misc SCANS VIDEOS WEB_CAM)

base_dirs = %w(DIGITAL_CAMERA IMAGES_misc melissa SCANS VIDEOS WEB_CAM)
home_dirs = base_dirs.map {|v| '/home/' + v }

dt = Date.today
dest_path = dest + [dt.year, dt.mon, dt.day].join("-")

just_testing = 
  case ARGV.shift
  when 'test'
    true
  when 'go'
    false
  else
    abort "must be 'test' or 'go'"
  end


def run_cmds(stack, testing=true)
  stack.each do |cmd|
    if testing
      if cmd.is_a? Proc
        puts "Would run lambda: #{cmd.to_s}"
      else
        puts "Would run: #{cmd}"
      end
    else
      if cmd.is_a? Proc
        puts "Running: #{cmd}"
        cmd.call
      else
        puts "Running: #{cmd}"
        puts `#{cmd}`
      end
    end
  end
  stack.clear
end

cmd_stack = []
cmd_stack.push(lambda { FileUtils.mkpath dest_path })
run_cmds(cmd_stack, just_testing)


Dir.chdir("/home") do |dir|
  base_dirs.each do |bdir|
    puts "***************************: #{bdir}"
    if no_tar.include?(bdir)
      cmd_stack.push("cp -r #{bdir} #{dest_path}")
      run_cmds(cmd_stack, just_testing)
    else
      tgz = "#{bdir}.tgz"
      cmd_stack.push("tar -czf #{tgz} #{bdir}")
      cmd_stack.push( lambda { FileUtils.mv tgz, dest_path } )
      run_cmds(cmd_stack, just_testing)
    end
  end
end
