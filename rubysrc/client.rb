require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'json' 

class Mode
  def listen(message)
    puts message
  end

  def run
  end
end

EventMachine.run {
  mode = nil
  http = EventMachine::HttpRequest.new("ws://localhost:3002").get :timeout => 0
  http.errback { puts "oops" }
  http.callback {
    puts "WebSocket connected!"
  }
 
  http.stream { |msg|
    puts "Recieved: #{msg}"
    if mode.nil?
      role = JSON.parse(msg)
      puts "role = #{role['role']}, id = #{role['id']}"
      mode = Mode.new
    else
      mode.listen(JSON.parse(msg))
    end
  }
  # TODO コネクション切断された場合の動作
}
 
