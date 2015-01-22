#!/usr/bin/env ruby

require 'securerandom'

def word(words)
  words.sample.chomp.gsub("'",'')
end

hashlength = 10
special = '!@#$%^&*()'.each_char.to_a
dict = '/usr/share/dict/words'
unless File.exist?(dict)
  abort "need: #{dict}\nyaourt -S words"
end

words = IO.readlines(dict)

WORD_LENGTH = 5

def randomize_case(word)
  word.chars.map {|char|
    char.send(rand(2) == 1 ? :upcase : :downcase)
  }.join
end

passwd =
  SecureRandom.base64(6) +
  special.sample +
  randomize_case(word(words)[0,WORD_LENGTH]) +
  special.sample +
  SecureRandom.base64(6) +
  randomize_case(word(words)[0,WORD_LENGTH])

len = ARGV[0] || passwd.size
puts passwd[0,len.to_i]
