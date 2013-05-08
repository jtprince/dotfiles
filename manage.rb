#!/usr/bin/env ruby

$LOAD_PATH.unshift __dir__ + "/lib"

require 'linker'
require 'optparse'

default_cmd = 'update'

opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <cmd>"
  op.separator "install"
  op.separator "update"
end
opts.parse!

if ARGV.size == 0
  exit
end

cmd = ARGV.shift || default_cmd

eval __dir__ + '/linksrc'

case cmd
when 'install'
when 'update'
end

