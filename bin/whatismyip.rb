#!/usr/bin/ruby -w
require 'open-uri'

url = 'http://bot.whatismyipaddress.com'
open(url) {|x| puts x.read }
