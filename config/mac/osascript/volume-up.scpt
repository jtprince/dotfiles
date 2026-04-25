set v to output volume of (get volume settings)
if v < 100 then
  set volume output volume (v + 10)
end if
