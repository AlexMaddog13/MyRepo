require 'gosu'
require_relative 'states/star_ship' 

class WorldMap < DrawObject
  attr_reader :x,:y
  def initialize(window, multiplier)
    @image = []
   (multiplier ** 2).times {@image << Gosu::Image.new(window, 'Space.jpg',false)}
   super(window,'Space.jpg')
   @multiplier = multiplier
 end

  
  def update()
 
    #if @window.button_down?(Gosu::MsLeft) 
     # if !@drag 
      #  @drag = [@window.mouse_x, @window.mouse_y]
        #puts "mouse x #{@window.mouse_x}, mouse y #{@window.mouse_y}"
       # @origin = [@x, @y]
      #else
       # @prev_x,  @prev_y = @x , @y
       # @x  = @origin[0] - (@window.mouse_x - @drag[0]) 
       # @y  = @origin[1] - (@window.mouse_y - @drag[1])
       
        #puts "x #{@x.abs > @height*2}, y #{@y.abs > @width*2}"
        #puts "x #{@x}, y #{@y}"
        #puts "mx #{@window.mouse_x}, my #{@window.mouse_y}"
         #puts "height x #{@height*-2}, width y #{@width*-2}"
        #@y = @height*-2 if @y.abs > @height*2
        #@x = @width*-2 if @x.abs > @width*2
         #puts "mouse x #{@window.x}, mouse y #{@window.y}"
   #   end
    #else 
     # @drag = @origin = nil 
    #end
  end
  def draw
    curx, cury = @x,@y
    @image.each_with_index do |item, i|
    @window.scale(@window.scaleVal){item.draw(curx,cury,@order)}
    curx += (@window.width)/(@multiplier)
    if curx == (@window.width) 

      curx = 0;
      cury += (@window.height)/(@multiplier)
    end
    end
  end
  
end
class GameWindow < Gosu::Window
  attr_accessor :stars, :RES_X, :RES_Y, :scaleVal, :curButtonId
  def initialize
    mult = 1
    @RES_X = 4096*mult
    @RES_Y = 2048*mult
    super(@RES_X, @RES_Y, false)
    self.caption = "Star Fighter"
    @map = WorldMap.new(self,mult)
    @player = StarShip.new(self,@map)
    @cursor = Cursor.new(self,"cursor.png",false,@player,5)
    @scaleVal =  1;
    @player.warp(500, 500)
    @star_anim = Gosu::Image::load_tiles(self, 'exp.png', 128, 128, false)
    @stars = Array.new
    @font = Gosu::Font.new(self, Gosu::default_font_name, 200)
    
    @zoom_center_x,@zoom_center_y = 0,0
  end
  def button_up(id)
    @curButtonId = id
  end
  def update
    if self.button_down? Gosu::KbNumpadAdd  then
      
      if @scaleVal <=1.5 
      @scaleVal += 0.01
      end

      #@zoom_center_x, @zoom_center_y =  @player.x,@player.y
    end    
    if self.button_down? Gosu::KbNumpadSubtract  then
      if self.width/@scaleVal <= @RES_X  && self.height/@scaleVal <= @RES_Y 
        @scaleVal -= 0.01
      end
      #@zoom_center_x, @zoom_center_y =  @player.x, @player.y
    end
    @player.update
    @map.update
    if rand(100) < 4 and @stars.size < 25 then
      @stars.push(Star.new(@star_anim, self))
    end
    
    @curButtonId = nil
  end

  def draw
    #puts "drawing"
    @player.draw
    @map.draw
    @cursor.move
    #@stars.each { |star| star.draw }
    #@font.draw("Счет: #{@player.score}", 50, 50, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close
    end
  end
end

module ZOrder
  Background, Stars, Player, UI = *0..3
end

class Star < DrawObject
  attr_reader :x, :y

  def initialize(animation, window)
    @animation = animation
    @window = window
    #@color = Gosu::Color.new(0xff000000)
    #@color.red = rand(256 - 40) + 40
    #@color.green = rand(256 - 40) + 40
    #@color.blue = rand(256 - 40) + 40
    @x = rand * @window.RES_X
    @y = rand * @window.RES_Y
  end

  def draw  
    img = @animation[Gosu::milliseconds / 100 % @animation.size];
    img.draw((@x+@window.map.x - img.width / 1.0)*@window.scaleXY, (@y+@window.map.y - img.height / 1.0)*@window.scaleXY,
        ZOrder::Stars, @window.scaleXY, @window.scaleXY,  0xffffffff, :add)
  end
end


window = GameWindow.new
window.show
