#!/usr/bin/ruby

require 'optparse'
require 'fileutils'

# relative to ENV['HOME']
VAULT = 'vault/git'
GIT_REPO = 'git'

cwd = File.basename(Dir.pwd)

$DRY = false

def run(cmd)
  puts cmd if $VERBOSE
  unless $DRY
    reply = `#{cmd}`
    if reply && reply.size > 0
      puts reply if $VERBOSE
    end
  end
end

$VERBOSE = 3
opt = { :bind => true, :git_repo => GIT_REPO, :gem => false }
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <dir>"
  op.separator " "
  op.on("-v", "--vault", "use #{VAULT} as git repo") { opt[:git_repo] = VAULT }
  op.on("-g", "--gem", "create the gem structure with jeweler") { opt[:gem] = true }
  op.on("--no-bind", "just create remote, don't bind dir to it") {|v| opt[:bind] = false }
  op.separator " "
  op.on("-q", "--quiet", "turn off verbose") { $VERBOSE = nil }
  op.on("--dry", "just print the commands") { $DRY = true; $VERBOSE = 3 }
end
opts.parse!

grd_exp = [ENV['HOME'], opt[:git_repo]].join('/')

if ARGV.size == 0
  puts opts 
  puts "\nUSING DIR: #{grd_exp}" if $VERBOSE
  exit
end

dir = ARGV.shift 
if opt[:gem]
  run "jeweler --bacon #{dir}"
  git_config = dir + '/.git'
  print "OK to delete #{git_config} (Y/n): "
  reply = gets.chomp
  unless reply =~ /nN/
    FileUtils.rm_rf git_config
  end
end

Dir.chdir(dir) do
  proj = File.basename(Dir.pwd)

  git_proj = [grd_exp, "#{proj}.git"].join('/')

  # The path should be relative so that it works well with ssh and different
  # users, etc.
  unless File.exist?(grd_exp)
    raise "The git repo: #{grd_exp} does not exist!"
  end

  puts "USING REPO NAME => #{git_proj}" if $VERBOSE

  create_remote = "mkdir #{git_proj}; cd #{git_proj}; git --bare init"
  run create_remote

  if opt[:bind]
    commands = ["git init", 
      "git add .", 
      "git commit -m 'init commit'", 
      "git push #{git_proj} master",
      "git remote add origin #{git_proj}",
      "git config branch.master.remote origin",
      "git config branch.master.merge refs/heads/master",
      "git pull"
    ]
    if $DRY
      puts "[DRY RUN]:" 
    else
      puts "[EXECUTING]:"
    end
    commands.each do |cmd|
      puts cmd
      if !opt[:dry] && reply = `#{cmd}` && reply =~ /\w/
        puts reply
      end
    end
  end
end
