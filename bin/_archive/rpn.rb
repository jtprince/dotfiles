#!/usr/bin/env ruby

def rpn(v)
  token = v.pop
  if token=~/^[-+*\/]$/
    y,x = rpn(v),rpn(v)
    x.send(token,y)
  else
    Float(token)
  end
end

while gets
  begin
    v = $_.split
    next if v.empty?
    x = rpn(v)
    raise unless v.empty?
    puts x
  rescue
    puts "error"
  end
end

