#!/usr/bin/ruby -w

def usage
  string = <<USAGE
adds all files with ? using svn add
USAGE
end

if ARGV.length > 0
  print usage
  exit
end

to_add = []
`svn st`.split("\n").each do |line|
  if line =~ /^\?\s+(.*)/ 
    #puts "first letter " + $1[0].chr
    filename = $1
    #puts "filename: " + filename
    base = File.basename(filename.gsub(/\\/, '/'))
    #puts "base: " + base
    if base[0,1] != '.'   ## not the .svn or .vim files etc
      to_add.push(filename)
    end
  end
end

if to_add.length > 0
  cmd = "svn add "
  listed = to_add.join("\n")
  one_line = to_add.join(" ")
  to_perform = cmd + one_line 
  show = cmd + "\n" + listed
  puts "************************************************"
  puts "Performing the command:"
  puts "************************************************"
  puts show
  puts
  print "perform? (Y/N) [Y]"
  unless gets == "N\n"
    puts `#{to_perform}`
  else
    puts "Execution aborted"
  end
else
  puts "No files found to add!"
end



