require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'json' 

class HostMode
  attr_writer :connection
  def listen(message)
    puts message
  end

  def run
    puts "host mode"
  end
end

class GuestMode
  attr_writer :connection
  def listen(message)
    puts message
  end
  
  def run
    puts "guest mode"
    loop {@connection.send({:key=>9}.to_json)}
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
    msg = JSON.parse(msg)
    if mode.nil?
      role, id = msg["role"], msg["id"]
      puts "role = #{role}, id = #{'id'}"
      mode = (role == "HOST") ? HostMode.new: GuestMode.new
      mode.connection = http
      t = Thread.new { mode.run }
    else
      mode.listen(msg)
    end
  }
  # TODO コネクション切断された場合の動作
}
 
