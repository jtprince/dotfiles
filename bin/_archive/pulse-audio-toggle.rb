#!/usr/bin/env ruby

class String
  def remove_gt_lt
    self.sub('<', '').chomp('>')
  end
end

Card = Struct.new(:index, :name, :profiles, :profile_availability) do
  def to_s
    lines = [
      "#{self.name}",
      "profiles: ",
    ]
    profile_lines = self.profiles.select(&:maybe_available).map do |profile|
      selected = (profile.code == self.profile_availability) ? '* ' : '  '
      "  " + selected + [profile.code, profile.description].join(' ')
    end
    (lines + profile_lines).join("\n")
  end
end

Profile = Struct.new(:code, :description, :availability) do
  def name()
    self.code.split(':').last
  end

  def output()
    self.io_type == 'output'
  end

  def input()
    self.io_type == 'input'
  end

  def io_type()
    self.code.split(':').first
  end

  def maybe_available()
    ['yes', 'unknown'].include?(self.availability)
  end
end


# returns a Profile object
#
# Takes a line like this:
#   output:hdmi-stereo: Digital Stereo (HDMI) Output (priority 5400, available: unknown)
# And returns a s
def create_profile(line)
  profile, desc_and_avail = line.strip.split(': ', 2)
  if desc_and_avail.include?(' Output ')
    desc, priority_avail = desc_and_avail.split(' Output ')
  else
    desc, priority_avail = desc_and_avail.split(' (', 2)
  end
  availability = priority_avail.chomp(')').split(', ').last.split(': ').last
  Profile.new(profile, desc, availability)
end

# Expects all the lines related to a single card
# returns Card
def get_card(card_lines)
  index = card_lines.shift.split(': ').last.to_i
  name = card_lines.shift.split(': ').last.remove_gt_lt

  profiles = []
  reading_profiles = false
  active_profile = nil
  card_lines.each do |line|
    if line =~ /^\s+active profile: /
      active_profile = line.split(': ').last.remove_gt_lt
      break
    elsif reading_profiles
      profiles << create_profile(line)
    elsif line =~ /^\s+profiles:/
      reading_profiles = true
    end
  end
  Card.new(index, name, profiles, active_profile)
end

def breakup_lines_by_card(lines)
  cards = []
  lines.each do |line|
    line =~ /^\s*index: \d+$/ ? (cards << [line]) : (cards.last << line)
  end
  cards
end


info = `pacmd list-cards`
lines = info.split("\n")
nesting = "    "

num_cards = lines.shift.split(/\s+/)[0].to_i

cards = breakup_lines_by_card(lines).map do |chunk_of_lines|
  get_card(chunk_of_lines)
end

puts cards.map(&:to_s).join("\n\n")


