require 'gtk2'

tray = Gtk::StatusIcon.new
tray.tooltip = ""
tray.visible = true
tray.stock = Gtk::Stock::DIALOG_INFO

quit = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
quit.signal_connect('activate'){Gtk.main_quit}

entry = Gtk::Entry.new
entry.set_max_length( 50 )
entry.set_editable(true)
entry.set_text( "hello hello hello" )
entry.select_region( 0, -1 )
item = Gtk::MenuItem.new
item.add(entry)

menu=Gtk::Menu.new
menu.append(item)
menu.append(Gtk::SeparatorMenuItem.new)
menu.append(quit)
menu.show_all

tray.signal_connect("popup-menu") do |widget, button, time|
  puts widget, button, time
    if button == 3
      menu.popup(nil, nil, button, time)
    end
end

Gtk.main
