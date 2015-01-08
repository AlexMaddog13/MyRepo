# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
require 'gosu'
class DrawObject
  attr_reader :order, :x, :y
  def initialize(window, image, scaleble = false, parent = nil, imgbasescale=1)
    @window = window
    @scaleble = scaleble
    @image ||= Gosu::Image.new(window, image,false)
    @x = @y = 0;
    @parent = parent;
    @order = parent.nil? ? 0:parent.order + 1;
    @imgbasescale= imgbasescale
    @angle = 0.0;
    @newangle = nil;
    @angle_step = 1.5;
    @znak = -1;

  end
  
  
  def move
    
    @x = @window.mouse_x
    @y = @window.mouse_y
   
    self.draw
  end

  def warp(x,y)
    @x = x
    @y = y
   
    self.draw
  end
  
  def moveto(x,y)
    @newangle = (-180*Math.atan2(@x-x,@y-y)/Math::PI)
    diffangle =  @angle - @newangle 
    @znak = ((diffangle/diffangle.abs).nan? ? 1 : (diffangle/diffangle.abs)) 
    @dir_x, @dir_y = x,y
    @znak = @znak*-1 if diffangle.abs > 360 - diffangle.abs 
    
  end
  
  def draw
   if @scaleble
      @window.scale(@window.scaleVal){
      @image.draw(@x,@y,@order,@imgbasescale,@imgbasescale)}
   else
      @image.draw(@x,@y,@order,@imgbasescale,@imgbasescale)
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
    @vel_x = @vel_y =  0.0
    @score = 0
    @startshooting = Gosu::milliseconds;
    @delay = 100;
    @Beams = Array.new
  end

  def turn_left
    if @angle.abs == 180 then
      @angle = 180
    end
    @angle -= @angle_step
  end

  def turn_right
    if @angle.abs == 180 then
      @angle = -180
    end
    @angle += @angle_step
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
    
  end

  def draw
    if !@newangle.nil? 
       if ((@angle - @newangle).abs).floor != 0 
        if @znak > 0
        self.turn_left
        else
          self.turn_right
        end
    else
      @newangle = nil
    end
    end
 
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
    if @window.curButtonId == (Gosu::MsLeft)
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