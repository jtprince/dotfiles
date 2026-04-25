#!/usr/bin/env ruby

puts `dropbox-index -R '#{File.join( ENV["HOME"], "Dropbox", "Public")}'`
