

local Screen = {}

function Screen:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Screen:open()
end

function Screen:loop(delta)
end

function Screen:on_input(event)
end

function Screen:close()
end


return Screen

