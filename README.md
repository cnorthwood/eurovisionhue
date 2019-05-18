# Eurovision Hue controller

Scrapes the live blog, updates your Hue light colours according to the country
most recently mentioned in that live blog.

Requires a modern Ruby. Install RVM: https://rvm.io/rvm/install and then
`rvm use 2.3.1` or something.

Install dependencies with [Bundler](https://bundler.io)

    bundle

If you have issues installing Nokogiri at this point, follow the instructions
at http://www.nokogiri.org/tutorials/installing_nokogiri.html#mac_os_x
and try again.

You will also need to install ImageMagick: https://www.imagemagick.org/script/binary-releases.php.

Now you need to register your Mac with you Hue. Press the button on the
bridge, then:

    bundle exec ruby eurovisionhue.rb

You only need to do that the first time you run it.

Optionally, use Docker:-

```bash
docker build -t eurovision .
```

```bash
docker run -it eurovision
```

## Last.FM mode

This also supports polling Last.fm and using your most recent track's album
art as the colours to use. You need to have a last.fm API key:

    LASTFM_USER=lastfm-user LASTFM_API_KEY=012344556 bundle exec ruby lastfmhue.rb
