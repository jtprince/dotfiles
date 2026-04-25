#!/usr/bin/env ruby

# written mainly as an exercise

require 'ruby-mpd'
require 'builder'

def mpdi(&block)
  mpd = MPD.new
  mpd.connect
  block.call(mpd)
  mpd.disconnect
end

# yields an array of song data

tablecss =<<TABLECSS
<style type="text/css">
  table.gridtable {
    font-family: verdana,arial,sans-serif;
    font-size:11px;
    color:#333333;
    border-width: 1px;
    border-color: #666666;
    border-collapse: collapse;
  }
  table.gridtable th {
    border-width: 1px;
    padding: 8px;
    border-style: solid;
    border-color: #666666;
    background-color: #dedede;
  }
  table.gridtable td {
    border-width: 1px;
    padding: 2px;
    border-style: solid;
    border-color: #666666;
    background-color: #ffffff;
  }
</style>
TABLECSS
tablecss = tablecss.each_line.map {|l| (" " * 4) << l }

cats = %i(artist album title length)
song_giver = Enumerator.new do |sg|
  mpdi do |mpd|
    mpd.songs.each do |song|
      if song.artist && song.title
        sg << cats.map {|cat| song.send(cat) }.to_a
      end
    end
  end
end

xml = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
xml.instruct!(:xml, :encoding => "UTF-8")

xml.html do |html|
  html.head { STDOUT.puts tablecss }
  html.body do |body|
    body.table(class: 'gridtable') do |table|
      table.tr do |header_row|
        cats.each do |cat|
          header_row.th cat.to_s
        end
      end
      song_giver.each do |song_data|
        table.tr do |tr|
          song_data.each do |datum|
            tr.td datum
          end
        end
      end
    end
  end
end
