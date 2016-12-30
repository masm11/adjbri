#!/usr/bin/env ruby

#    adjbri.rb - Select preferrable brightness.
#    Copyright (C) 2016 Yuuki Harano
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
