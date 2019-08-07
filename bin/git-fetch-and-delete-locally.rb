#!/usr/bin/env ruby

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)}"

  opts.on("-f", "--force", "force deletion of branches not fully merged") do
    options[:force] = v
  end
end.parse!


def clean_lines(string, no_leading_star=true, no_leading_space=true)
  lines = string.split("\n").map(&:chomp)
  if no_leading_star
    lines.map! {|line| line.sub(/^\s*\*/, ' ') }
  end
  if no_leading_space
    lines.map! {|line| line.sub(/^\s+/, '') }
  end
  lines
end

def is_remote?(branch)
  branch.start_with?("remotes/origin/")
end

puts `git fetch -p`
puts `git checkout master`
puts `git pull`

branches = clean_lines `git branch -a`

grouped = branches.group_by {|branch| branch.split('/').last }

deleted = 0
grouped.each do |branch_name, branches|
  if branches.size == 1 && !is_remote?(branches.first)
    deleted += 1
    branch = branches.first
    delete_opt = options[:force] ? "-D" : "-d"
    puts `git branch #{delete_opt} #{branch}`
  else
    # puts "'#{branches.first}' has remote '#{branches.last}'"
  end
end

if deleted == 0
  puts "<< No local branches without a remote. >>"
end
