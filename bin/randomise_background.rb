#!/usr/bin/env ruby

require 'shellwords'
#File.write("/home/jtprince/randomize_bgk_which_ruby.log", "using ruby: #{RUBY_VERSION} #{RUBY_RELEASE_DATE} #{`which ruby`}")

$VERBOSE = ARGV.delete("-v") ? 3 : nil

BKG_DIR = ENV['HOME'] + '/Dropbox/backgrounds'
EXTS = %w(png jpg)

files_w_ext = Dir[*EXTS.map {|ext| BKG_DIR + "/*.#{ext}" }]

bkg_prog = 
  if `which feh`.size > 0
    # feh is in official repos, so using it
    'feh --bg-fill'
  elsif `which hsetroot`.size > 0
    # putting feh as default since hsetroot seems a little flaky at moment
    # (put into AUR from community)
    'hsetroot -fill'
  else
    abort "need feh or hsetroot to work!"
  end

cmd = "#{bkg_prog} '#{Shellwords.escape(files_w_ext.sample)}'"
puts cmd if $VERBOSE
system cmd
