#!/usr/bin/env ruby

require 'optparse'

def get_dirs
  Dir['*'].select {|fn| File.directory?(fn) }
end

def unmount(dirs)
  dirs.each do |dir|
    puts "Unmounting #{dir}"
    `fusermount -u #{dir}`
  end
end

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "usage: #{File.basename(__FILE__)} [options] [dirs]"
  opts.on("-u", "--unmount", "unmount all the mounts") do |v|
    options[:unmount] = true
  end
  opts.on("--setup-instructions") do
    puts <<-END
      prereq - pull down catfs from https://github.com/kahing/catfs/releases/
      chmod +x and put in ~/.local/bin, which should be on your path.  Also
      make a cache dir for goofys.  For example:
      ```
      mkdir -p ~/.local/bin
      cd ~/.local.bin
      wget https://github.com/kahing/catfs/releases/download/v0.8.0/catfs
      chmod +x catfs
      # check that <$HOME>.local/bin is in your $PATH (if not, add it)
      echo $PATH | grep '.local/bin'
      mkdir -p ~/.cache/goofys
      ```

      Also, note that interactive shell prompts can slow down interaction with
      the underlying s3 filesystem.  Consider starting a bash prompt with a
      clean environment before navigating:

          env -i bash --noprofile --norc
    END
    exit
  end
end
parser.parse!

dirs =
  if ARGV.size > 0
    ARGV.dup
  else
    get_dirs
  end

if options[:unmount]
  unmount(dirs)
  exit
end

dirs.each do |dir|
  puts "Mounting #{dir}"
  `goofys --cheap --cache "--free:5%:#{ENV['HOME']}/.cache/goofys" #{dir} #{dir}`
end