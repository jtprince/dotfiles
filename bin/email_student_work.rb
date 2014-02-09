#!/usr/bin/env ruby

require 'mail'
require 'optparse'
require 'ostruct'
require 'io/console'

## My mock Mail object for testing only!
#class Mail < Hash
  #attr_accessor :files
  #def initialize(*args)
    #@files = []
    #super(*args)
  #end
  #def add_file(file)
    #@files << file
  #end
  #def deliver!
    #puts "pretending:"
    #p self
    #p self.files
  #end
#end

def email_address_to_name(address)
  address.match(/"([^"]+)"/)[1]
end

def name_to_lastname(name)
  name.split(/\s+/).last
end

def basename_to_lastname(basename)
  basename.split(/[\._]/).first
end

opt = OpenStruct.new({
  subject: 'assignment graded',
  from: '"John T. Prince" <jtprince@gmail.com>',
  body: 'Assignment attached',
  attachments: [],
})

parser = OptionParser.new do |op|
  op.banner = "usage: #{File.basename($0)} <ADDRESSES>.txt student_paper ..."
  op.separator "student_paper: named <Last.> or <Last_>"
  op.separator %Q{<ADDRESSES>.txt:to have one address per line "First M. Last" <address>}
  op.on("-s", "--subject <string>", "subject line, def: #{opt.subject}") {|v| opt.subject = v }
  op.on("-b", "--body <string>", "body def: #{opt.body}") {|v| opt.body = v }
end
parser.parse!

if ARGV.size < 2
  puts parser
  exit
end

print "gmail password: "
gmail_password = STDIN.noecho(&:gets).chomp
puts

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

addresses_file = ARGV.shift
student_files = ARGV.dup

addresses = IO.readlines(addresses_file).map(&:chomp).reject {|address| address.size < 1 }.compact

last_name_to_address = addresses.each_with_object({}) do |address, hash| 
  hash[ name_to_lastname( email_address_to_name(address) ) ] = address
end

basename_to_filename = student_files.each_with_object({}) do |file,hash| 
  hash[File.basename(file)] = file
end

last_name_to_file = basename_to_filename.keys.each_with_object({}) do |basename, hash| 
  hash[basename_to_lastname(basename)] = basename_to_filename[basename]
end

last_name_to_file.each do |last_name, filename|
  mail = Mail.new
  opt.to_h.each do |k,v|
    mail[k] = v
  end
  mail[:to] = last_name_to_address[last_name]
  mail.add_file filename
  puts
  puts "** SENDING MAIL **"
  puts "TO: #{last_name_to_address[last_name]}"
  puts "SUBJECT: #{mail.subject}"
  puts "ATTACHMENT: #{filename}"
  mail.deliver!
end
