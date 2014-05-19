#!/usr/bin/env ruby -wKU

require 'rubygems'
require 'rmagick'

# this version is for miracle grue gcode
# TODO: may need to turn off fan during dark colors?

# Usage: ruby veneer.rb filename.gcode filename.png > new.gcode

# you'll then need to use gpx to convert it to x3g since makerware no longer lets you print gcode :(
# https://github.com/whpthomas/GPX
# Usage: gpx -m r2 new.gcode new.x3g

# This simple proof of concept expects a 100x100 pixel png and a cylinder with 100 sides

gcode_filename = ARGV.shift || "rep2.gcode"
img_filename = ARGV.shift || "checker_board.png"
pixels = []

img = Magick::Image::read(img_filename)[0]
img = img.quantize(256, Magick::GRAYColorspace)
img.flip!
# puts "This image is #{img.columns}x#{img.rows} pixels"

# puts img.pixel_color(0,0).intensity/257
# img.rows.times do |row|
#   line = ""
#   img.columns.times do |col|
#     line << (img.pixel_color(col, row).intensity/257 == 255 ? 1 : 0).to_s
#   end
#   puts line
# end

in_perimeter = false
current_row = 0
current_column = 0

File.open(gcode_filename, "r") do |file|
  file.each_line do |line|
    if line =~ /Connection$/
      in_perimeter = true
      current_row += 1
      current_column = 0
    end

    if line =~ /Restart$/
      in_perimeter = false
      current_column = 0
    end
    
    if in_perimeter
      if line =~ /^G1.*X.*Y.*Z.*F.*A.*; Outline$/
        current_column += 1
      end
    
      if line =~ /^G1 X(.*) Y(.*) Z(.*) F(.*) A(.*); Outline$/
        x = $1
        y = $2
        z = $3
        f = $4
        a = $5

        # old: black and white
        # darkness = img.pixel_color(current_column-1, current_row-1).intensity/257 == 255 ? 0 : 1
        # slow speed down on black parts
        # if darkness == 1
        #   f = f.to_f/4.0
        #   # slow down extrusion?
        #   # e = e.to_f/4.0
        # end

        # new grayscale as percentage of intensity
        darkness = (img.pixel_color(current_column-1, current_row-1).intensity/257).to_f / 255.0
        # assume minimum speed is 1/5th for black (darkness=1) and full speed is white (darkness=0)
        min_speed = f.to_f / 4.0
        max_speed = f.to_f
        f = (((max_speed - min_speed) / 100.0) * (darkness * 100.0)) + min_speed;
        # puts "#{darkness} darkness = #{f} speed"
      
        puts "G1 X#{x} Y#{y} Z#{z} F#{f} A#{a}"
      else
        puts line
      end
    else
      puts line
    end
  end
end