#!/usr/bin/env ruby

require 'open-uri'
require 'json'

usernames = ARGV.dup

def download(url)
  puts url
  raw_data = open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}", &:read)
  [raw_data, JSON.parse(raw_data)]
end

def filename(num)
  num.to_s.rjust(5, "0") + ".json"
end

url = nil
usernames.each do |username|
  num = 0
  base = "https://www.reddit.com/user/" + username + ".json"
  url ||= base
  raw, data = download(url)
  File.write(filename(num), raw)

  while after = data['data']['after']
    sleep(rand(1..10))
    url = base + "?count=25&after=#{after}"
    raw, data = download(url)
    num += 1
    File.write(filename(num), raw)
  end
end
