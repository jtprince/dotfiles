#!/usr/bin/ruby -w

require 'net/smtp'
require 'optparse'

# abstracts out the email address
def get_from_email(string)
  if string =~ /<(.*)>/
    $1.dup
  else
    string
  end
end

# arg is string or array
def get_to_email(arg)
  ar = 
    if arg.is_a? Array
      arg
    else
      arg.split(', ')
    end
  ar.map do |email|
    if email =~ /(.*)<(.*)>/ 
      $2.dup
    else
      email
    end
  end
end



# to is a string or an array
def send_email(from, to, subject, message)
  from_email = get_from_email(from) 
  to_email = get_to_email(to)

  msg = <<END_OF_MESSAGE
From: #{from}
To: #{to}
Subject: #{subject}

#{message}
END_OF_MESSAGE

  # on local machine with smtp
  Net::SMTP.start('localhost') do |smtp|
    smtp.send_message(msg, from_email, *to_email)
  end
end


if $0 == __FILE__

  # TODO: get working with ssl on gmail for output!

  opt = {}
  opt[:subject] = '(no subject)'
  opt[:message] = ''

  opts = OptionParser.new do |op|
    prog = File.basename(__FILE__)
    op.banner = "usage: #{prog} from to ... [-s subject] [-m message]"
    op.on('-m', '--message <message>', "'my message' def: '#{opt[:message]}'") {|v| opt[:message] = v}
    op.on('-s', '--subject <subject>', "'my subject' def: '#{opt[:subject]}'") {|v| opt[:subject] = v}

    op.separator ""
    op.separator "examples:"
    op.separator "  #{prog} mine@home.com bob@gmail.com sally@yahoo.com \\"
    op.separator "          -s hi -m 'my message'"
    op.separator "  #{prog} 'Sender <mine@home.com>' 'Bob <bob@gmail.com>' \\"
    op.separator "          'Sally <sally@yahoo.com>' -s hi -m 'my message'"
    op.separator "  #{prog} mine@home.com 'bob@gmail.com, sally@yahoo.com' \\"
    op.separator "          -s hi -m 'my message'"
    op.separator ""
    op.separator ""

  end

  opts.parse!

  if ARGV.size < 2
    puts opts
    abort
  end

  opt[:from] = ARGV.shift
  opt[:to] = ARGV.to_a.join(', ')

  send_email opt[:from], opt[:to], opt[:subject], opt[:message]

end



