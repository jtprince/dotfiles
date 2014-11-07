#!/usr/bin/env ruby

######################################################################
# Monitors
######################################################################

require 'json'
require 'time'

module SysMonitor
  SLEEP = 2

  def valid?
    true
  end

  class DateTime
    include SysMonitor
    def initialize(format="%Y-%m-%d | %a %b %d | %l:%M%P")
      @format = format
    end
    def data
      Time.now.strftime(@format)
    end
  end

  # a mixin that actively sleeps the monitor
  # requires mixin classes to implement get_data which returns the data
  module Sleeper
    def initialize(slp=SysMonitor::SLEEP)
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

    def initialize(update_sec=SysMonitor::LongTimer::SLEEP)
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

  class Days
    include SysMonitor
    include LongTimer

    def initialize
      super
      @start = Time.new(2014, 11, 4, 19, 0, 0, "-07:00")
    end

    def data
      seconds = Time.new - @start
      (seconds.to_f / 60 / 60 / 24).floor.to_i.to_s
    end
  end

  class Weather
    PROGRAM = 'weather_simple.rb'
    LOCATION = 'provo'
    include SysMonitor
    include LongTimer

    def get_data
      (temp_s, weather_s, intensity_s) = `#{PROGRAM} #{LOCATION}`.split(' ')
      [temp_s.to_i, weather_s, intensity_s.to_i]
    end
  end

  class Quote
    include SysMonitor
    include LongTimer
    QUOTES = [
      #'move-eat-sleep-relax-connect',
      #'1-act-on-important, 2-extraordinary, 3-bigrocks, 4-ruletech, 5-fire',
      #'to a mind that is still the whole universe surrenders',
      #'be the change you wish to see in the world',
      #'see everything as if it were your first or last time',
      # Kurt Vonnegut '"We are what we pretend to be, so we must be careful about what we pretend to be."
      #'For my soul delighteth in plainness; for after this manner doth the Lord God work among the children of men'
      'whatsoever is light, is good, because it is discernible',
      'my soul delighteth in plainness',
      'see that all these things are done in wisdom and order',
      'he should be diligent, that thereby he might win the prize',
      'mourn with those that mourn',
      'my grace is sufficient for all men that humble themselves before me',
      'he hath all power unto the fulfilling of all his words',
      'I am in your midst, and I have not forsaken you',
      'what you do is who you become',
      #'if you have time to browse internet, you have time to read scriptures & exercise',
      #'We are what we pretend to be, so careful what you pretend.',
      #"I am no lover of disorder and doubt as such. Rather do I fear to lose truth by the pretension to possess it already wholly." # -- William James
      "I fear to lose truth by the pretension to possess it already wholly.",
      "If patience is worth anything, it must endure to the end of time.", # Ghandi
      "A living faith will last in the midst of the blackest storm.", #Ghandi
      "the inches we need are everywhere around us",
      "master everything important",
      "breathe in hostility, breathe out focus and peace",
      "Our revealed truth should leave us stricken with the knowledge of how little we really know", #Hugh B. Brown
      "The master has failed more times than the beginner has tried" #Hugh B. Brown
    ]

    def get_data
      QUOTES.sample
    end
  end

  class CPU
    include SysMonitor
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
    include SysMonitor
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
    include SysMonitor
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

  class MPD
    include SysMonitor
    include Sleeper
    ARTIST_LENGTH = 60
    TITLE_LENGTH = 60

    def get_data
      title = `mpc -f "%title%|%file%" current`.strip
      title = File.basename(title) if title.include?("/")
      artist = `mpc -f "%composer%|%artist%" current`.strip
      artist_short = artist[0..ARTIST_LENGTH]
      title_short = title[0..TITLE_LENGTH]
      artist_short << "..." if artist_short != artist
      title_short << "..." if title_short != title
      "#{artist_short} - #{title_short}"
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
    escaped = self.map(&:to_json)
    puts("[" + escaped.join(",") + "],\n\n") || $stdout.flush
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
            "#{temp}°C #{condition_st*intensity}"
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
# '⌘'

# ttf-font-icons
# need something like this line inside the bar stanza:
# font pango:DejaVu Sans Mono, Icons 8
# insert character in vim with: <C-v>uXXXX
# see https://www.dropbox.com/s/9iysh2i0gadi4ic/icons.pdf

mpd = I3Bar::UI::SimpleText.new('mpd', '#FFA500', SysMonitor::MPD.new)
quote = I3Bar::UI::SimpleText.new('quote', '#DDDDDD', SysMonitor::Quote.new(6000))
bat = I3Bar::UI::UpDownBar.new('', '#0000FF', SysMonitor::Battery.new)
cpu = I3Bar::UI::VBars.new('', '#FF0000', SysMonitor::CPU.new)
mem = I3Bar::UI::VBars.new('♏', '#00FF00', SysMonitor::Memory.new)
weather = I3Bar::UI::WeatherDisplay.new('weather', '#DDDDDD', SysMonitor::Weather.new)
days = I3Bar::UI::SimpleText.new('days', '#0404B4', SysMonitor::Days.new)
datetime = I3Bar::UI::SimpleText.new('datetime', '#DDDDDD', SysMonitor::DateTime.new)

components = [mpd, quote, bat, cpu, mem, weather, days, datetime].select {|cell| cell[:monitor].valid? }

thin_space = ' '
div = I3Bar::UI::Divider.new("#{thin_space}◀▶#{thin_space}", "#000000")

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

