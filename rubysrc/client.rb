require 'rubygems'
require 'eventmachine'
require 'em-http-request'
 
EventMachine.run {
  http = EventMachine::HttpRequest.new("ws://localhost:3002").get :timeout => 0
 
  http.errback { puts "oops" }
  http.callback {
    puts "WebSocket connected!"
    http.send("Hello client")
  }
 
  http.stream { |msg|
    puts "Recieved: #{msg}"
    http.send "Pong: #{msg}"
  }
}
 
