#!/usr/bin/env ruby

require 'optparse'
require 'midilib/sequence'
require 'midilib/io/seqreader'
require 'midilib/io/seqwriter'

=begin
    mod_wheel       => 1,
    breath          => 2,
    foot            => 4,
    portamento_time => 5,
    volume          => 7,
    balance         => 8,
    pan             => 10,
    expression      => 11,
    sustain         => 64, 
    portamento      => 65,
    sustenuto       => 66,
    soft_pedal      => 67,
    hold_2          => 69,
    temp_change     => 81,
    tremelo         => 92,
    chorus          => 93,
    celeste         => 94,
    phaser          => 95,
=end

ControllerNums = {
  :volume => 7,
  :pan => 10,
}

MIDPOINT = 63
def make_pan(num, spread)
  start = 
    if num % 2 == 0  # even
      (MIDPOINT - (num.to_f/2 - 0.5) * spread).to_i
    else  # odd
      MIDPOINT - ((num.to_i / 2) * spread).to_i
    end
  (0...num).map do |v|
    (start + (spread * v)).to_s
  end.reverse
end

#bottoms up will move the bass pan a little closer to the middle

opt = {}
opt[:postfix] = "_tmp"
opts = OptionParser.new do |op|
  op.banner = "usage: #{File.basename(__FILE__)} <file>.mid ... [-- <timidity args>]"
  op.separator "outputs: <file>#{opt[:postfix]}.mid"
  op.separator ""
  op.separator " note that tracks are numbered if they have a program change (ie, instrument)"
  op.separator " track numbers do not necessarily correlate with actual track numbers"
  op.on("-s", "--summary", "prints a summary about the file") {|v| opt[:summary] = v }
  op.on("-p", "--pan <v1,v2..>", Array, "pan for each track") {|v| opt[:pan] = v }
  op.on("--make-pan <spread,[bottomsup]>", Array, "will calculate the pan") {|v| opt[:make_pan] = v }
  op.on("-v", "--volume <v1,v2..>", Array, "volume for each track") {|v| opt[:volume] = v }
  op.on("-i", "--instrument <v1,v2..>", Array, "instrument for each track") {|v| opt[:instrument] = v }
  op.on("-c", "--compare", "compare two files") {|v| opt[:compare] = v }
  op.on("-t", "--trim-last-tempo", "trims last tempo event") {|v| opt[:trim_last_tempo] = v }
  op.on("-k", "--keep", "keep the file you made") {|v| opt[:keep] = v }
  op.on("--see-tempos", "see tempos objects") {|v| opt[:see_tempos] = v }
  op.on("--postfix <String>", "postfix (default: #{opt[:postfix]})") {|v| opt[:postfix] = v }
  op.on("--verbose") {|v| $MIDVERBOSE = 5 }
end

ControllersList = [:volume, :pan]

before_double_dash = true
(before_argv, after) = ARGV.partition do |arg|
  if arg == '--'
    before_double_dash = false
  end
  before_double_dash
end

# remove the '--' if any, set run_timidity to true if double dash
run_timidity = !!(after.shift)

opts.parse!(before_argv)

if before_argv.size == 0
  puts opts.to_s
  exit
end

before_argv.each do |file|
  puts "#{file}:" if opt[:summary] || $MIDVERBOSE
  base = file.chomp(File.extname(file))
  seq = MIDI::Sequence.new
  my_track_num = 0
  File.open(file, 'rb') do |io|
    seq.read(io)
  end
  my_tracks = seq.tracks.select {|track| track.events.any? {|e| e.is_a? MIDI::ProgramChange } }

  if opt[:make_pan]
    opt[:pan] = make_pan(my_tracks.size, opt[:make_pan].first.to_i)
    opt[:pan][-1] = (opt[:pan][-1].to_i + opt[:make_pan].last.to_i).to_s if opt[:make_pan].size == 2
  end

  my_tracks.each_with_index do |track,my_track_num|
    puts "  TRACK #{my_track_num}:" if (opt[:summary] or $MIDVERBOSE)
    track.events.each do |event|
      if opt[:summary]
        if event.program_change?
          event.print_decimal_numbers = true
          puts "    instrument: #{event.program}"
        elsif event.is_a? MIDI::Controller
          ControllerNums.each do |k,v|
            if event.controller == v
              puts "    #{k}: #{event.value}"
            end
          end
        end
      end

      case event
      when MIDI::Controller
        ControllersList.each do |controller|
          if opt[controller] && event.controller == ControllerNums[controller]
            before = event.value
            newval = ( opt[controller][my_track_num] || opt[controller].last ).to_i
            event.value = newval.chr
            puts "    #{controller}: #{before} => #{newval}" if $MIDVERBOSE
          end
        end
      when MIDI::ProgramChange 
        if opt[:instrument]
          before = event.program
          event.program = (opt[:instrument][my_track_num] || opt[:instrument].last).to_i
          puts "    instrument: #{before} => #{event.program}" if $MIDVERBOSE
        end
      end
    end
  end

  if opt[:see_tempos]
    tempo_events = seq.tracks.first.events.select do |event|
      event.is_a? MIDI::Tempo 
    end
    puts tempo_events.to_yaml.split("\n").reject {|v| v =~ /\s+is_/ }.join("\n")
  end

  if opt[:trim_last_tempo]
    puts "TRIMMING LAST TEMPO!"
    tempo_events = seq.tracks.first.events.select do |event|
      event.is_a? MIDI::Tempo 
    end
    ev = seq.tracks[0].events  
    ev.delete tempo_events.last
    seq.tracks[0].events = ev
    seq.tracks[0].recalc_times
  end

  unless opt[:summary] or opt[:see_tempos]
    outfile = base + opt[:postfix] + ".mid"
    File.open(outfile, 'wb') {|io| seq.write io } 
    puts "WRITING TO: #{outfile}" if $MIDVERBOSE
    sleep 0.5
  end

  if run_timidity
    system "timidity #{outfile} #{after.join(" ")}"
  end

  unless opt[:keep]
    File.unlink(outfile) if outfile && File.exist?(outfile)
  end

end
