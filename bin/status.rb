#!/usr/bin/env ruby
# encoding: UTF-8

######################################################################
# Monitors
######################################################################

module Monitor
  SLEEP = 2

  def valid?
    true 
  end

  class DateTime
    include Monitor
    def initialize(format="%a %b %d %l:%M%P")
      @format = format
    end
    def data
      Time.now.strftime(@format)
    end
  end

  # a mixin that actively sleeps the monitor
  # requires mixin classes to implement get_data which returns the data
  module Sleeper
    def initialize(slp=Monitor::SLEEP)
      @sleep = slp
    end

    def data
      sleep(@sleep)
      get_data
    end
  end

  # requires mixin classes to implement get_data which returns the data
  module LongTimer
    SLEEP = 600

    def initialize(update_sec=Monitor::LongTimer::SLEEP)
      @update_sec = update_sec
      @last_update = Time.now - @update_sec # set to immediately update
    end

    def data 
      if ((now=Time.now) - @last_update) >= @update_sec
        @last_update = now
        @data = get_data
      end
      @data
    end
  end

  class Weather
    PROGRAM = 'weather_simple.rb'
    LOCATION = 'provo'
    include Monitor
    include LongTimer

    def get_data
      (temp_s, weather_s, intensity_s) = `#{PROGRAM} #{LOCATION}`.split(' ')
      [temp_s.to_i, weather_s, intensity_s.to_i]
    end
  end

  class Quote
    include Monitor
    include LongTimer
    QUOTES = [
      #'move-eat-sleep-relax-connect',
      #'1-act-on-important, 2-extraordinary, 3-bigrocks, 4-ruletech, 5-fire',
      #'to a mind that is still the whole universe surrenders',
      #'be the change you wish to see in the world',
      #'see everything as if it were your first or last time',
      # Kurt Vonnegut '"We are what we pretend to be, so we must be careful about what we pretend to be."
      #'D&C 61:36 be of good cheer, little children; for I am in your midst, and I have not forsaken you.',
      'what you do is who you become',
      #'We are what we pretend to be, so careful what you pretend.',
    ]

    def get_data
      QUOTES.sample
    end
  end

  class CPU
    include Monitor
    include Sleeper
    IDLE_IDX = 3

    CPUInfo = Struct.new(:idle, :total) do
      def percent(prev)
        100 * (1.0 - (self.idle - prev.idle).to_f./(self.total - prev.total))
      end
    end

    def initialize(*args)
      @io = File.open("/proc/stat")
      @num_cpus = @io.read.scan(/^cpu\d+\s+/).size
      @io.rewind
      @prev_cpuinfos = cat_proc
      super(*args)
    end

    # returns an array of CPUInfo objects, one for each cpu.
    # always rewinds the io object
    def cat_proc
      # user nice system idle iowait irq softirq
      @io.readline # cpu_totals
      cpuinfos = @num_cpus.times.map do
        pieces = @io.readline.split(' ')
        data = pieces[1,7].map(&:to_i)
        CPUInfo.new( data[IDLE_IDX], data.reduce(:+) )
      end
      @io.rewind
      cpuinfos
    end

    # returns an array of percents
    def get_data
      cpuinfos = cat_proc
      percents = cpuinfos.zip(@prev_cpuinfos).map do |cpui, prev_cpui|
        cpui.percent(prev_cpui)
      end
      @prev_cpuinfos = cpuinfos
      percents
    end
  end

  class Memory
    include Monitor
    include Sleeper
    attr_reader :total

    def initialize(*args)
      @total = get_tot_mem
      super(*args)
    end

    # returns % memory used and % total memory used (i.e., w/cache)
    def get_data
      (mem, w_cache) = get_mem
      [100*mem.to_f/@total, 100*w_cache.to_f/@total]
    end

    def get_tot_mem
      `free -m`[/Mem:\s+(\d+)\s/m, 1].to_i
    end

    # returns memory used and total memory used (w/cache)
    def get_mem
      lines = `free -m`.split("\n")
      header = lines[0]
      w_cache = lines[1].split(/\s+/)[2].to_i
      mem = lines[2].split(/\s+/)[2].to_i
      [mem, w_cache]
    end
  end

  class Battery
    include Monitor
    include Sleeper

    def valid?
      `which acpi`.size.>(0)
    end

    # returns [direction, percent] where direction is +/- or 0
    def get_data
      (status, percent) = `acpi -b`.split(': ').last.split(', ')
      direction  =
        case status
        when 'Discharging' then '-'
        when 'Charging' then '+'
        else '0'
        end
      [direction, percent[0...-1].to_f]
    end
  end

