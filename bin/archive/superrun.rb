#!/usr/bin/env ruby

require 'trollop'

parser = Trollop::Parser.new do
  banner "usage: #{File.basename(__FILE__)} [OPTIONS] -- <your command>"
  text "automatically sets bigmem flag if needed (> 24GB)"
  opt :mem, "amount of memory for the job", :default => 24, :short => "-m"
  opt :name, "name of the job", :default => 'current', :short => "-n"
  opt :email, "send email to this address", :default => 'jtprince@chem.byu.edu', :short => "-e"
  opt :time, "amount of walltime needed (hh:mm:ss)", :default => '0:59:59', :short => "-t"
  opt :file, "writes this to qsub file", :default => 'supercompute.rb', :short => "-f"
  opt :dry, "don't submit the file", :default => false, :short => "-d"
end

middle_i = ARGV.index('--')
(parser.educate && exit) unless middle_i
initial_args = ARGV[0...middle_i]
args_to_run = ARGV[(middle_i+1)..-1]

opt = parser.parse(initial_args)

if args_to_run.size == 0
  parser.educate && exit
end

if opt[:mem] > 24
  opt[:bigmem] = true
end

header = %Q{#!/usr/bin/env ruby

#PBS -l nodes=1:ppn=1#{opt[:bigmem] ? ":bigmem" : ''},mem=#{opt[:mem]}gb,walltime=#{opt[:time]},qos=preemptee
#PBS -N #{opt[:name]}
#PBS -m bea
#PBS -M #{opt[:email]}
# Job can be requeued if it is preempted
#PBS -r y

require 'rake'
cd ENV['PBS_O_WORKDIR']
}

cmd = args_to_run.join(" ")
body = "
puts 'running: #{cmd}'
puts `#{cmd}`
"

File.open(opt[:file],'w') do |out|
  out.puts header
  out.puts body
end

puts( `qsub #{opt[:file]}` ) unless opt[:dry]

=begin
require 'babypool'
HOME = ENV['HOME']

# MODIFY THIS:
################################################################
NUM_PROCESSORS = 1
SLEEP_TIME = 30

base = "ruby -S mascot_pepxml_to_peptide_hit_qvalues.rb -d"

act_on = Dir["*.xml"].sort
################################################################
#
## MULTIFILE: 
pool = Babypool.new(:thread_count => NUM_PROCESSORS)

act_on.each do |file|
  pool.work do |job|
    cmd = [base, file].join(" ")
    puts cmd
    puts `#{cmd}`
  end
end

loop do
  sleep(SLEEP_TIME)
  unless pool.busy?
    pool.drain
    break
  end
end
=end

