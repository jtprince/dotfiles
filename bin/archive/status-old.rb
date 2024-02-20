#!/usr/bin/env ruby
# encoding: UTF-8

# replacement for conky or i3status for simple status-bar
# dependencies:
# sudo apt-get install sysstat weather-util acpi
#   then config /etc/default/sysstat, ENABLED="true"
# find your 4 letter code for weather station here:
#   http://weather.rap.ucar.edu/surface/stations.txt
#   KPVU is the Provo Municipal Airport

WEATHER_STATION = 'KPVU'

require 'ostruct'

def have_util?(util)
  `which #{util}`.size > 0
end

unless have_util?('sar')
  puts "need to install sysstat and configure it!"
  # need to install sysstat and config /etc/default/sysstat, ENABLED="true"
  exit
end

def network_interface(default='eth0') 
  lines = `ip link show`.split("\n")
  interface = default
  lines.each_slice(2) do |info, link|
    md = info.match(/^\d+: (\w+): .*? state (UP|DOWN|UNKNOWN)/)
    if md[2] == 'UP'
      interface = md[1]
      break
    end
  end
  interface
end

NETWORK_INTERFACE = network_interface
MAX_KBS = 100

HAVE_ACPI = have_util?('acpi')

class SysMonitor
  DEFAULT_SLEEP = 2  # seconds
  DEFAULT_WEATHER_CHECK = 600 # seconds

  BAR = [
    ' ', 
    '▁', # U+2581 lower 1/8
    '▂', # U+2582 lower 1/4
    '▃', # U+2583 lower 3/8
    '▄', # U+2584 lower  1/2
    '▅', # U+2585 lower 5/8
    '▆', # U+2586 lower 3/4
    '▇', # U+2587 lower 7/8
    '█', # U+2588 full block
  ]

  def initialize(sleep=DEFAULT_SLEEP)
    @weather_check_sec = DEFAULT_WEATHER_CHECK
    @last_weather_update = Time.now - @weather_check_sec # start by checking weather!
    @sleep = sleep
  end

  # reread all the info
  def update!
    @mem, @swp = memory_swap_percents
    cpu_thread = Thread.new {processor_percents}
    network_thread = Thread.new {received_transmitted}
    weather!
    if HAVE_ACPI
      battery_thread = Thread.new {battery_status}
      battery_thread.join
    end
    cpu_thread.join
    network_thread.join
  end

  def bar(type, div='', bookend='')
    case type
    when :cpu
      bar_monitor(@cpus, div, bookend)
    when :mem
      bar_monitor([@mem], div, bookend)
    when :swp
      bar_monitor([@swp], div, bookend)
    when :rkb  # received k/b
      bar_monitor([@received_transmitted[0]], div, bookend)
    when :tkb  # transmitted k/b
      bar_monitor([@received_transmitted[1]], div, bookend)
    else
      raise ArgumentError, "unrecognized type: #{type}"
    end
  end

  def weather!
    if (now=Time.now) - @last_weather_update >= @weather_check_sec
      @last_weather_update = now
      data = `weather --id=#{WEATHER_STATION}`
      @temp = data[%r{Temperature: (.*?) F},1]
    end
  end
  attr_accessor :temp

  # sets the @bat_dir ('+', '-', '0') and the @bat_percent as a float.
  def battery_status
    (status, percent) = `acpi -b`.split(': ').last.split(', ')
    status =
      case status
      when 'Discharging' then '-'
      when 'Charging' then '+'
      else '0'
      end
    @bat_dir = status
    @bat_percent = percent[0...-1].to_f
    self
  end

  # a bar that also reports the direction it is moving
  def moving_bar(type, div='', bookend='')
    case type
    when :bat
      @bat_dir + bar_monitor([@bat_percent])
    end
  end

  # returns the memory and swap as a percent
  def memory_swap_percents
    lines = `free`.split("\n")
    # [CAT]        total       used       free     shared    buffers     cached
    header = lines.shift
    mem = lines.shift
    swap = lines.pop
    [mem, swap].map do |line|
      data = line.chomp.split(/\s+/)
      # used / total
      used = 
        if data[5]
          data[2].to_f - data[5].to_f - data[6].to_f
        else
          data[2].to_f
        end
      ( used / data[1].to_f) * 100
    end
  end

  # returns the percent of the max, but no more than 100.0
  def percent_no_gt(max=100.0, value)
    perc = 100 * (value / max)
    (perc > 100) ? 100 : perc
  end

  # returns percent of max_kbs
  def received_transmitted(max_kbs=MAX_KBS)
    lines = `sar -n DEV #{@sleep} 1`.split("\n")
    relevant_lines = lines[3..-1].take_while {|line| line =~ /\w/ }
    data_ar = relevant_lines.map do |line|
      data = line.split(/\s+/)
      # interface, rxkb, txkb
      [data[2], percent_no_gt(max_kbs, data[5].to_f), percent_no_gt(max_kbs, data[6].to_f)]
    end
    data = data_ar.find {|ar| ar[0] == NETWORK_INTERFACE }
    @received_transmitted = data[1..-1]
  end

  # 04:09:43 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
  def processor_percents
    reply = `sar -P ALL #{@sleep} 1`
    lines = reply.split("\n")
    header = lines.shift
    num_cpus = header[/\((\d+) CPU\)$/, 1].to_i
    # read a cycle
    3.times { lines.shift }
    @cpus = num_cpus.times.map do
      line = lines.shift
      line.chomp!
      # the total usage (100% - idle)
      100.0 - line[/\s+([\d\.]+)$/,1].to_f
    end
  end

  def percent_bar(percent=0.0)
    BAR[(percent.to_f / 12.5).floor]
  end

  def bar_monitor(data, div='', bookend='')
    bars = data.map {|p| percent_bar(p) }.join(div)
    bookend + bars + bookend
  end
