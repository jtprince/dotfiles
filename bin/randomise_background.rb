#!/usr/bin/env ruby

#File.write("/home/jtprince/randomize_bgk_which_ruby.log", "using ruby: #{RUBY_VERSION} #{RUBY_RELEASE_DATE} #{`which ruby`}")

BKG_DIR = ENV['HOME'] + '/Dropbox/backgrounds'
EXTS = %w(png jpg)

files_w_ext = Dir[*EXTS.map {|ext| BKG_DIR + "/*.#{ext}" }]

bkg_prog = 
  if `which feh`.size > 0
    'feh --bg-fill'
  elsif `which hsetroot`.size > 0
    'hsetroot -fill'
  else
    abort "need feh or hsetroot to work!"
  end

system "#{bkg_prog} '#{files_w_ext.sample}'"
