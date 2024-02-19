#!/usr/bin/env ruby

ZOOKEEPER_URL = "localhost:2181"

BASE_CMD = "kafka-topics.sh --zookeeper #{ZOOKEEPER_URL}"

list_cmd = [BASE_CMD, "--list"].join(' ')
puts(list_cmd)

topics = `#{list_cmd}`.split("\n").map(&:chomp)

topics.each do |topic|
  delete_cmd = [BASE_CMD, '--delete', '--topic', topic].join(' ')
  puts delete_cmd
  `#{delete_cmd}`
end
