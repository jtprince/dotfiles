#!/usr/bin/env ruby

require 'taglib'
require 'fileutils'

require 'taglib'

alb_to_file = ARGV.group_by do |file|
  TagLib::FileRef.open(file) {|fileref| fileref.tag.album }
end

alb_to_file.each do |alb, file|
  FileUtils.mkdir alb 
  FileUtils.mv file, alb
end
