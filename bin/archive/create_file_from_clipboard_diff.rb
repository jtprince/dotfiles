#!/usr/bin/env ruby

require 'clipboard'
require 'fileutils'

# can't get explicit secondary working, but this will copy from the <ctrl><v>
# style clipboard:
string = Clipboard.paste('clipboard')

# this is the structure of a diff that needs to be created:
test = <<HERE
diff --git a/automate/saveUserToInsideSales.php b/automate/saveUserToInsideSales.php
new file mode 100644
index 0000000..3302884
--- /dev/null
+++ b/automate/saveUserToInsideSales.php
@@ -0,0 +1,13 @@
+<?php
+
+require_once("config.inc");
+
+$user_ids = array_slice($argv, 1);
+
+$force_save = True;
+
+foreach ($user_ids as $user_id) {
+    $user = Core_Retailer_Factory::getObject($user_id);
+    $inside_sales_id = Lib_Service_InsideSales_Integration::saveLead($user, $force_save);
+    echo "User " . $user_id . " saved with inside_sales lead id: " . $inside_sales_id . "\n";
+}
HERE



def create_file(stripped_lines)
  unless stripped_lines[1].split.first == 'new'
    abort "This doesn't seem like a newfile diff or is in the wrong register.  See 'test' in the script"
  end

  mode = stripped_lines[1].split.last[-3..-1]
  filename = stripped_lines[0].split.last.sub(/^b\//, '')
  dir = File.dirname(filename)
  FileUtils.mkdir_p(dir)

  if stripped_lines.size == 3
    `touch #{filename}`
    `chmod #{mode} #{filename}`
  else
    file_contents = stripped_lines[6..-1].map {|line| line[1..-1] + "\n" }.join

    File.write(filename, file_contents)
    `chmod #{mode} #{filename}`
    puts "Created #{filename} #{mode} with contents of size #{file_contents.size}"

  end
end


stripped_lines = string.split("\n").map(&:chomp)

file_lines = []
current_lines = nil
stripped_lines.each do |line|
  if line =~ /^diff --git a\//
    file_lines << current_lines if current_lines
    current_lines = [line]
  else
    current_lines << line
  end
end 
file_lines << current_lines

new_file_lines = file_lines.select {|lines| lines[1].split.first == 'new' }

new_file_lines.each do |lines|
  create_file(lines)
end
