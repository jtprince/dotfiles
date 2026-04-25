#!/usr/bin/ruby

require 'optparse'
require 'fileutils'

SLEEP_INC = 0.25
MAX_SLEEP_TIME = 60

# returns the job number if still printing, otherwise false
def still_printing?(file)
  reply = `lpq`
  ars = reply.split("\n").map {|line| line.split(/\s+/)}
  ar_of_interest = ars.select do |ar|
    ar[3] == file
  end
  if ar_of_interest.size > 0
    ar_of_interest.first[2]
  else
    false
  end
end


def print_job(file)
  puts "SUBMITTING JOB: #{file}"
  reply = `lpr -o Duplex=DuplexNoTumble #{file}`
  puts reply if reply =~ /\w+/
  cnt = 0

  total_sleep_time = 0
  jobid = false
  while jobid = still_printing?(file) do
    sleep(SLEEP_INC)
    total_sleep_time += SLEEP_INC
    if total_sleep_time > MAX_SLEEP_TIME
      break
    end
  end
  if jobid
    puts "didn't seem to be able to finish printing #{file}.. trying again."
    reply = `lprm #{jobid}`
    puts reply if reply && reply != ""
    sleep(5)
    system "sudo /etc/init.d/cups restart"
    sleep(5)
    system "sudo /etc/init.d/networking restart"
    print_job(file)
  end
end

$NO_PRINT = false
$RANGE = nil
$DELETE = false
$RESTART_CUPS = false
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} file.pdf ..."
  op.on("-c", "--cups", "restart cups to begin") { $RESTART_CUPS = true }
  op.on("-n", "--no-print", "create files and leave tmpdir") { $NO_PRINT = true }
  # transformed to array start and end indices
  op.on("-r", "--range <start_pg,end_pg>", Array, "prints from pg-pg inclusive", "end_pg is optional from start to finish otherwise") {|v| $RANGE = v.map {|i| i.to_i - 1} }
  op.on("-d", "--delete", "deletes file after successful print") {|v| $DELETE = true }
end


opts.parse!

if ARGV.size == 0
  puts opts.to_s
end

if $RESTART_CUPS
  system "sudo /etc/init.d/cups restart"
  sleep(5)
  system "sudo /etc/init.d/networking restart"
  sleep(5)
end

ARGV.each do |file|
  tmpdir = file + ".tmpdir"
  begin
    FileUtils.rm_rf(tmpdir) if File.exist?(tmpdir)
    FileUtils.mkdir  tmpdir
    FileUtils.cp file, tmpdir
    Dir.chdir(tmpdir) do
      `pdftk #{file} burst`
      ar = Dir["pg_*.pdf"].sort
      ar.delete file  # make sure the file is not there by some glob accident
      ar = ar[$RANGE[0]..($RANGE[1] || -1)] if $RANGE
      ar.each_slice(2) do |ar|
        base = ar.map {|v| v.sub(/\.pdf/i, '') }.join("__")
        outpdf = base + '.pdf'
        outps = base + '.ps'
        unless ar.size == 1
        `pdftk #{ar.join(" ")} cat output #{outpdf}`
        end
      `pdftops #{outpdf}`

      # print the file and delete it when done
      print_job(outps) unless $NO_PRINT
      end
    end
    File.unlink file if $DELETE
  ensure
    FileUtils.rm_rf tmpdir unless $NO_PRINT
  end
end
