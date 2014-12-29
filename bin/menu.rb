#!/usr/bin/env ruby

require 'ostruct'

class App < OpenStruct
  class << self
    def from_desktop_file(file)
      lines = IO.readlines(file).drop_while(&:empty?)
      desktop = lines.shift
      return nil unless desktop && desktop =~ /[Desktop Entry]/
      hash = lines.each_with_object({}) do |line, hash|
        if md=line.match(/([^=]+)=(.*)/)
          hash[md[1].downcase] = md[2]
        end
      end
      App.new( hash )
    end
  end

  def cats
    return [] unless cts = categories
    cts.split(';').compact
  end
end

branch = 'share/applications'
desktop_glob = "*.desktop"

dirs = [
  ENV['HOME'] + "/.local/#{branch}", # home
  ENV['HOME'] + "/Desktop",          # desktop
  "/usr/#{branch}",                  # shared
]

desktop_files = dirs.flat_map {|dir| Dir[dir + '/' + desktop_glob] }

objs = desktop_files.map {|f| App.from_desktop_file(f) }.compact

cats = objs.each_with_object(Hash.new {|h,k| h[k] = [] }) do |app, cat_to_objs|
  app.cats.each do |cat|
    cat_to_objs[cat] << app
  end
end

sorted = cats.sort_by {|cat,objs| -objs.size }
sorted.each do |cat, objs|
  puts cat
  objs.each do |obj|
    puts "  #{obj.name}: #{obj.exec}"
  end
end
