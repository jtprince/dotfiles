#!/usr/bin/env ruby

require 'ostruct'

TOTAL_TRYING_SECONDS = 60
SLEEP_BETWEEN = 2
NUM_TRIES = TOTAL_TRYING_SECONDS / SLEEP_BETWEEN

mac_address = ARGV.shift
if not mac_address
  puts "usage: #{File.basename(__FILE__)} <macaddress>"
  puts "ensures power is on and then works for #{TOTAL_TRYING_SECONDS} seconds to connect"
  puts "to device until it is connected."
  exit
end

BASECMD = "bluetoothctl"

BLUETOOTHCTL = OpenStruct.new(
  power_is_on: "Changing power on succeeded",
  failed_to_connect: "Failed to connect: org.bluez.Error.Failed",
  successful_connect: "Connection successful",
)

MSGS = OpenStruct.new(
  attempting: "Attempting to connect to %s",
  unexpected_connection_msg: "Something totally awry %s",
  failure_to_poweron_bluetooth: "Could not turn bluetooth on!",
  connected_to: "Connected to %s",
  failed_connected_to: "Failed to connect to %s...",
  sleeping: "Sleeping for %d seconds and trying again...",
  unrecognized_response: "Unrecognized response from connect! %s",
)

def cmd(command, arg)
  bluetoothctl_cmd = [BASECMD, command, arg].join(' ')
  `#{bluetoothctl_cmd}`.chomp
end

def ensure_power_on!(tries = 3, sleep_for = 1.5)
  power_is_on = false
  response = nil
  tries.times.each do
    response = cmd('power', 'on')
    if response == BLUETOOTHCTL.power_is_on
      power_is_on = true
      break
    end
    sleep sleep_for
  end
  if power_is_on
    puts response
  else
    abort MSGS.failure_to_poweron_bluetooth
  end
end

# returns true if successful connect, false otherwise
def attempt_to_connect(mac_address, sleep_for = SLEEP_BETWEEN)
  connected = false
  response = cmd('connect', mac_address)
  response_lines = response.split("\n")
  if response_lines.first != MSGS.attempting % mac_address
    abort MSGS.unexpected_connection_msg % response_lines.join("\n")
  end
  case response_lines.last
  when BLUETOOTHCTL.successful_connect
    connected = true
    puts MSGS.connected_to % mac_address
  when BLUETOOTHCTL.failed_to_connect
    puts MSGS.failed_connected_to % mac_address...
    unless connected
      puts MSGS.sleeping % sleep_for
      sleep sleep_for
    end
  else
    abort MSGS.unrecognized_response % response_lines.join("\n")
  end
  connected
end

ensure_power_on!

NUM_TRIES.times do
  connected = attempt_to_connect(mac_address)
  break if connected
end
