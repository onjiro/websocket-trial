class StarrubyView
  attr_accessor :screen
  attr_accessor :graphics
  def initialize
    @graphics = {}
    @models = []
  end

  def add(model)
    @models << model
  end
  
  def draw
    @screen.clear 
    @models.each do |one|
      # TODO 画面スクロール、拡大縮小可能な構造に変更
      graphic = @graphics[one.state.graphic]
      x = one.x
      y = one.y
      @screen.render_texture(graphic, x, y)
    end
  end
end

