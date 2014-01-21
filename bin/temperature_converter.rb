#!/usr/bin/env ruby

class Temperature
  def initialize(num=-273.15, units=:celsius)
    from(num, units)
  end

  def from(num, units=:celsius)
    @celsius = 
      case units
      when :celsius
        num
      when :kelvin
        num - 273.15
      when :fahrenheit
        (num - 32) * (5.0/9)
      when :newton
        num * (100.0/33)
      when :rankine
        (num - 491.67) * (5.0/9)
      when :romer, :rømer
        (num-7.5) * 40.0/21
      when :delisle
        100 - (num * (2.0/3))
      when :reaumur, :réaumur
        num * (5.0/4)
      end
  end

  def to(units=:celsius)
    case units
    when :celsius
      @celsius
    when :kelvin
      @celsius + 273.15 
    when :fahrenheit
      (@celsius * (9.0/5)) + 32
    when :newton
      @celsius * (33.0/100)
    when :rankine
      (@celsius + 274.15) * (9.0/5) 
    when :romer, :rømer
      @celsius*(21.0/40) + 7.5
    when :delisle
      (100 - @celsius) * (3.0/2)
    when :reaumur, :réaumur
      @celsius * (4.0/5)
    end
  end

  def to_s
    "#{@celsius} ℃"
  end

end

if __FILE__ == $0
end
