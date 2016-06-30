#!/usr/bin/ruby

# https://spin.atomicobject.com/2011/05/28/3-ways-to-make-tab-delimited-files-from-your-mysql-table/
# The only way to get properly quoted values is to use mysql -e with an `INTO
# OUTFILE` command.
# Note that you cannot use this command on production because the production
# user does not have this permission.  You'll have to transfer the info to
# another DB and export it from there :(

# right now this is just a crude template generator

if ARGV.size != 3
  puts "usage: #{File.basename(__FILE__)} database table outfile"
  exit
end

database, table, outfile = ARGV

header_file = "/tmp/headers.tsv"
data_file = "/tmp/data.tsv"

puts "mysql_login=\"mysql --user=root --password='<<REPLACE>>'"

header_query = "$mysql_login -e \"SELECT GROUP_CONCAT(COLUMN_NAME SEPARATOR '\\t') FROM INFORMATION_SCHEMA.COLUMNS WHERE table_schema='#{database}' and table_name='#{table}' INTO OUTFILE '#{header_file}' FIELDS TERMINATED BY '\\t' OPTIONALLY ENCLOSED BY '' ESCAPED BY '' LINES TERMINATED BY '\\n';\""

puts header_query

double_quote = '"'

values_query = "$mysql_login #{database} -e \"SELECT * FROM #{table} INTO OUTFILE '#{data_file}' FIELDS TERMINATED BY '\\t' OPTIONALLY ENCLOSED BY '\\#{double_quote}' LINES TERMINATED BY '\\n';\""

puts values_query

puts "cat #{header_file} #{data_file} > #{outfile}"
puts "rm #{header_file} #{data_file}"
