# Eurovision Hue controller

Scrapes the live blog, updates your Hue light colours according to the country
most recently mentioned in that live blog.

This now has a .ruby-version file, so if you've [got RVM installed](https://rvm.io/rvm/install
it'll automatically pick a Ruby that this is tested with.

Install dependencies with [Bundler](https://bundler.io)

    bundle

If you have issues installing Nokogiri at this point, follow the instructions
at http://www.nokogiri.org/tutorials/installing_nokogiri.html#mac_os_x
and try again.

You will also need to install ImageMagick: https://www.imagemagick.org/script/binary-releases.php.
(If you get Terrapin::CommandNotFoundError, ths is probably why).

If you haven't yet, you'll need to register with the Hue bridge (only first time):

    bundle exec lights discover -s
    bundle exec lights register

Alternatively, if the first fails to discover your bridge, and you know the IP
address, `bundle exec lights config -i <IP ADDRESS>`.

Now start the script:

    bundle exec ruby eurovisionhue.rb

## Docker

This can be built/run using docker and the included Dockerfile.

Build with:

    docker build -t eurovisionhue .

Run initial config:

    echo "{}" > ~/.lightsconfig
    docker run --rm -it -v ~/.lightsconfig:/app/.lightsconfig eurovisionhue bundle exec lights discover -s
    docker run --rm -it -v ~/.lightsconfig:/app/.lightsconfig eurovisionhue bundle exec lights register

Run with:

    docker run --rm -it -v ~/.lightsconfig:/app/.lightsconfig eurovisionhue

## Last.FM mode

*deprecated, this needs rework*

This also supports polling Last.fm and using your most recent track's album
art as the colours to use. You need to have a last.fm API key:

    LASTFM_USER=lastfm-user LASTFM_API_KEY=012344556 bundle exec ruby lastfmhue.rb
