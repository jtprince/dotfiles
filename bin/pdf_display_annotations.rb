#!/usr/bin/env ruby

# still need to figure out how to print out who the annotation belongs to

# apti libglib2.0-dev libpoppler-dev
# gem install glib2 poppler gdk_pixbuf2 andand

require 'andand'
require 'poppler'
require 'optparse'


def date(annotation)
  begin
    annotation.respond_to?(:date) ? annotation.date : nil
  rescue
    nil
  end
end

def display_annotation(annotation)
  [
    [
      (annotation.respond_to?(:subject) ? annotation.subject : annotation.type.nick),
      date(annotation),
    ].compact.join(" - ") << ":", 
    (text=annotation.contents) ? text.gsub("\r", "\n") : "<no associated text>"
  ].join("\n")
end

opts = OptionParser.new do |op|
  op.banner = "usage: #{$0} <input>.pdf"
end
opts.parse!

if ARGV.size < 1
  puts opts
  exit
end

ARGV.each do |file|
  input_uri = "file://#{File.expand_path(file)}"
  Poppler::Document.new(input_uri).each do |page|
    page.annot_mapping.each do |obj|
      puts display_annotation(obj.annot), "\n"
    end
  end
end


# text
# [:open?, :icon, :state, :label, :popup_is_open?, :opacity, :date, :subject, :reply_to, :external_data, :type, :contents, :name, :modified, :flags, :color, :notify, :set_property, :get_property, :freeze_notify, :thaw_notify, :destroyed?, :ref_count, :type_name, :gtype, :signal_has_handler_pending?, :signal_connect, :signal_connect_after, :signal_emit, :signal_emit_stop, :signal_handler_block, :signal_handler_unblock, :signal_handler_disconnect, :signal_handler_is_connected?]

# line
# [:type, :contents, :name, :modified, :flags, :color, :notify, :set_property, :get_property, :freeze_notify, :thaw_notify, :destroyed?, :ref_count, :type_name, :gtype, :signal_has_handler_pending?, :signal_connect, :signal_connect_after, :signal_emit, :signal_emit_stop, :signal_handler_block, :signal_handler_unblock, :signal_handler_disconnect, :signal_handler_is_connected?]
#
#[:type, :contents, :name, :modified, :flags, :color, :notify, :set_property, :get_property, :freeze_notify, :thaw_notify, :destroyed?, :ref_count, :type_name, :gtype, :signal_has_handler_pending?, :signal_connect, :signal_connect_after, :signal_emit, :signal_emit_stop, :signal_handler_block, :signal_handler_unblock, :signal_handler_disconnect, :signal_handler_is_connected?]