end

######################################################################
# I3Bar UI Components
######################################################################

class I3Bar < Array

  def initialize(*args)
    puts "{ \"version\": 1 }"
    puts "["
    super(*args)
  end

  # sends to stdout, flushes stdout, clears the array
  def display!
    puts("[" + self.join(",") + "],\n\n") || $stdout.flush
    self.clear
  end

  class UI < Hash

    # in case the original needs to be called
    alias_method :orig_initialize, :initialize

    # will optionally take: name, color, monitor on initialize
    def initialize(*args)
      [:name, :color, :monitor].zip(args).each {|pair| store(*pair) }
    end

    def to_s
      pairs = self.map do |k,v| 
        if !v.nil?
          [k, v]
        end
      end.compact
      kv = pairs.map {|pair| %Q|"#{pair[0]}": "#{pair[1]}"| }.join(", ")
      "{" << kv << "}"
    end

    class Divider < UI
      def initialize(text, color="#FFFFFF")
        self[:name] = 'divider'
        self[:full_text] = text
        self[:color] = color
      end
    end

    module Bar
      LEVELS = [
        ' ', # U+2002 En Space Nut (a normal space not enough!
        '▁', # U+2581 lower 1/8
        '▂', # U+2582 lower 1/4
        '▃', # U+2583 lower 3/8
        '▄', # U+2584 lower  1/2
        '▅', # U+2585 lower 5/8
        '▆', # U+2586 lower 3/4
        '▇', # U+2587 lower 7/8
        '█', # U+2588 full block
      ]
    end

    # a single directional bar (can be up, down, or zero)
    class UpDownBar < UI
      def initialize(*args)
        self[:denom] = 100.0 / (Bar::LEVELS.size - 1)
        self[:ends] = ' '
        super(*args)
      end

      # data is an array of direction and percent. returns self
      def display!(data)
        bar = Bar::LEVELS[ (data[1].to_f / self[:denom]).floor ]
        direction_glyph = 
          case data[0]
          when '+' then '⇡'
          when '-' then '⇣'
          else '⧫'
          end
        self[:full_text] = (self[:symbol] || self[:name]) + self[:ends] + direction_glyph + bar + self[:ends]
        self
      end
    end

    # ad hoc for weather.  Expects [temp (int), condition string, intensity (int)]
    class WeatherDisplay < UI
      def display!(data)
        (temp, condition_st, intensity) = data
        st = 
          if condition_st 
            "#{temp}° #{condition_st*intensity}"
          else
            "[NC]"
          end
        self[:full_text] = st 
      end
    end

    # just text
    class SimpleText < UI
      def display!(data)
        self[:full_text] =  data
      end
    end

    class VBars < UI
      DEFAULTS = {
        join: '⋮',
        ends: ' ',
      }

      attr_accessor :join
      attr_accessor :ends

      def initialize(*args)
        DEFAULTS.each {|k,v| self[k] = v }
        super(*args)
      end

      # returns self
      def display!(percents)
        denom = 100.0 / (Bar::LEVELS.size - 1)
        bars = percents.map do |percent|
          Bar::LEVELS[ (percent.to_f / denom).floor ]
        end.join(self[:join])
        self[:full_text] = (self[:symbol] || self[:name]) + self[:ends] + bars + self[:ends]
        self
      end
    end
  end

end

# '𝗖' '𝗕' '𝗠'

quote = I3Bar::UI::SimpleText.new('quote', '#DDDDDD', Monitor::Quote.new(6000))
bat = I3Bar::UI::UpDownBar.new('♉', '#0000FF', Monitor::Battery.new)
cpu = I3Bar::UI::VBars.new('⌘', '#FF0000', Monitor::CPU.new)
mem = I3Bar::UI::VBars.new('♏', '#00FF00', Monitor::Memory.new)
weather = I3Bar::UI::WeatherDisplay.new('weather', '#DDDDDD', Monitor::Weather.new)
datetime = I3Bar::UI::SimpleText.new('datetime', '#DDDDDD', Monitor::DateTime.new)

components = [quote, bat, cpu, mem, weather, datetime].select {|cell| cell[:monitor].valid? }

div = I3Bar::UI::Divider.new(" ◀▶ ", "#000000")

i3bar = I3Bar.new

loop do
  i3bar << div
  threads = components.map do |ui|
    thread = Thread.new(ui) {|iui| iui.display!(iui[:monitor].data) }
    i3bar << ui
    i3bar << div
    thread
  end
  threads.each(&:join)
  i3bar.display!
end

