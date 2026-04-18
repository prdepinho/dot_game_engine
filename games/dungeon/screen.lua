
local Input = require "games.dungeon.input"

local Screen = {}
Screen.__index = Screen

function Screen:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function Screen:open(layer)
  self.components = {}
  self.focus = nil
  self.layer = layer or 1
  self.running = true
end

function Screen:add_component(component)
  self.components[component.id] = component
end

function Screen:loop(delta)
end

function Screen:on_input(event)
end

function Screen:set_visibility(bool)
  for _,component in pairs(self.components) do
    component:set_visibility(bool)
  end
end

function Screen:remove_component(component)
  self.components[component.id]:delete()
  self.components[component.id] = nil
end

function Screen:delete()
  for _,component in pairs(self.components) do
    component:delete()
  end
end


return Screen

