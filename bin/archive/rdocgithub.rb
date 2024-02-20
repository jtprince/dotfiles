#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'

$FORCE = false

def regenerate_rdoc(rdoc_dir, rdoc_cmd)
  # do not proceed if they don't want to delete their doc folder
  unless $FORCE
    if File.exist?(rdoc_dir)
      print "ok to delete '#{rdoc_dir}' (Y/n)?"
      reply = gets.chomp
      if reply.size > 0 or reply =~ /n/i
        abort 'exiting!'
      end
    end
  end

  FileUtils.rm_rf rdoc_dir
  run rdoc_cmd
end

def run(cmd)
  puts "RUNNING: "
  puts cmd
  reply = `#{cmd}`
  if reply && reply.size > 0
    puts reply
  end
end

def putsv(*args)
  puts(*args) if $VERBOSE
end

def make_forward_page(final_rdoc_dir, version)
  redirect_str = "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"0; URL=#{version}\">"
  Dir.chdir(final_rdoc_dir) do
    File.open("index.html",'w') {|io| io.print redirect_str }
  end
end

# renames the doc folder 'Major.Minor.Patch', tars it, and returns the
# [filename, data]
def grab_doc_versioned(rdoc_dir, version)
  FileUtils.mv rdoc_dir, version
  tar_dir = "#{version}.tar"
  run "tar -cf #{tar_dir} #{version}"
  FileUtils.rm_rf version
  [tar_dir, IO.read(tar_dir)]
end


def switch_branches(rdoc_dir, version, commit=true, final_rdoc_dir="rdoc")
  status = `git status`
  unless status =~ /nothing to commit \(working directory clean\)/
    abort 'need clean git directory to proceed (.gitignore doc dir)'
  end
  (tar_doc_fn, data) = grab_doc_versioned(rdoc_dir, version)
  reply = `git checkout gh-pages 2>&1`  # capture any error messages
  if reply =~ /error/
    putsv "INITIALIZING gh-pages!"
    run "git symbolic-ref HEAD refs/heads/gh-pages"
    run "rm .git/index"
    run "git clean -fdx"
  else
    # we already checked out gh-pages on the check above if it didn't fail on
    # error
    puts "CHECKED OUT gh-pages!"
  end
 
  FileUtils.mkdir(final_rdoc_dir) unless File.exist?(final_rdoc_dir)
  # unpack the rdoc
  Dir.chdir(final_rdoc_dir) do
    File.open(tar_doc_fn,'w') {|io| io.print data }
    run "tar -xf #{tar_doc_fn}"
    FileUtils.rm_rf tar_doc_fn
  end
  # create the new redirect
  make_forward_page(final_rdoc_dir, version)
  if commit
    run "git add ."
    run "git commit -a -m \"adding rdoc for version #{version}\""
    run "git push origin gh-pages"
    `git checkout #{$cbr}`
  end
end

def get_current_branch
  `git branch`.split("\n").find {|line| line =~ /^\*/ }.chomp.split(/\s+/).last
end

def get_version(version_file="VERSION")
  IO.read(version_file).split("\n").first.chomp
end


#################################################################
# MAIN 
#################################################################


opt = {
  rdoc_cmd: 'rdoc',
  rdoc_dir: 'doc',
  commit: true,
}

opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)}"
  op.separator ""
  op.separator "regenerates rdoc, and adds it to gh-pages by version in VERSION"
  op.separator "the latest rdoc is always available in <user>.github.com/<project/rdoc"
  op.separator ""
  op.separator "assumes you are at the top of your directory structure."
  op.separator "only cleans out gh-pages of normal files if the branch does not already exist"
  op.separator ""
  op.on("--hanna", "uses hanna instead of rdoc") {|v| opt[:rdoc_cmd] = 'hanna' }
  op.on("-f", "--force", "don't ask for permission") {|v| $FORCE = true }
  op.on("-h", "--help", "print help") {|v| opt[:help] = true}
  op.on("-n", "--no-commit", "don't commit (leaves you in gh-pages)") {|v| opt[:commit] = false }
end
opts.parse!
ARGV.clear

if opt[:help]
  puts opts
  exit
end

$cbr = get_current_branch
version = get_version
regenerate_rdoc(opt[:rdoc_dir], opt[:rdoc_cmd])
switch_branches(opt[:rdoc_dir], version, opt[:commit])

