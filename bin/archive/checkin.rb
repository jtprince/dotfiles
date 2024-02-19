#!/usr/bin/ruby

require 'rubygems'
require 'fileutils'

class VCS
  NLRE = /\r?\n/

  def self.vcs_classes
    %w(Git Svn Bzr).map do |v|
      VCS.const_get v
    end
  end

  # searchs all the directories one level down for the vcs file
  def self.make_objects(top_dir)
    dirs_onedown = Dir[File.join(File.expand_path(top_dir), '*')].select {|f| FileTest.directory?(f) }
    objs_ars = vcs_classes.map do |vcs|
      vcs_dirs = dirs_onedown.select do |path|
        vcs_file = File.join(path, ".#{vcs.to_s.split('::').last.downcase}") 
        File.exist?( vcs_file ) && FileTest.directory?( vcs_file )
      end
      vcs_dirs.map {|dir| vcs.new dir }
    end
    objs_ars.flatten
  end

  attr_reader :path

  def to_s
    path
  end

  # returns the reply
  def run(cm)
    Dir.chdir(@path) do |dir|
      `#{[cmd, cm].join(" ")}`
    end
  end

  def qrun(info=nil)
    ARGV.clear
    puts "****** #{File.basename(path)} ******"
    if info
      puts info 
    end
    print(cmd + " ")
    reply = gets.chomp
    if reply =~ /\w/
      if reply == 'rm'
        puts "TRYING TO REMOVE:"
        rm
      elsif reply == 'ci'
        run("ci -m 'auto'")
      else
        run(reply)
      end
    else
      '(doing nothing)'
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
    @path = path
  end

  def changes
    Dir.chdir(@path) do
      reply = `#{cmd} status`.chomp
      if reply =~ /\w/
        qrun(reply)
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
        qrun(reply)
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
        qrun(reply)
      else
        nil
      end
    end
  end

  class Svn < VCS
    def changes
      reply = run(:status)
      if reply.split(/\r?\n/).any? {|v| v =~ /^M/ }
        qrun(reply)
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


dir = ARGV[0] || abort("usage: #{File.basename(__FILE__)} .")

ARGV.clear
objs = VCS.make_objects(dir)
objs.each do |obj|
  if reply = obj.changes
    puts reply
  else
    puts "#{obj}: no changes"
  end
end




