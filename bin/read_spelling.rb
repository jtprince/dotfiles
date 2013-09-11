#!/usr/bin/env ruby

require 'shellwords'
pdfcmd = 'pdftotext'
espeak = 'espeak'

def speak(string, speed=130, amplitude=18)
  system "espeak -v en-us -a #{amplitude} -s #{speed} #{Shellwords.escape(string)}"
end

SpellingWord = Struct.new(:number, :word, :review_word, :challenge_word) do
  def say(speeds=[130, 80])
    if review_word
      speak "review word", 180 
    end
    if challenge_word
      speak "challenge word", 180
    end
    speak "number #{number}", 170
    speeds.each do |speed|
      speak word, speed
      sleep 0.2
    end
  end
end

# takes output of mr. Jenning's spelling words piped through pdftotext
def get_spelling_words(file)
  lines = IO.readlines(file).map(&:chomp)
  review_word = false
  challenge_word = false
  words = []
  lines.each do |line|
    if md=line.match(/\A(\d+)\.\s+(\w+)\Z/)
      (num, word) = md.captures
      words << SpellingWord.new(num, word, review_word, challenge_word)
    elsif line.match(/\AReview Words/)
      review_word = true
      challenge_word = false
    elsif line.match(/\AChallenge Words/)
      challenge_word = true
      review_word = false
    end
  end
  words
end

pdffile = ARGV.shift

unless pdffile
  puts "usage: #{File.basename(__FILE__)} <spellinglist>.pdf"
  exit
end

base = pdffile.chomp(File.extname(pdffile))
txtfile = base + ".txt"

system pdfcmd, pdffile

words = get_spelling_words(txtfile)

words.each do |word|
  word.say
  sleep 1
end
