#!/usr/bin/ruby -w


############################################################################
# useful for search and replace when there are lots of sticky expressions
# that need escaping, etc
#
# when: ruby -pi -e 'gsub!(search,replace)' files
# fails you
############################################################################


ext = ".sar.sar.sar"

puts "Search for (use / / for regexps):"
search = gets.chomp
puts "Replace with:"
replace = gets.chomp
puts "For files (give a glob):"
file_glob = gets.chomp

Dir[file_glob].each do |file|
  puts "working on: #{file}"
  tmpfile = file + ext
  st = File.stat(file)
  if File.exist?(tmpfile) then abort("Tempfile #{tmpfile} already exists! Delete it or move it before running again") end
  File.open(file) do |fh|
    File.open(tmpfile, "w") do |out|
      out.print( fh.read.gsub(search, replace) )
    end
  end
  File.rename(tmpfile, file)
  File.chmod(st.mode, file) 
  File.chown(st.uid, st.gid, file) 
end