end


class StatusBar

  class Group < Array
    def initialize(data=[], sep=" ")
      super(data)
      @sep = sep
    end

    def to_s
      self.join(@sep)
    end
  end

  GLYPH = OpenStruct.new( {
    broken_vertical_bar: '¦',
    vertical_bar: '|',
    light_vertical_bar: '❘', # not recognized
    thick_bar: '┃',
    thin_3_part_bar: '┆',
    weird: '§',
    lozenge: '⧫', # not recognized
    br_triangle: '▶',
    bl_triangle: '◀',
    six_per_em_space: ' ',
    up_arrow: '↑',
    dn_arrow: '↓',
    vertical_ellipsis: '⋮',
    circled_star: '⊛',
    double_wide_diamond: '◀▶',
  } )

  DEFAULT_SEP = " #{GLYPH.double_wide_diamond} "

  attr_accessor :sep
  attr_accessor :sections

  def initialize(sep=DEFAULT_SEP)
    @sep = sep
    @sections = []
  end

  def display(&block)
    Kernel.loop do  
      block.call(self)
      puts self.urp
    end
  end

  # gives the status message and clears sections array
  def urp
    to_display = to_s
    @sections.clear
    to_display
  end

  def to_s
    sections.join(sep).concat(sep)
  end

  # adds the string as a section
  def <<(section)
    @sections << section.to_s
  end
end


status_bar = StatusBar.new
monitor = SysMonitor.new
G = StatusBar::GLYPH

status_bar.display do |status_bar|
  # sleep duration is pegged to monitor updates right now
  monitor.update!
  mons = []
  mons << "bat" + monitor.moving_bar(:bat, '', '') if HAVE_ACPI
  mons << "cpu" + monitor.bar(:cpu, G.thin_3_part_bar, G.thin_3_part_bar)
  mons.push( [:mem, :swp].map {|type| type.to_s + monitor.bar(type, '', '')}.join("  ") )
  mons.push( NETWORK_INTERFACE + [:rkb, :tkb].zip([G.dn_arrow, G.up_arrow]).map {|type, sym| sym + " " + monitor.bar(type) }.join("  ") )
  #sys_monitor_bars = [:cpu, :mem, :swp, :rkb, :tkb].map {|type| type.to_s + monitor.bar(type, '', '|') }

  status_bar << StatusBar::Group.new( mons, "  #{G.double_wide_diamond}  " )
  status_bar << Time.now.strftime( "%a %Y-%m-%d %l:%M %P" )
  status_bar << (monitor.temp + "°F")
end
