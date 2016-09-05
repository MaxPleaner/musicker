require 'webrick'
 WEBrick::HTTPServer.new(:Port => 8001, :DocumentRoot => (`pwd`.chomp + "/dist/")).start
