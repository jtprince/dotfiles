#!/usr/bin/env ruby

require 'mail'
require 'optparse'
require 'io/console'

## to is a string or an array
#def send_email(from, to, subject, message)
  #from_email = get_from_email(from) 
  #to_email = get_to_email(to)

  #msg = <<END_OF_MESSAGE
#From: #{from}
#To: #{to}
#Subject: #{subject}

##{message}
#END_OF_MESSAGE

  ## on local machine with smtp
  #Net::SMTP.start('localhost') do |smtp|
    #smtp.send_message(msg, from_email, *to_email)
  #end
#end

opt = {}
opt[:from] = '"John T. Prince" <jtprince@gmail.com>'
opt[:subject] = '(no subject)'
opt[:message] = ''
opt[:attachments] = []

parser = OptionParser.new do |op|
  prog = File.basename(__FILE__)
  op.banner = "usage: #{prog} to ... [-s subject] [-m message]"
  op.on('-f', '--from <from>', "'from email def: '#{opt[:from]}'") {|v| opt[:from] = v}
  op.on('-m', '--message <message>', "'my message' def: '#{opt[:message]}'") {|v| opt[:body] = v}
  op.on('-s', '--subject <subject>', "'my subject' def: '#{opt[:subject]}'") {|v| opt[:subject] = v}
  op.on('-a', '--attachment <filepath>', "def: '#{opt[:attachments]}'") {|v| opt[:attachments] << v}

  op.separator ""
  op.separator "examples:"
  op.separator "  #{prog} mine@home.com bob@gmail.com sally@yahoo.com \\"
  op.separator "          -s hi -m 'my message'"
  op.separator "  #{prog} 'Sender <mine@home.com>' 'Bob <bob@gmail.com>' \\"
  op.separator "          'Sally <sally@yahoo.com>' -s hi -m 'my message'"
  op.separator "  #{prog} mine@home.com 'bob@gmail.com, sally@yahoo.com' \\"
  op.separator "          -s hi -m 'my message'"
end

parser.parse!

if ARGV.size < 1
  puts parser
  exit
end

print "gmail password: "
gmail_password = STDIN.noecho(&:gets).chomp

Mail.defaults do
  delivery_method :smtp, {
    address: "smtp.gmail.com",
    port: 587,
    user_name: 'jtprince',
    password: gmail_password,
    authentication: :plain,
    enable_starttls_auto: true,
  }
end

opt[:to] = ARGV.to_a

attachments = opt.delete(:attachments)

mail = Mail.new
opt.each do |key,val|
  mail[key] = val
end

attachments.each do |attachment|
  mail.add_file attachment
end

mail.deliver!



