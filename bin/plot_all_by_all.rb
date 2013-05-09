#!/usr/bin/ruby

require 'rsruby'
require 'rsruby/dataframe'

file = ARGV[0] || abort("usage: #{File.basename(__FILE__)} <csv_w_headers>.csv\noutputs: <csv_w_headers>.png")

#############################
ext = 'png'
width = 800  # in pixels
height = 800
#############################

# initialize R and dataframes

r = RSRuby.instance
r.class_table['data.frame'] = lambda{|x| DataFrame.new(x)}
RSRuby.set_default_mode(RSRuby::CLASS_CONVERSION)

df = r.read_csv(file, :quote=>"")

### SOMETHING is wrong with png output... not sure what it is.
#r.png(:filename=>file.sub(/\.csv$/i, ".#{ext}"), :width=>800, :height=>800)
r.plot(df)
sleep(10)
r.dev_off()

#r.dev_off()

# here's the equivalent R script
# run by R CMD BATCH <script_name>
# or within R: source("<script_name>")

#png(file="data_clean.png", width=2400, height=2400)
#df = read.csv("data_clean.csv", quote="")
#plot(df)
#dev.off()
