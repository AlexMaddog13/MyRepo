# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.
=begin
puts "Hello World"
3.times {print "Ruby"}
1.upto(9) { |x| print x  }
a = [3,  2 , 1]
a[3] = a[2] - 1
a.each do |elt|
  print elt+1
end

a = [1,2,3,4]
b = a.map { |x| x*x}
c = a.select { |x| x%2==0}

a.inject do |sum,x|
  sum +x
end

h = {
  :one => 1,
  :two => 2
}

h [:one]
h[:three] = 3;
h.each do |key,value|  
  print "#{value}:#{key}:"
end

def square(x) 
   x*x
end

x = 1
x += 1
x, y = 1, 2
a, b = b, a
x,y,z = [1,2,3]

def polar(x,y)
  theta = Math.atan2(x,y)
  r = Math.hypot(x, y)
  [r, theta]
end

distance, angle = polar(2,2)
puts "-----------------"
puts distance
puts angle

def are_you_sure?
  print "are you sure?"
  responce =gets
  case responce
  when /^[yY]/
    return true
  when /^[nN]/, /^$/
    retunr false
  end
end

class Sequence
  include Enumerable
  
  def initialize(from, to, by)
    @from, @to, @by = from, to, by
  end
  
  def each
    x =@from
    while x<= @to
      yield x
      x += @by
    end
  end
  
  def length
    return 0 if @from > @to
    Integer((@to-@from)/@by) + 1
  end
  
  alias size length
  
  def[](index)
    return nil if index < 0 
    v = @from + index*@by
    if v <= @to
      v
    else
      nil
    end
  end
  
  def *(factor)
    Sequence.new(@from*factor, @to*factor, @by*factor)
  end
  
  def +(offset)
    Sequence.new(@from+offset, @to+offset, @by+offset)
  end
  
end

s = Sequence.new(1, 10, 2)
s.each { |x| puts x  }
puts s[s.size-1]
t = (s+1)*2

module Sequences
  def self.fromtoby(from,to,by)
    x = from
    while x<= to
      yield x
      x+=by
    end
  end
end

Sequences.fromtoby(1, 10, 2) {|x| print x}

class Range
  def by(step)
    x = self.begin
    if exclude_end?
      while x <self.end
        yield x
        x+=step
      end
    else
      while x<=self.end
        yield x
        x+=step
      end
    end
  end
end

#(0..10).by(2) {|x|print x}
#(0...10).by(2) {|x|print x}

puts '214214\\'
puts '4124124\\\''
puts '124124\\\\'
puts sprintf("znaxchenie pi primerno ravno %.4f", Math::PI)
puts "piprimerno ravno %.4f" % Math::PI
puts "%s : %f" % ["pi", Math::PI]
puts %x[ls]
10.times {puts "test".object_id}
greeting = "Hello"
greeting  << " " << "World"
puts greeting 
count = Array.new(3) {|i| i + 1} #[1,2,3]

count.each { |item| puts item  }
=end

a = [[7,8,1,4,9],[3,6,7],[1,2,3]]

puts a.sort_by { |x| x[-1]  }

"asfa".to_f