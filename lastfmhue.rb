require 'color'
require 'hue'
require 'miro'
require 'nokogiri'
require 'open-uri'

url = "http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=laser-kun&limit=1&api_key=#{ENV['LASTFM_API_KEY']}"

hue = Hue::Client.new

def colour_to_hue(colour)
  r = colour.r
  g = colour.g
  b = colour.b
  max = [r, g, b].max
  min = [r, g, b].min
  delta = max - min
  v = max * 100

  if max != 0.0
    s = delta / max * 100
  else
    s = 0.0
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

    if h < 0
      h += 360.0
    end
  end

  {
    hue: (h * 182.04).round,
    saturation: (s / 100.0 * 255.0).round,
    bri: (v / 100.0 * 255.0).round
  }
end

current_album_art = nil

while true do
  doc = Nokogiri::XML(open(url))
  new_album_art = doc.xpath("//image[@size='large']").first.text
  if new_album_art != current_album_art
    unless new_album_art.empty?
      current_album_art = new_album_art
      puts "Transitioning lights to art for #{doc.xpath("//track/name").first.text} [#{new_album_art}]"
      begin
        file = Tempfile.new 'lastfmhue'
        file.write open(new_album_art).read
        file.close
        colours = Miro::DominantColors.new(file.path)
        hue.lights.each_with_index do |light, i|
          light.on!
          rgb = colours.to_rgb[i]
          target_colour = Color::RGB.new(rgb[0], rgb[1], rgb[2])
          puts "Transitioning #{light.name} to #{rgb}"
          light.set_state(colour_to_hue(target_colour), transition: 5)
        end
      ensure
        file.close
        file.unlink
      end
    end
  end
  sleep 18
end
