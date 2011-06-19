require 'rubygems'
require 'eventmachine'
require 'em-http-request'
require 'json' 
require "starruby"
require "starruby_view"
require "collision_checker"

class HostMode
  include StarRuby
  
  attr_writer :connection
  def initialize
    @messages = []
    @models = []
    @controlers = []
    @view = StarrubyView.new
    @collision_checker = CollisionChecker.new
  end

  def listen(message)
    @messages << message
  end

  def run
    Game.run(320, 240, :title => "host mode", :fps => 60) do |game|
      @view.screen = game.screen if @view.screen.nil?

      # 現在のモデルの状態を送信する
      @connection.send(@models.to_json)

      # 行動の入力を受け付ける
      @controlers.each {|one| one.entry }

      # モデルの動作を実行、衝突判定、描画
      @models.each do |one| 
        @collision_checker.add one
        @view.add one
        one.action.next
      end
      @collision_checker.check
      @view.draw

      # サーバーから受け取ったメッセージをフラッシュ
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
 
