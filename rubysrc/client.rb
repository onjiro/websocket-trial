require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'json' 
require "starruby"

class HostMode
  include StarRuby
  
  attr_writer :connection
  def initialize
    @messages = []
  end

  def listen(message)
    @messages << message
  end

  def run
    font = Font.new("FreeSans", 12)
    white = Color.new(255, 255, 255)
    
    Game.run(320, 240, :title => "host mode", :fps => 60) do |game|
      game.screen.clear
      @messages.inject(8) do |y, one|
        game.screen.render_text("#{one}", 8, y, font, white)
        y = y + 8
      end
      @messages = []
    end
  end
end

class GuestMode
  include StarRuby
  
  attr_writer :connection
  
  def listen(message)
    puts message
  end
  
  def run
    i = 0
    Game.run(320, 240, :title => "guest mode", :fps => 20) do |game|
      @connection.send({:key=>i}.to_json)
      i = i + 1
    end
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
 
