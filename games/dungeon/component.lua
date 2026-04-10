
local Component = {}
Component.__index = Component

function Component:new(screen, id, o)
  o = o or {}
  setmetatable(o, self)
  o.screen = screen
  o.id = id
  return o
end

function Component:create()
end

function Component:on_input(event)
end

function Component:enable(bool)
end

function Component:delete()
end

return Component
