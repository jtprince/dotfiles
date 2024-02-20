#!/usr/bin/env ruby

outfile = "record_window.mpg"
File.delete(outfile) if File.exist?(outfile)

reply = `xwininfo`
dims = %w(Width Height).map do |term|
  reply[/#{term}: (\d+)/, 1].to_i
end
dims.map! {|dim| (dim % 2 == 0) ? dim : dim-1 }

corners = reply[/Corners: (.*)/, 1].split(' ')[0].gsub(/[\+\-]/,' ').strip.split

#cmd = "ffmpeg -f alsa -i pulse -f x11grab -r 30 -s #{dims[0]}x#{dims[1]} -i :0.0+#{corners[0]},#{corners[1]} #{outfile}"
cmd = "ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s #{dims[0]}x#{dims[1]} -i :0.0+#{corners[0]},#{corners[1]} -acodec pcm_s16le #{outfile}"
#cmd = "ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s #{dims[0]}x#{dims[1]} -i :0.0+#{corners[0]},#{corners[1]} -acodec pcm_s16le -vcodec libx264 -vpre lossless_ultrafast -threads 0 output.mkv"
##cmd = "ffmpeg -f alsa -ac 2 -i pulse -f x11grab -r 30 -s #{dims[0]}x#{dims[1]} -i :0.0+#{corners[0]},#{corners[1]} -acodec pcm_s16le -vcodec libx264 -crf 0 -preset ultrafast -threads 0 output.mkv"
puts cmd
system cmd

"ffmpeg -i output.mkv -acodec libmp3lame -ab 128k -ac 2 -vcodec libx264 -vpre slow -crf 22 -threads 0 our-final-product.mp4"
