#!/usr/bin/ruby -w
require 'open-uri'

open('http://www.whatismyip.com/automation/n09230945.asp') do |x|
  puts x.read
end
