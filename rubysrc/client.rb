require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'json' 
require "modes"


EventMachine.run {
  mode = nil
  http = EventMachine::HttpRequest.new("ws://localhost:3002").get :timeout => 0
  http.errback { puts "oops" }
  http.callback {
    puts "WebSocket connected!"
  }
 
  http.stream { |msg|
    # puts "Recieved: #{msg}"
    msg = JSON.parse(msg)
    if mode.nil?
      role, id = msg["role"], msg["id"]
      puts "role = #{role}, id = #{'id'}"
      mode = (role == "HOST") ? HostMode.new: GuestMode.new
      mode.connection = http
      
      # ゲームループのスレッドとそれを監視するスレッド
      t = Thread.new { mode.run }
      Thread.new { loop {exit if t.status == false; sleep 1} }
    else
      mode.listen(msg)
    end
  }
  # TODO コネクション切断された場合の動作
}
 
