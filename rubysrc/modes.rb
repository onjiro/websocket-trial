require 'rubygems'
require 'json' 
require "starruby"
require "starruby_view"
require "collision_checker"
require "jsonsupport"

class ModelState
  attr_accessor :graphic
  def next
    # TODO
  end
end

class Model
  include JsonSupport
  attr_accessor :x, :y, :state
  def next
    @state.next
  end
end

class HostMode
  include StarRuby
  
  attr_writer :connection
  def initialize
    full = Texture.load("img/ラリアット.png")
    graphic = Texture.new(128, 160)
    graphic.render_texture(full, 0, 0, {:src_x => 0, :src_y => 0, :src_width => 128, :src_height => 160})
    @messages = []
    player = Model.new
    player.x, player.y = 64, 24
    player.state = ModelState.new
    player.state.graphic = :graphic
    @models = [player]
    @controlers = []
    @view = StarrubyView.new
    @view.graphics[:graphic] = graphic
    @collision_checker = CollisionChecker.new
  end

  def listen(message)
    @messages << message
  end

  def run
    Game.run(320, 240, :title => "host mode", :fps => 60) do |game|
      @view.screen = game.screen if @view.screen.nil?

      # 現在のモデルの状態を送信する
      @connection.send(@models.to_json) unless @connection.nil?

      # 行動の入力を受け付ける
      @controlers.each {|one| one.entry }

      # モデルの動作を実行、衝突判定、描画
      @models.each do |one|
        @collision_checker.add one
        @view.add one
        one.next
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

