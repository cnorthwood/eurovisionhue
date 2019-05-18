require 'color'
require 'hue'
require 'json'
require 'miro'
require 'nokogiri'
require 'open-uri'

# TODO: this is the semi-final blog post
url = 'https://oneurope.co.uk/live-blog/live-blog-eurovision-2019-second-semi-final/'

hue = Hue::Client.new

def colour_to_hue(colour)
  r = colour.r
  g = colour.g
  b = colour.b
  max = [r, g, b].max
  min = [r, g, b].min
  delta = max - min
  v = max * 100

  s = if max != 0.0
        delta / max * 100
      else
        0.0
      end

  if s == 0.0
    h = 0.0
  else
    if r == max
      h = (g - b) / delta
    elsif g == max
      h = 2 + (b - r) / delta
    elsif b == max
      h = 4 + (r - g) / delta
    end

    h *= 60.0

    h += 360.0 if h < 0
  end

  {
    hue: (h * 182.04).round,
    saturation: (s / 100.0 * 255.0).round,
    bri: (v / 100.0 * 255.0).round
  }
end

def find_country(text)
  country_names = Dir.entries('flags')
                     .map { |filename| filename.split('.')[0] }
                     .reject(&:nil?)
  mentioned_countries = country_names.select { |country_name| text.downcase.include? country_name.downcase }
  mentioned_countries.first
end

current_country = nil

loop do
  doc = Nokogiri::HTML(open(url, read_timeout: 10))
  new_country = doc.css('.livedojo_title').map { |elem| find_country(elem.text) }.reject(&:nil?).first
  puts "Detected change to #{new_country} on the live blog" if new_country != current_country
  if new_country != current_country
    current_country = new_country
    colours = Miro::DominantColors.new("flags/#{new_country}.png")
    hue.lights.each_with_index do |light, i|
      light.on!
      rgb = colours.to_rgb[i % colours.to_rgb.count]
      target_colour = Color::RGB.new(rgb[0], rgb[1], rgb[2])
      puts "Transitioning #{light.name} to #{rgb}"
      light.set_state(colour_to_hue(target_colour), transition: 5)
    end
  end
  sleep 26
end
