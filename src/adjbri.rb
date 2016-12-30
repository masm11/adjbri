#!/usr/bin/env ruby

require 'gtk3'

BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/brightness'
MAX_BRIGHTNESS_PATH = '/sys/class/backlight/intel_backlight/max_brightness'

if ARGV[0].nil?
  puts "Usage: #{$0} <brightness[,...]>"
  puts "Example:"
  puts "  #{$0} 1,25%,50%"
  exit 1
end
brightnesses = ARGV[0].split(',')

icon = Gtk::StatusIcon.new
icon.icon_name = 'network-error'
icon.tooltip_text = 'Brightness'

min = 1
max = 1
open(MAX_BRIGHTNESS_PATH) do |f|
  max = f.readline.strip.to_i
end

@cur = min
open(BRIGHTNESS_PATH) do |f|
  @cur = f.readline.strip.to_i
end

menu = Gtk::Menu.new
brightnesses.each do |str|
  item = Gtk::MenuItem.new(str.to_s)
  item.signal_connect('activate') do |w|
    brightness = w.label
    if brightness =~ /%$/
      brightness = max * brightness.to_i / 100
    end
    @cur = brightness.to_i
    set_brightness
  end
  item.show
  menu.add item
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
