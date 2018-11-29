#!/usr/bin/env ruby

require 'json'

email_address_fragment, hostname = ARGV.dup
email_address_fragment ||= 'prince'
hostname ||= "http://localhost"

json = `http GET "#{hostname}/timp/organizations/dev/tokens/"`

data = JSON.parse(json)

if email_address_fragment.include?("-l")
  puts data.map {|user| user['email_address'] }
else
  user_data = data.find {|user| user['email_address'].include?(email_address_fragment)}
  print user_data['api_token']
end

