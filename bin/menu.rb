#!/usr/bin/env ruby

require 'ostruct'
require 'andand'

class App < OpenStruct
  def major_cat
    cats.andand.first
  end

  def cats
    return [] unless cts = categories
    cts.split(';').compact
  end
end

def desktop_file_to_object(file)
  lines = IO.readlines(file)
  lines = lines.drop_while(&:empty?)
  desktop = lines.shift
  return nil unless desktop && desktop =~ /[Desktop Entry]/
  hash = lines.each_with_object({}) do |line, hash| 
    if md=line.match(/([^=]+)=(.*)/)
      hash[md[1].downcase] = md[2]
    end
  end
  App.new( hash )
end

branch = 'share/applications'
glob = "*.desktop"

home_items = ENV['HOME'] + "/.local/#{branch}"
shared_items = "/usr/#{branch}"
desktop_items = ENV['HOME'] + "/Desktop"

dirs = [shared_items, home_items, desktop_items]

desktop_files = dirs.flat_map {|dir| Dir[dir + '/' + glob] }
  
objs = desktop_files.map {|f| desktop_file_to_object(f) }.compact

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






=begin
[Desktop Entry]
Categories=Game;
Name=Sword & Sworcery
Exec=/opt/swordandsworcery/run.sh
Icon=/opt/swordandsworcery/swordandsworcery.jpg
Type=Application

[Desktop Entry]
Version=1.0
Type=Application
Name=GIMP Image Editor
GenericName=Image Editor
Comment=Create images and edit photographs
Exec=gimp-2.6 %U
TryExec=gimp-2.6
Icon=gimp
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;GTK;
X-GNOME-Bugzilla-Bugzilla=GNOME
X-GNOME-Bugzilla-Product=GIMP
X-GNOME-Bugzilla-Component=General
X-GNOME-Bugzilla-Version=2.6.12
X-GNOME-Bugzilla-OtherBinaries=gimp-2.6
StartupNotify=true
MimeType=application/postscript;application/pdf;image/bmp;image/g3fax;image/gif;image/x-fits;image/pcx;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-psd;image/x-sgi;image/x-tga;image/x-xbitmap;image/x-xwindowdump;image/x-xcf;image/x-compressed-xcf;image/tiff;image/jpeg;image/x-psp;image/png;image/x-icon;image/x-xpixmap;image/svg+xml;image/x-wmf;
X-Ubuntu-Gettext-Domain=gimp20

[Desktop Entry]
Type=Application
Name=notepad
MimeType=application/x-wine-extension-ini;
Exec=env WINEPREFIX="/home/jtprince/.wine" wine start /ProgIDOpen inifile %f
NoDisplay=true
StartupNotify=true
Icon=1E64_notepad.0
=end

