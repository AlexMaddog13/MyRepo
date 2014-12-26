# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require 'gosu'

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
            @icon.draw(@x ,@y, 1)
      end

    end
   
end


class StarShip
  attr_reader :score
  attr_reader :x
  attr_reader :y
  attr_reader :angle
  attr_reader :x_local
  attr_reader :y_local
  attr_reader :vel_x
  attr_reader :vel_y
  def initialize(window)
    @window = window
    @image = Gosu::Image.new(@window, 'Starfighter.png', false)
    @beep = Gosu::Sample.new(@window, 'beep.wav')
    @x = @y = @vel_x = @vel_y = @angle = 0.0
    @x_local = @y_local =0
    @score = 0
    @startshooting = Gosu::milliseconds;
    @delay = 100;
    @Beams = Array.new
  end

  def warp(x, y)
    @x, @y = x, y
  end

  def turn_left
    if angle.abs == 360 then
      @angle = 0
    end
    @angle -= 4.5
  end

  def turn_right
    if angle.abs == 360 then
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
    @x %= @window.RES_X
    @y %= @window.RES_Y

    @vel_x *= 0.95
    @vel_y *= 0.95
    
    #puts "player x: #{@x} y:#{@y}"
    @x_local, @y_local = (@x * @window.map.f_x)%@window.width , (@y*@window.map.f_y)%@window.height 
  end

  def draw
    @image.draw_rot((@x+@window.map.x)*@window.map.f_x, (@y+ @window.map.y)*@window.map.f_y  , 1, @angle,0.5,0.5,@window.map.f_x,@window.map.f_y)
    @Beams.each{|laser| laser.draw}
  end
 
  
  def score
    @score
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