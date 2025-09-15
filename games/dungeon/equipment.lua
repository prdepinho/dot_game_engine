
local Equipment = {}

function Equipment:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Equipment:create()
end

return Equipment
