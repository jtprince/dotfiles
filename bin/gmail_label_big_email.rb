#!/usr/bin/env ruby

require 'highline/import'
require 'gmail'

STD_LABELS = Hash[ [1, 5, 10, 15].map {|n| [n, "gt_#{n}MB"] } ]

if ARGV.size == 0
  puts "usage: #{File.basename(__FILE__)} username"
  puts "(prompts for password)"
  puts "labels emails based on total size"
  puts "NEED TO EXPAND to include more than INBOX"
  exit
end

username = ARGV.shift
password = ask("Enter your gmail password: ") {|q| q.echo = "*" }

logged_in_status = []

Gmail.connect!(username, password) do |gmail|
  STD_LABELS.values.each do |std_label|
    gmail.labels.add(std_label) unless gmail.labels.exists?(std_label)
  end

  gmail.inbox.emails(:all).each do |email|
    begin
      message = email.raw_message
      size_mb = message.raw_source.size.to_f / 1_000_000
      puts "SUBJECT: #{message.subject}"
      puts size_mb.to_s
      STD_LABELS.keys.reverse.each do |n|
        if size_mb >= n
          puts "labeling! #{STD_LABELS[n]}"
          email.label!(STD_LABELS[n])
          break
        end
      end
      logged_in_status << gmail.logged_in?
    rescue
      (trues, falses) = logged_in_status.partition
      puts "NUM TRUES and FALSES on logged in: "
      p trues.size
      p falses.size
      puts "LAST 10 entries"
      puts logged_in_status[-10..-1]
      puts "LOGGED IN ON ERROR (NOW)?: "
      p gmail.logged_in?
    end
  end
end

