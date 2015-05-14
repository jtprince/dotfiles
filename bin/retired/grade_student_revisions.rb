#!/usr/bin/env ruby

require 'fileutils'
include FileUtils

def run(*args)
  puts "running: #{args.join(' ')}"
  system *args
end

class String
  def tailnum
    if md=self[-1].match(/(\d)$/)
      md[1].to_i
    end
  end

  def student
    self.split(/[\._\d]/).first
  end
end

# block expects the glob
def search_for_it(dir, seeking_rev, glob)
  Dir.chdir(dir) do |topdir|
    rev_dir = Dir["*"].find {|d| File.directory?(d) && d.tailnum == seeking_rev }

    if rev_dir
      puts "folder found: #{rev_dir}"
      rev_dir_full = File.expand_path(rev_dir)
      Dir.chdir(rev_dir_full) do |rev_dir|
        puts Dir.pwd
        final_glob = rev_dir + "/" + glob
        files = Dir[final_glob]
        file = files.first
        if file
          puts "first file found: #{file}"
          run "acroread", file
        else
          puts "can't find file"
        end
        true
      end
    end
  end
end

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} <file>.pdf"
  puts "looks up 2 dirs until it finds the previous submission"
  puts "opens it in acrobat if available"
  exit
end

file = ARGV.shift

run "pdfxc.sh", file

start_dir = File.expand_path(File.dirname(file))
puts "starting dir: #{start_dir}"
current_rev = start_dir.tailnum
unless current_rev
  start_dir = File.expand_path(start_dir + "/..")
  current_rev = start_dir.tailnum
  abort "no revision information with #{start_dir}" unless current_rev
end

puts "current_revision: #{current_rev}"

seeking_rev = current_rev - 1

puts "seeking_revision: #{seeking_rev}"

student = file.student
puts "looking for student: #{student}"

oneup = start_dir + "/.."
twoup = start_dir + "/.."

if [oneup, twoup].any? do |dir| 
  glob = "#{student}*.pdf"
  search_for_it(dir, seeking_rev, glob)
end
  puts "success"
else
  puts "failure"
end



