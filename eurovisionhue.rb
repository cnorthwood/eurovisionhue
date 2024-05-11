require 'lights'
require 'json'
require 'miro'
require 'faraday'

class EurovisionHue
  def initialize
    @bulb_ids = hue.request_bulb_list.map { |b| b[0] }
  end

  def start!
    current_country = nil

    loop do
      new_country = nil
      get_liveblog_text.each do |entry|
        detected_country = find_country entry
        unless detected_country.nil?
          new_country = detected_country
          break
        end
      end
      puts "Detected change to #{new_country} on the live blog" if new_country != current_country
      if new_country != current_country and !new_country.nil?
        current_country = new_country
        bulbs_to_colours Miro::DominantColors.new("flags/#{new_country.sub(" ", "_")}.png")
                                      .to_rgb
                                      .reject { |rgb| rgb[0] + rgb[1] + rgb[2] == 0 } # Ignore black

      end
      sleep 19
    end
  end

  private

  def bulbs_to_colours(colours)
    @bulb_ids.each_with_index do |bulb_id, i|
      rgb = colours[i % colours.count]
      target_state = BulbState.new
      target_state.on = true
      target_state.transition_time = 5
      target_state.xy = rgb_to_xy(*rgb)
      puts "Transitioning #{bulb_id} to #{rgb}"
      @hue.set_bulb_state(bulb_id, target_state)
    end
  end

  def gamma_correction(c)
    c > 0.04045 ? ((c + 0.055) / (1.055)) ** 2.4 : c / 12.92
  end

  def rgb_to_xy(r, g, b)
    # https://gist.github.com/popcorn245/30afa0f98eea1c2fd34d
    # convert to 0-1 and apply gamma correction
    r = gamma_correction r / 255.0
    g = gamma_correction g / 255.0
    b = gamma_correction b / 255.0

    x = r * 0.649926 + g * 0.103455 + b * 0.197109
    y = r * 0.234327 + g * 0.743075 + b * 0.022598
    z = r * 0.0000000 + g * 0.053077 + b * 1.035763

    [x / (x+y+z), y / (x+y+z)]
  end

  def find_country(text)
    text.downcase!
    mentioned_countries = country_names.select { |country_name| text.include? country_name.downcase }
    mentioned_countries.min_by { |country_name| text.index(country_name.downcase) }
  end

  def country_names
    @country_names ||= Dir.entries('flags')
       .map { |filename| filename.split('.')[0] }
       .reject(&:nil?)
       .map { |filename| filename.sub("_", " ") }
  end

  def get_liveblog_text
    url = 'https://data.24liveplus.com/v1/retrieve_server/x/event/3577972495301732666/news/?inverted_order=1'
    http_get(url).body["data"]["news"].map { |entry| entry["contents"] }
  end

  def hue
    @hue ||= connect_to_hue!
  end

  def connect_to_hue!
    lights_config_path = "#{ENV["HOME"]}/.lightsconfig"
    unless File.exist? lights_config_path
      p "This script requires you to have configured lights first. Run"
      p "bundle exec lights discover -s"
      p "bundle exec lights register"
      p
      p "If the above does not work, and you know the IP address of your Hue bridge, then:"
      p "bundle exec lights config -i <IP ADDRESS>"
      p "bundle exec lights register"
      exit 1
    end

    config = JSON.parse(IO.read(lights_config_path))
    Lights.new config["bridge_ip"], config["username"]
  end

  def http_get(url)
    @http ||= Faraday.new do |conn|
      conn.options.timeout = 10
      conn.response :json
    end
    @http.get(url)
  end
end

eurovision_hue = EurovisionHue.new
eurovision_hue.start!
