#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "`basename $0` <outfile.mp3>"
    exit 0
fi

#  http://stackoverflow.com/questions/2968417/compressing-voice-with-mp3
# going to need to revamp this to make it work better
# it does not appear that a 
# -V 9 –vbr-new -mm -h -q 0

# this is a suboptimal solution!!!

ffmpeg -f alsa -ac 2 -i pulse -codec:a libmp3lame -qscale:a 9 -y $1

# need to look more into how to use opus codec

# the reason we don't just use a simple bash command is because nobody has
# figured out how to not get the last of the recording clipped!
# e.g., if I run:
# arecord -q -f cd -t raw | lame -r -V 9 - $1
# then it always chops the last second or so because lame is killed before
# http://linux-speakup.org/pipermail/speakup/2000-August/001624.html
#
#Well I give up!

#I have spent the day reading about subshells and trapping the kill signal,
#and experimenting with same, and have not been able to successfully
#interrupt only the "arecord" process leaving "lame" to finish processing
#data sent to it through a pipe.

#This is really not a proper thread for this list, but if anyone has been
#able to do that, I would appreciate knowing how. Meanwhile I will just
#contine to arecord to a file and then as a second and subsequent task I
#will process that file with "lame".  Every variation of piping I have
#tried always loses the last few seconds of data.

#Off it goes to the back burner! 

#Chuck.

# this didn't really work well...
#require 'shellwords'

#if ARGV.size == 0
  #puts "usage: #{File.basename($0)} <outfile.mp3>"
  #puts "terminate with <Ctrl-C>"
  #exit
#end

#outfile = Shellwords.escape(ARGV.shift)

#begin
  #pid = fork { exec "arecord -q -f cd -t raw | lame -r -V 9 - #{outfile}" }
  #loop do
  #end
#rescue SystemExit, Interrupt
  #sleep 7
  #Process.kill('SIGINT', pid)
#end
