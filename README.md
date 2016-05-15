Eurovision Hue controller
=========================

Scrapes the live blog, updates your Hue light colours according to the country
most recently mentioned in that live blog.

Will probably work on most Macs.

Install dependencies with [Bundler](https://bundler.io)

    bundle
    
Now you need to register your Mac with you Hue. Press the button on the bridge, then:

    bundle exec ruby eurovisionhue.rb

You only need to do that the first time you run it.
