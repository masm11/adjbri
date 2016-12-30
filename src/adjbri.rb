#!/usr/bin/env ruby

require 'gtk3'

BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/brightness'
MAX_BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/max_brightness'

if ARGV[0].nil? || ARGV[0] == '--help'
  puts "Usage: #{$0} <brightness[,...]>"
  puts "Example:"
  puts "  #{$0} 1,25%,50%"
  exit 1
end
brightnesses = ARGV[0].split(',')

icon = Gtk::StatusIcon.new
icon.icon_name = 'display'
icon.tooltip_text = 'Brightness'

@max = 1
open(MAX_BRIGHTNESS_PATH) do |f|
  @max = f.readline.strip.to_i
end

@cur = @max
open(BRIGHTNESS_PATH) do |f|
  @cur = f.readline.strip.to_i
end

def brightness_to_value(str)
  return @max * str.to_i / 100 if str =~ /%$/
  return str.to_i
end

menu = Gtk::Menu.new
brightnesses.each do |str|
  str = str.to_s
  item = Gtk::MenuItem.new(str)
  item.signal_connect('activate') do |w|
    @cur = brightness_to_value w.label
    set_brightness
    icon.tooltip_text = "Brightness #{w.label}"
  end
  item.show
  menu.add item
  
  if brightness_to_value(str) == @cur
    icon.tooltip_text = "Brightness #{str}"
  end
end

icon.signal_connect('popup_menu') do |w, btn, time|
  menu.popup(nil, nil, btn, time)
end

def set_brightness
  open(BRIGHTNESS_PATH, 'r+') do |f|
    f.write(@cur.to_s)
  end
end

GLib::Timeout.add(1000) do
  set_brightness
  true
end

Gtk.main
