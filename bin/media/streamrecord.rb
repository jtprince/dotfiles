#!/usr/bin/ruby

now = sprintf("%04d%02d%02d", *(Time.now.to_a[3..5].reverse))

dir="/home/john/Music/DR_LAURA"
base_file="#{dir}/show_#{now}"
wav_file="#{base_file}.wav"
mp3_file="#{base_file}.mp3"


# 11pm-12am
#"mms://citadelcc-wjr-am.wm.llnwd.net/citadelcc_WJR_AM?MSWMExt=.asf"

#Thread.new do
  cmd = "mplayer -endpos 60 -ao pcm:file=#{wav_file} -vc null -vo null mms://live.cumulusstreaming.com/KSOO-AM"
  system cmd
#end

#sleep(30)

#Thread.stop

#pid=$!;
#echo "kill $pid && lame --preset voice $wav_file $mp3_file && rm $wav_file &" -n | at now + 1 minutes;
#echo "Recording $wav_file and $mp3_file"

#mimms "mms://live.cumulusstreaming.com/KSOO-AM" - | mplayer -vo null -vc dummy -af resample=44100 -ao pcm:waveheader:file=- | lame --preset voice - file.mp3 &


