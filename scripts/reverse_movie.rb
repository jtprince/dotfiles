#!/usr/bin/ruby -w

require 'fileutils'
require 'optparse'


$fps = 30
$just_reverse_names = false
$split = true
$join = true
$reverse = true
opts = OptionParser.new do |op|
	op.banner = "usage: #{File.basename(__FILE__)} [-r FPS] <moviefile> ..."
  op.separator "reverses the movies and outputs <moviefile>.reverse.mp4"
  op.on("-r", "--r <fps>", "frames per second (default: #{$fps})") {|v| $fps = v }
  op.on("--reverse-names", "takes images and reverses their names") {|v| $just_reverse_names = v }
  op.on("--split", "just splits up a movie") {|v| $join = false ; $reverse = false }
  op.on("--join", "just joins the frames in given dir") {|v| $split = false ; $reverse = false }
end

opts.parse!


if ARGV.size == 0
  puts opts.to_s
	exit
end

# http://electron.mit.edu/~gsteele/ffmpeg/
# http://ubuntuforums.org/showthread.php?t=688095&page=2

# system "ffmpeg -i 100_4039.MOV -r 30 -f image2 images%05d.png"

#  puts "ffmpeg -i #{file} -r #{bit_rate} -f image2 images%05d.png"
#  puts `ffmpeg -i images%05d.png -r #{bit_rate} output.`

def run(*argv)
  to_run = argv.join(" ")
  #puts to_run
  system to_run
end

def reverse_names(files)
  tmp_dir2 = 'file_name_tmp_dir'
  FileUtils.mkdir tmp_dir2
  FileUtils.mv files, tmp_dir2
  files.reverse.zip(files) do |last, first|
    FileUtils.mv File.join(tmp_dir2, last), first
  end
  FileUtils.rm_rf tmp_dir2 if File.exist? tmp_dir2
end

if $just_reverse_names
  reverse_names(ARGV.to_a)
else
  ARGV.each do |movie_file|

    movie_file_dirname = File.dirname(movie_file)
    movie_file_base = File.basename(movie_file)
    movie_file_base_noext = File.basename(movie_file, ".*")
    revtag = $reverse ? '.reverse' : ''
    output_movie_file = File.join(movie_file_dirname, movie_file_base_noext + "#{revtag}.mp4")

    tmp_dir = movie_file + '.split'
    #FileUtils.rm_rf tmp_dir if File.exist? tmp_dir

    if $split
      FileUtils.mkdir tmp_dir if $split
      FileUtils.cp movie_file, tmp_dir
    else
      tmp_dir = movie_file
    end

    Dir.chdir(tmp_dir) do
      if $split
        run "ffmpeg -i #{movie_file_base} -r #{$fps} -f image2 images%05d.png"
      end
      if $join
        if $reverse
          files = Dir["images*.png"].sort
          reverse_names(files)
        end
        run "ffmpeg -i images%05d.png -r 30 ../#{output_movie_file}"
      end
    end
    FileUtils.rm_rf tmp_dir unless $split || $join
  end

end
