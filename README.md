# Note

# This app is incomplete (a work in progress)

This is a static website which uses [genrb](http://github.com/maxpleaner/genrb), a build system I've made for compiling coffeescript, sass, and slim.

The source code is in `source/`. Running `ruby gen.rb` will compile the site into `dist/`. For local development, `guard` can be used with the livereload chrome extension to automatically build when source files change.

The purpose of this site is [music sampling](https://en.wikipedia.org/wiki/Sampling_(music)). It uses [RecordRTC](https://github.com/muaz-khan/RecordRTC) to do client side recordings.

Audio samples are persisted using a separate app, [media-backend](http://github.com/maxpleaner/media-backend), build with Sinatra.

----

How to use:

1. clone
2. `cp .env.example .env` (and customize .env)
  - the `MEDIA_BACKEND_TOKEN` env var should match that of the media-backend server. 
3. `bundle`.
4. open the static site at `/dist/index.html`

