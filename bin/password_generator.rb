#!/usr/bin/env ruby

require 'securerandom'

def word(words)
  words.sample.chomp.gsub("'",'')
end

hashlength = 12
special = '!@#$%^&*()'.each_char.to_a
dict = '/usr/share/dict/words'
unless File.exist?(dict)
  abort "need: #{dict}\nyaourt -S words"
end

words = IO.readlines(dict)

passwd = 
  SecureRandom.base64(6) +
  special.sample +
  word(words) +
  special.sample +
  SecureRandom.base64(6) +
  word(words)

puts passwd
