#!/usr/bin/env ruby

require 'optparse'
require 'open3'

opts = {
  keep_lines: false,
  remove_vtt: true,
}

parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <url> ..."
  op.on("--keep-lines", "-n", "keep lines as found in vtt file") {|v| opts[:keep_lines] = true }
  op.on("--no-remove-vtt", "-v", "keep the vtt file around") {|v| opts[:remove_vtt] = false }
end
parser.parse!

urls = ARGV.dup

if urls.size == 0
  puts parser
  exit
end

def vtt_to_paragraph(path, opts)
  is_text_line = false
  text_lines = IO.foreach(path).map do |line|
    if is_text_line
      is_text_line = false
      line.chomp
    elsif line =~ /\A[\d\:\.]+ --> [\d\:\.]+\Z/
      is_text_line = true
      nil
    end
  end.compact
  delimiter = opts[:keep_lines] ? "\n" : " "
  text_lines.join(delimiter)
end

cmd = %w(youtube-dl --skip-download --all-subs -o %(title)s.%(ext)s --restrict-filenames)

urls.each do |url|
  out, err, st = Open3.capture3(*(cmd + [url]))
  subtitle_file_line = out.split("\n").find {|line| line =~ /\[info\] Writing video subtitles to:/ }
  filename_w_quotes = subtitle_file_line.split(': ').last
  filename = filename_w_quotes.gsub('"', '')
  puts "saved cc to: #{filename}"
  basename = filename.chomp(File.extname(filename))
  txt_file = basename + ".txt"
  paragraph = vtt_to_paragraph(filename, opts)
  File.write(txt_file, paragraph)
  if opts[:remove_vtt]
    puts "removing: #{filename}"
    File.unlink filename
  end
  puts "wrote to: #{txt_file}"
end
