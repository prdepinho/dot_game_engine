

local Screen = {}
Screen.__index = Screen

function Screen:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function Screen:open()
  self.components = {}
  self.focus = nil
end

function Screen:add_component(component)
  self.components[component.id] = component
end

function Screen:loop(delta)
end

function Screen:on_input(event)
end

function Screen:close()
  for _,component in ipairs(self.components) do
    component:delete()
  end
end


return Screen

