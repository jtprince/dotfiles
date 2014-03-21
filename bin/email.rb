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
emails = {
  gmail: '"John T. Prince" <jtprince@gmail.com>',
  chem: '"John T. Prince" <jtprince@chem.byu.edu>',
}

opt = {}
opt[:from] = emails.values.first
opt[:subject] = '(no subject)'
opt[:message] = ''
opt[:attachments] = []

parser = OptionParser.new do |op|
  prog = File.basename(__FILE__)
  op.banner = "usage: #{prog} to ... [-s subject] [-m message] [-a attachment]"
  op.on('-f', '--from <from>', "'from email (1st is def: #{emails.keys.join('|')})", "can give key or real email") do |v| 
    opt[:from] = v.include?('@') ? v : emails[v.to_sym]
  end
  op.on('-m', '--message <message>', "'my message' def: '#{opt[:message]}'") {|v| opt[:body] = v}
  op.on('-s', '--subject <subject>', "'my subject' def: '#{opt[:subject]}'") {|v| opt[:subject] = v}
  op.on('-a', '--attachment <filepath>', "def: '#{opt[:attachments]}'") {|v| opt[:attachments] << v}
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



