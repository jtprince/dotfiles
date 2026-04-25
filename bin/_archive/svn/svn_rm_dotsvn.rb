#!/usr/bin/ruby

## deletes all .svn directories starting in pwd
## copied from http://www.bigbold.com/snippets/posts/show/565 

def deleteDir(dir)
    puts "cd #{dir}"
    Dir.chdir(dir)
    Dir.foreach(dir) do |file|
        if file != "." and file != ".."
            if File.directory?(file)
                deleteDir("#{dir}/#{file}")
            else
                puts "delete file #{file}"
                puts "size: #{File.size(file)}"
                begin
                    File.delete(file)
                rescue
                    File.chmod(0644, file)
                    File.delete(file)
                end
            end
        end
    end
    Dir.chdir("..")
    puts "delete directory #{dir}"
Dir.delete(dir)
    end

def processDir(dir)
    #puts "Processing directory #{dir}"
    Dir.chdir(dir)
    Dir.foreach(dir) do |file|
        if File.directory?(file)
            if file == ".svn"
                puts "Deleting directory #{dir}/#{file}"
                deleteDir("#{dir}/#{file}")
            elsif file != "." and file != ".."
                processDir("#{dir}/#{file}")
            end
        end
    end
    Dir.chdir("..")
end

puts "Are you sure you want to delete all the .svn files? [Yn]"
reply = gets
if reply =~ /[Yy]/
  puts "Working directory: #{Dir.pwd}"
  processDir(Dir.pwd)
else
  puts "NOT deleting files!"
end

