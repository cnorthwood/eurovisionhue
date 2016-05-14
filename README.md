Eurovision Hue controller
=========================

Scrapes the live blog, updates your Hue light colours according to the country
most recently mentioned in that live blog.

You might want to change the URL. Will probably work on most Macs.

Install dependencies: `bundle`

    bundle
    
Now you need to register your Mac with you Hue. Press the button on the bridge, then:

    bundle exec irb
    require 'huey'
    Huey::Request.register
    exit


    
    ruby eurovisionhue.rb
