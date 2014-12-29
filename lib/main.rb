require 'gosu'
require_relative 'states/star_ship' 

class WorldMap < DrawObject
  attr_reader :scale, :x,:y
  def initialize(w,h, window)
    super(window,'Space.jpg')
   @window = window
  #@background_image =  Gosu::Image.new(@window,'Space.jpg',false)
   @f_x = @f_y = 1.0
   @scale =  1.0
  end

  
  def update(player)
    @player = player
    #@x = @player.x_local
    #@y = @player.y_local
    if @window.button_down? Gosu::KbNumpadAdd  then
      #puts (@window.RES_X * @f_x )
      #puts @width
     #if @window.RES_X * @scale  < @width*4 &&  @window.RES_Y * @scale < @height*3 
       @scale += 0.01
        #@x -=15 
        #@y -=15 
      #end
      
    end
    
    if @window.button_down? Gosu::KbNumpadSubtract  then
      #if @window.RES_X * @scale > @width &&  @window.RES_Y * @scale > @height
        @scale -= 0.01
      #end
    end

    if @window.button_down?(Gosu::MsLeft) 
      if !@drag 
        @drag = [@window.mouse_x, @window.mouse_y]
        #puts "mouse x #{@window.mouse_x}, mouse y #{@window.mouse_y}"
        @origin = [@x, @y]
      else
        @prev_x,  @prev_y = @x , @y
        @x  = @origin[0] - (@window.mouse_x - @drag[0]) #translate according to mouse movement
        @y  = @origin[1] - (@window.mouse_y - @drag[1])
       
        #puts "x #{@x.abs > @height*2}, y #{@y.abs > @width*2}"
        #puts "x #{@x}, y #{@y}"
        #puts "mx #{@window.mouse_x}, my #{@window.mouse_y}"
         #puts "height x #{@height*-2}, width y #{@width*-2}"
        #@y = @height*-2 if @y.abs > @height*2
        #@x = @width*-2 if @x.abs > @width*2
         #puts "mouse x #{@window.x}, mouse y #{@window.y}"
      end
    else #button is released
      @drag = @origin = nil #clear variables, so you can re-use them
    end
    
  end
  #def draw
    #puts "diff x #{@x - @height}, diff y #{@y -  @width}"
    #puts "height x #{@height}, width y #{@width}"
    #self.borders

    #puts "px #{@player.x*@f_x}, py #{@player.y*@f_y}"
    #puts "mx #{@scale}"
    #puts "cx #{(@x+@player.x)*@f_x}, my #{(@x+@player.x)*@f_x}"
  #  @background_image.draw(@x*@scale,@x*@scale, 0,@scale,@scale);
  #end
  
end
class GameWindow < Gosu::Window
  attr_accessor :stars, :RES_X, :RES_Y, :map

  def initialize
    @RES_X = 5545
    @RES_Y = 2877
    super(5545/8, 2877/6, false)
    self.caption = "Star Fighter"
    @map = WorldMap.new(5545/8,2877/6, self)
    @cursor = Cursor.new(self,"cursor.png",99)
    @scaleXY = 0;
    @player = StarShip.new(self)
    @player.warp(0, 0)
    @star_anim = Gosu::Image::load_tiles(self, 'exp.png', 128, 128, false)
    @stars = Array.new
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 200)
  end
  
  def update
    @player.update
    #@cursor.update
    @map.update(@player)
    if rand(100) < 4 and @stars.size < 25 then
      @stars.push(Star.new(@star_anim, self))
    end
  end

  def draw
    @player.draw
    @map.draw
    @cursor.move
    @stars.each { |star| star.draw }
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

class Star
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
    img.draw((@x+@window.map.x - img.width / 1.0)*@window.map.scale, (@y+@window.map.y - img.height / 1.0)*@window.map.scale,
        ZOrder::Stars, @window.map.scale, @window.map.scale,  0xffffffff, :add)
  end
end

puts  "Строка/".chop if "Строка/".end_with?("/")
window = GameWindow.new
window.show