# An example of the output that we're parsing.
# We care about
#   * the number of cards available
#   * the name of each card
#   * the profiles available for each card
#   * the active profile
__END__
2 card(s) available.    
    index: 0
    name: <alsa_card.pci-0000_00_03.0>
    driver: <module-alsa-card.c>
    owner module: 6
    properties:
        alsa.card = "0"
        alsa.card_name = "HDA Intel HDMI"
        alsa.long_card_name = "HDA Intel HDMI at 0xf7d1c000 irq 48"
        alsa.driver_name = "snd_hda_intel"
        device.bus_path = "pci-0000:00:03.0"
        sysfs.path = "/devices/pci0000:00/0000:00:03.0/sound/card0"
        device.bus = "pci"
        device.vendor.id = "8086"
        device.vendor.name = "Intel Corporation"
        device.product.id = "0a0c"
        device.product.name = "Haswell-ULT HD Audio Controller"
        device.form_factor = "internal"
        device.string = "0"
        device.description = "Built-in Audio"
        module-udev-detect.discovered = "1"
        device.icon_name = "audio-card-pci"
    profiles:
        output:hdmi-stereo: Digital Stereo (HDMI) Output (priority 5400, available: unknown)
        output:hdmi-stereo-extra1: Digital Stereo (HDMI 2) Output (priority 5200, available: no)
        output:hdmi-surround-extra1: Digital Surround 5.1 (HDMI 2) Output (priority 100, available: no)
        output:hdmi-surround71-extra1: Digital Surround 7.1 (HDMI 2) Output (priority 100, available: no)
        output:hdmi-stereo-extra2: Digital Stereo (HDMI 3) Output (priority 5200, available: no)
        output:hdmi-surround-extra2: Digital Surround 5.1 (HDMI 3) Output (priority 100, available: no)
        output:hdmi-surround71-extra2: Digital Surround 7.1 (HDMI 3) Output (priority 100, available: no)
        output:hdmi-stereo-extra3: Digital Stereo (HDMI 4) Output (priority 5200, available: no)
        output:hdmi-surround-extra3: Digital Surround 5.1 (HDMI 4) Output (priority 100, available: no)
        output:hdmi-surround71-extra3: Digital Surround 7.1 (HDMI 4) Output (priority 100, available: no)
        output:hdmi-stereo-extra4: Digital Stereo (HDMI 5) Output (priority 5200, available: no)
        output:hdmi-surround-extra4: Digital Surround 5.1 (HDMI 5) Output (priority 100, available: no)
        output:hdmi-surround71-extra4: Digital Surround 7.1 (HDMI 5) Output (priority 100, available: no)
        off: Off (priority 0, available: unknown)
    active profile: <output:hdmi-stereo>
    sinks:
        alsa_output.pci-0000_00_03.0.hdmi-stereo/#0: Built-in Audio Digital Stereo (HDMI)
    sources:
        alsa_output.pci-0000_00_03.0.hdmi-stereo.monitor/#0: Monitor of Built-in Audio Digital Stereo (HDMI)
    ports:
        hdmi-output-0: HDMI / DisplayPort (priority 5900, latency offset 0 usec, available: yes)
            properties:
                device.icon_name = "video-display"
                device.product.name = "LG IPS FULLHD"
        hdmi-output-1: HDMI / DisplayPort 2 (priority 5800, latency offset 0 usec, available: no)
            properties:
                device.icon_name = "video-display"
        hdmi-output-2: HDMI / DisplayPort 3 (priority 5700, latency offset 0 usec, available: no)
            properties:
                device.icon_name = "video-display"
        hdmi-output-3: HDMI / DisplayPort 4 (priority 5600, latency offset 0 usec, available: no)
            properties:
                device.icon_name = "video-display"
        hdmi-output-4: HDMI / DisplayPort 5 (priority 5500, latency offset 0 usec, available: no)
            properties:
                device.icon_name = "video-display"
    index: 1
    name: <alsa_card.pci-0000_00_1b.0>
    driver: <module-alsa-card.c>
    owner module: 7
    properties:
        alsa.card = "1"
        alsa.card_name = "HDA Intel PCH"
        alsa.long_card_name = "HDA Intel PCH at 0xf7d18000 irq 45"
        alsa.driver_name = "snd_hda_intel"
        device.bus_path = "pci-0000:00:1b.0"
        sysfs.path = "/devices/pci0000:00/0000:00:1b.0/sound/card1"
        device.bus = "pci"
        device.vendor.id = "8086"
        device.vendor.name = "Intel Corporation"
        device.product.id = "9c20"
        device.product.name = "8 Series HD Audio Controller"
        device.form_factor = "internal"
        device.string = "1"
        device.description = "Built-in Audio"
        module-udev-detect.discovered = "1"
        device.icon_name = "audio-card-pci"
    profiles:
        input:analog-stereo: Analog Stereo Input (priority 60, available: unknown)
        output:analog-stereo: Analog Stereo Output (priority 6000, available: unknown)
        output:analog-stereo+input:analog-stereo: Analog Stereo Duplex (priority 6060, available: unknown)
        off: Off (priority 0, available: unknown)
    active profile: <input:analog-stereo>
    sources:
        alsa_input.pci-0000_00_1b.0.analog-stereo/#1: Built-in Audio Analog Stereo
    ports:
        analog-input-mic: Microphone (priority 8700, latency offset 0 usec, available: unknown)
            properties:
                device.icon_name = "audio-input-microphone"
        analog-output-speaker: Speakers (priority 10000, latency offset 0 usec, available: unknown)
            properties:
                device.icon_name = "audio-speakers"
        analog-output-headphones: Headphones (priority 9000, latency offset 0 usec, available: no)
            properties:
                device.icon_name = "audio-headphones"
