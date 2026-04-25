#!/usr/bin/ruby

require 'optparse'
require 'rubygems'
require 'fileutils'
require 'find'

cwd = Dir.getwd
CWD_T = cwd + '/'

def trim_dir(dir)
  dir.sub(CWD_T,'').sub(/^\.\//,'')
end

class VCS
  NLRE = /\r?\n/
  VCS_TYPES = %w(git svn bzr)

    def self.vcs_classes
    VCS_TYPES.map do |v|
      VCS.const_get v.capitalize
    end
  end

  # given a path, returns the correct vcs object or nil if not version control
  def self.create(path)
    klass = vcs_classes.find do |vcs| 
      vcs_file = File.join(path, ".#{vcs.to_s.split('::').last.downcase}") 
      File.exist?( vcs_file ) && FileTest.directory?( vcs_file )
    end
    klass ? klass.new(path) : nil
  end

  attr_reader :path
  attr_accessor :current_message

  def to_s
    path
  end

  # returns the reply
  def run(cm)
    Dir.chdir(@path) do |dir|
      `#{[cmd, cm].join(" ")}`
    end
  end

  # should return an array of unknown files
  def unknown
    []
  end

  # removes files that aren't under version control
  def rm
    un = unknown 
    Dir.chdir(path) do 
      FileUtils.rm_rf un
    end
    (ex, noex) = un.partition do |file|
      File.exist?(file)
    end
    puts "REMOVED: #{noex.inspect}"
    puts "NOT REMOVED: #{ex.inspect}"
  end

  def cmd
    self.class.to_s.split('::').last.downcase
  end

  def initialize(path)
    @path = path.sub(/^\.\//,'')
  end

  def changes
    Dir.chdir(@path) do
      reply = `#{cmd} status`.chomp
      if reply =~ /\w/
        reply
      else
        nil
      end
    end
  end

  class Git < VCS
    No_Changes = 'nothing to commit (working directory clean)'

    def unknown
      reply = run('ls-files -o')
      reply.split(NLRE).map {|v| v.chomp }
    end

    get_untracked = ""
    def changes
      reply = run(:status)
      if reply.include? No_Changes
        nil
      else
        reply
      end
    end
  end

  class Bzr < VCS

    def unknown
      reply = run(:status)
      get_unkown = false
      ret = []
      reply.each do |line|
        if line =~ /^unknown:/
          get_unkown = true
        elsif line =~ /^\w/
          get_unkown = false
        elsif get_unkown
          ret << line.strip
        end
      end
      ret
    end

    def changes
      reply = run(:status)
      if reply.split(NLRE).any? {|v| v =~ /^(modified|unknown)/ }
        reply
      else
        nil
      end
    end
  end

  class Svn < VCS
    def changes
      reply = run(:status)
      if reply.split(/\r?\n/).any? {|v| v =~ /^M/ }
        reply
      else
        nil
      end
    end
    
    def unknown
      reply = run(:status)
      ret = []
      reply.each do |line|
        if line[0] == '?'
          ret << line.split(/\s+/)[1].chomp
        end
      end
      ret
    end

  end
end

# the block yields each path, expects to receive a VCS type object or nil
# ignores '.*' files
# returns [array of objects, ar of dirs that aren't version controlled]
def get_dirs(top_dir, recursive=false, soft=false, &block)
  vc_objs = []
  not_vc_dirs = []
  if recursive
    Find.find(top_dir) do |path|
      if FileTest.directory?(path)
        if File.basename(path) =~ /^\../ # don't look inside '.*' folders
          Find.prune
        elsif !soft && File.symlink?(path)
          Find.prune
        else
          obj = block.call(path)
          if obj ; vc_objs << obj
          else ; not_vc_dirs << path
          end
          # if head contains a .svn file, don't look further down this branch
          VCS::VCS_TYPES.each do |tp|
            dot_file = "#{path}/.#{tp}"
            if FileTest.directory?(dot_file)
              Find.prune
            end
          end
        end
      end
    end
  else
    Dir[File.join(File.expand_path(top_dir), '*')].select {|f| FileTest.directory?(f) }.each do |path| 
      obj = block.call(path) 
      if obj ; vc_objs << obj
      else ; not_vc_dirs << path
      end
    end
  end
  [vc_objs, not_vc_dirs]
end




opt = {}
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <topdir>"
  op.separator ""
  op.on("-r", "--recursive", "searches for version control recursively") {|v| opt[:recursive] = v }
  op.on("-v", "--verbose", "give lots of info") {|v| $VERBOSE = v }
  op.on("-s", "--soft", "follow soft links") {|v| opt[:soft] = v }
  op.on("-n", "--not-vc", "lists dirs not under version control") {|v| opt[:not_vc] = v }
  op.separator ""
  op.separator "by default doesn't search for soft links"
end

opts.parse!

if ARGV.size == 0
  puts opts.to_s
  exit
end

dir = ARGV[0]

ARGV.clear # in case we want to do some query stuff

(objs, not_vc) = get_dirs(dir, opt[:recursive], opt[:soft]) do |dr| 
  VCS.create(dr)
end

hash = {}
(changes, no_changes) = objs.partition do |obj|
  obj.current_message = obj.changes
end


puts "NOTHING TO DO:" if no_changes.size > 0
puts no_changes.map {|v| trim_dir(v.to_s) }.sort.join(" ")
if $VERBOSE
  changes.sort_by {|v| v.to_s }.each do |v|
    puts "************** #{trim_dir(v.to_s)} **************"
    puts v.current_message
  end
else
  puts "CHANGES: " if changes.size > 0
  puts changes.map {|v| trim_dir(v.to_s) }.sort.join(" ")
end

if opt[:not_vc]
  puts "NOT UNDER VERSION CONTROL:"
  puts not_vc.map {|v| trim_dir(v)}.join(" ")
end



