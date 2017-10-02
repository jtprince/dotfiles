#!/usr/bin/env ruby

require 'json'

email_address_fragment, hostname = ARGV.dup
email_address_fragment ||= 'prince'
hostname ||= "http://localhost"

json = `http GET "#{hostname}/api/organizations/dev/tokens/"`

data = JSON.parse(json)

user_data = data.find {|user| user['email_address'].include?(email_address_fragment)}

print user_data['api_token']
