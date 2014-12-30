# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require 'gosu'

class DrawObject
  attr_reader :order
  def initialize(window, image, scaleble = false, parent = nil)
    @window = window
    @scaleble = scaleble
    @image ||= Gosu::Image.new(window, image,false)
    @x = @y = 0;
    @parent = parent;
    @order = parent.nil? ? 0:parent.order + 1;
  end
  
  
  def move
    @x = @window.mouse_x
    @y = @window.mouse_y
    self.draw
  end

  def moveto(x,y)
    @x = x/@window.scaleVal
    @y = y/@window.scaleVal
    self.draw
  end
  
  def draw
   if @scaleble
      @window.scale(@window.scaleVal){
      @image.draw(@x,@y,@order)}
   else
      @image.draw(@x,@y,@order)
   end
  end
  
end
class Cursor  < DrawObject

end
class Laser
    def initialize(player, window, pos_offset_x, pos_offset_y)
        @player = player
        @window = window
        @shooting = false
        @x = @player.x + Gosu::offset_x(@player.angle + pos_offset_x, 100) 
        @y = @player.y + Gosu::offset_y(@player.angle + pos_offset_y, 100) 
        @distance = 0
        @icon = Gosu::Image.new(@window, "123.png", false,50,50,50,50)
    end
   
    def shoot
        @startangle = @player.angle
        @shooting = true 
    end
    
    def shootable?
      return  @shooting 
    end
   
    def update
      if @shooting

           if @distance >= 3000
             @shooting = false
           end
           decriser = 0.25
           @xacseleretor =  Gosu::offset_x(@startangle, 100) * decriser
           @yacseleretor = Gosu::offset_y(@startangle, 100)  * decriser
           @x += @xacseleretor; 
           @y += @yacseleretor;
           @distance += (@xacseleretor.abs+@yacseleretor.abs)
           @x %= @window.RES_X
           @y %= @window.RES_Y
      end
    end
   
    def draw
      if @shooting
            @icon.draw(@x ,@y, 0)
      end

    end
   
end


class StarShip < DrawObject
  attr_reader :score, :x, :y
  def initialize(window,map)
    super(window,'Starfighter.png',true,map)
    @beep = Gosu::Sample.new(@window, 'beep.wav')
    @vel_x = @vel_y = @angle = 0.0
    @score = 0
    @startshooting = Gosu::milliseconds;
    @delay = 100;
    @Beams = Array.new
  end

  def warp(x, y)
    self.moveto(x,y)
  end

  def turn_left
    if @angle.abs == 360 then
      @angle = 0
    end
    @angle -= 4.5
  end

  def turn_right
    if @angle.abs == 360 then
      @angle = 0
    end
    @angle += 4.5
  end

  def accelerate
    @vel_x += Gosu::offset_x(@angle, 0.5)
    @vel_y += Gosu::offset_y(@angle, 0.5)
  end

  def move
    @x += @vel_x
    @y += @vel_y
    @x %= @window.width
    @y %= @window.height

    @vel_x *= 0.95
    @vel_y *= 0.95
    
    #puts "player x: #{@x} y:#{@y}"
    #@x_local, @y_local = (@x * @window.map.scale)%@window.width , (@y*@window.map.scale)%@window.height 
  end

  def draw
    @window.scale(@window.scaleVal){ @image.draw_rot(@x, @y, @order, @angle,0.5,0.5)}
    #puts (@x*@window.map.scale)
    #@Beams.each{|laser| laser.draw}
  end
 
  
  def score
    @scores
  end
  
 def update
    if @window.button_down? Gosu::KbLeft or @window.button_down? Gosu::GpLeft then
      self.turn_left
    end
    if @window.button_down? Gosu::KbRight or @window.button_down? Gosu::GpRight then
      self.turn_right
    end
    if @window.button_down? Gosu::KbUp or @window.button_down? Gosu::GpButton0 then
      self.accelerate
    end
    if @window.button_down?(Gosu::MsLeft)
      self.moveto(@window.mouse_x,@window.mouse_y)
    end
    
    if @window.button_down? Gosu::KbSpace
      if  @Beams.size < 2 
        @laser1 = Laser.new(self,@window,30,30)
        @laser2 = Laser.new(self,@window,-30,-30)
        @laser1.shoot
        @laser2.shoot
        @Beams << @laser1
        @Beams << @laser2
      end
    end
   
    self.move

    self.collect_stars(@window.stars)
    @Beams.each{|laser| @Beams.delete(laser) if !laser.shootable? }
    @Beams.each{|laser| laser.update}
     #puts @Beams.size
  end
 
   def collect_stars(stars)
    stars.reject! do |star|
      if Gosu::distance(@x, @y, star.x, star.y) < 130 then
        @score += 10
        @beep.play
        true
      else
        false
      end
    end
  end
end