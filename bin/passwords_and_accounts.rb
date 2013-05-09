#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'

def putsv(*args)
  puts(*args) if $VERBOSE
end

opt = {}
opts = OptionParser.new do |op|
  op.banner = "write: #{File.basename(__FILE__)} 'category' 'account' 'password'"
  op.separator " view: #{File.basename(__FILE__)} 'category'"
  op.separator ""
  op.on("-l", "--less", "open the document with less") {|v| opt[:less] = v }
  op.on("-u", "--unzip", "unzip it") {|v| opt[:unzip] = v }
  #op.on("-z", "--zip", "zip it up") {|v| opt[:zip] = v }
  op.on("-v", "--verbose", "") {|v| $VERBOSE = 3 }
end
opts.parse!

if (ARGV.size == 0) && (opt[:less].nil? && opt[:unzip].nil? && opt[:zip].nil?)
  puts(opts)
  exit
end

(category, *other) = ARGV

zip_file = 'passwds_logins.zip'
passwd_file = 'passwords__logins.yaml'
dir = zip_file.chomp(File.extname(zip_file))
path = File.join( ENV['HOME'], 'Dropbox', 'env' )

Dir.chdir(path) do
  unless opt[:zip]
    if File.exist?(dir)
      putsv "#{dir} already exists! removing #{dir}"
      FileUtils.rm_rf dir
    end
    putsv "unzipping #{zip_file}"
    system "unzip #{$VERBOSE ? "" : "-q"} #{zip_file}" unless opt[:zip]
  end
  Dir.chdir(dir) do
    if opt[:less]
      putsv "opening #{passwd_file} in less"
      system "less #{File.join(path, dir, passwd_file)}"
    elsif opt[:unzip] || opt[:zip]
      # do nothing
    else
      if other.size > 0
        cat_re = /^#{Regexp.escape(category)}\:/
        lines = IO.readlines(passwd_file).select {|line| !line.match(cat_re) }
        lines.push( "#{category}: [#{other.join(', ')}]\n" )
        File.open(passwd_file, 'w') do |io|
          io.print lines.join
        end
      else
        putsv "Searching for /#{category}/i:"
        results = IO.readlines(passwd_file).grep(/#{category}/i)
        puts results.join("\n")
        puts "#{results.size} result(s)"
      end
    end
  end
  if other.size > 0
    putsv "removing #{zip_file}"
    FileUtils.rm_rf zip_file
    putsv "creating #{zip_file}"
    system "zip -e -r #{$VERBOSE ? "" : "-q"} #{zip_file} #{dir}"
  end
  unless opt[:unzip]
    putsv "removing #{dir}"
    FileUtils.rm_rf dir
  end

end
