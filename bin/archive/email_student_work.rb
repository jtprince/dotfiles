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

GRADESHEET_TXT = ".GRADING.txt"
GRADESHEET_MP3 = ".GRADING.mp3"

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
  op.separator %Q{<ADDRESSES>.txt:to has one address per line in this format!: "First M. Last" <address>}
  op.separator ""
  op.separator "WARNING: assumes unique last names!!!"
  op.separator ""
  op.on("-s", "--subject <string>", "subject line, def: #{opt.subject}") {|v| opt.subject = v }
  op.on("-b", "--body <string>", "body def: #{opt.body}") {|v| opt.body = v }
  op.on(
    "-g", "--grade-sheet-as-body", 
    "grabs <paper>#{GRADESHEET_TXT} and makes body", 
    "will also attach <paper>#{GRADESHEET_MP3} if exists"
  ) do |v| 
    opt.grade_sheet = v
  end
  op.on("-d", "--dry", "don't deliver the message") {|v| opt.dry = v }
end
parser.parse!

if ARGV.size < 2
  puts parser
  exit
end

unless opt.dry
  print "gmail password: "
  gmail_password = STDIN.noecho(&:gets).chomp
  puts
end

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

if opt.grade_sheet
  opt.delete_field(:body)
end

last_name_to_file.each do |last_name, filename|
  puts
  if opt.dry
    puts "** <PRETEND MAIL> **"
  else
    puts "** SENDING MAIL **"
  end

  base = filename.chomp(File.extname(filename))
  gradesheet = base + GRADESHEET_TXT
  audiofile = base + GRADESHEET_MP3
  mail = Mail.new
  mail.charset = 'UTF-8'
  opt.to_h.each do |k,v|
    mail[k] = v
  end
  mail[:to] = last_name_to_address[last_name]

  puts "TO: #{last_name_to_address[last_name]}"
  puts "SUBJECT: #{mail.subject}"

  if opt.grade_sheet
    body = IO.read( gradesheet )
    mail[:body] = body 
    if File.exist?(audiofile)
      puts "SOUND ATTACHMENT: #{audiofile}"
      mail.add_file(audiofile)
    end
    start_of_msg = ( body.split("\n")[0,3].join("\n") << "\n... (first 3 lines) ..." )
    puts "MESSAGE: \n#{start_of_msg}"
  end

  puts "ATTACHMENT: #{filename}"
  mail.add_file filename

  unless opt.dry
    mail.deliver!
    sleep 10  # I think gmail gets mad if I do too many too fast
  end
end
