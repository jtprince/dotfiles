#!/usr/bin/env ruby

require 'mail'
require 'optparse'
require 'io/console'

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
  op.on('--msgfile <file>', "sets the message from <file> contents") {|v| opt[:body] = IO.read(v, encoding: 'UTF-8') }
  op.on('-s', '--subject <subject>', "'my subject' def: '#{opt[:subject]}'") {|v| opt[:subject] = v}
  op.on('-a', '--attachment <filepath>', "def: '#{opt[:attachments]}'") {|v| opt[:attachments] << v}
  op.on('-d', '--dry', "don't actually send the email") {|v| opt[:dry] = v }
end

parser.parse!

if ARGV.size < 1
  puts parser
  exit
end

unless opt[:dry]
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
end

opt[:to] = ARGV.to_a

attachments = opt.delete(:attachments)

mail = Mail.new
mail.charset = 'UTF-8'

opt.each do |key,val|
  mail[key] = val
end

attachments.each do |attachment|
  mail.add_file attachment
end

if opt[:dry]
  puts "=" * 78
  puts mail.subject
  puts "-" * 78
  puts mail.body
  puts "-" * 78
  puts "ATTACHMENTS (num): (#{mail.attachments.size})"
  puts "=" * 78
else
  mail.deliver!
end
