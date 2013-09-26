#!/usr/bin/env ruby

require 'optparse'

module Enumerable
  # File activesupport/lib/active_support/core_ext/enumerable.rb, line 34
  def index_by
    if block_given?
      Hash[map { |elem| [yield(elem), elem] }]
    else
      to_enum :index_by
    end
  end
end

Mounted = Struct.new(:name, :majmin, :removable, :sz, :ro, :type, :mountpoint) do
  # e.g., "sdb"
  def devname
    name.sub(/\d+/,'')
  end

  def drivename
    File.basename(mountpoint)
  end
end

Drive = Struct.new(:devname, :disk, :partitions) do
  def unmount_partitions
    partitions.each do |partition|
      run "udisks --unmount #{Shellwords.escape(partition.mountpoint)}"
    end
    @unmounted = true
  end

  def eject
    unmount_partitions unless @unmounted
    run "udisks --detach #{Shellwords.escape(devname)}"
  end
end

def confirm_removal(mounted_device)
  puts "Would you like to remove #{mounted_device.name}?  [ENTER]"
  gets.chomp == ''
end

def run(cmd)
  puts cmd
  #system cmd
end

def get_removable_drives
  lines = `lsblk -i`.split("\n").map(&:chomp)

  lines.shift
  mounted_devs = lines.map do |line|
    mounted = Mounted.new( *line.split(/\s+/) )
    mounted.removable = (mounted.removable == '0' ? false : true)
    mounted.name = mounted.name.gsub(/[\|\`\-]/, '')
    mounted
  end

  partitions = mounted_devs.select {|md| md.type == 'part' }
  disks = mounted_devs.select {|md| md.type == 'disk' }
  disk_by_devname = disks.index_by(&:name)

  drives = partitions.group_by(&:devname).map do |devname, partitions|
    Drive.new devname, disk_by_devname[devname], partitions
  end
  drives.select {|drive| drive.disk.removable }
end

def list_removable_drives
  p get_removable_drives
end

parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <part of name of drive>"
  op.separator "safely removes the device (must be removable)"
  op.on("-l", "--list", "lists removable drives and exits") { list_removable_drives ; exit }
end
parser.parse!

if ARGV.size == 0
  puts parser
  exit
end

string = ARGV.shift
regexp = Regexp.new( string )


drives = get_removable_drives
usb_stick = drives.find do |drive|
  drive.partitions.any? {|part| part.drivename[regexp] }
end

unless usb_stick
  puts "couldn't find match to: #{regexp.inspect}"
  puts "among: "
  list_removable_drives
  exit
end

if confirm_removal usb_stick
end
