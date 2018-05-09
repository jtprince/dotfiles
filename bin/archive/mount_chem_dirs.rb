#!/usr/bin/env ruby

require 'optparse'

MOUNT_ON_STARTUP_HOSTS = %w(prince)

# should maybe have gvfs gvfs-bin gvfs-backends installed

opts = {}
parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} home|lab|all ..."
  op.on("-u", "--umount", "unmount all listed") {|v| opts[:umount] = "-u" }
  op.on("-s", "--startup", "check for correct host on startup") {|v| opts[:startup] = v }
  op.on("-d", "--dry", "just print commands and exit") {|v| opts[:dry] = v }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

exit if opts[:startup] && !MOUNT_ON_STARTUP_HOSTS.include?(`hostname -s`)

research_base = 

dirs = {
  home: ENV['HOME'] + '/.gvfs/jtprince on faculty.chem.byu.edu',
  lab: ENV['HOME'] + '/.gvfs/research on labs.chem.byu.edu/princelab'
}

mounts = {
  home: %w(faculty jtprince),
  lab: %w(labs research)
}

to_mount = 
  if ARGV.first == 'all'
    mounts.keys 
  else
    ARGV.map(&:to_sym)
  end

to_mount.each do |key|
  if File.exist?(dirs[key]) && !opts[:umount] && !opts[:dry]
    puts "already mounted: #{dirs[key]}"
  else
    compname, share = mounts[key]
    cmd = "gvfs-mount #{opts[:umount]} 'smb://WORKGROUP;jtprince@#{compname}.chem.byu.edu/#{share}'"
    puts cmd
    system cmd unless opts[:dry]
  end
end
