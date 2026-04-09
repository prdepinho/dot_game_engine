
local Component = {}

function Component:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Component:create(id, layer, position, dimensions, on_click)
  self.highlighted = false
  self.id = id
  self.on_click = on_click
  create_segmented_panel({
      id = self.id,
      gui = true,
      layer = layer,
      position = position,
      dimensions = dimensions,
      texture = {
        texture = "gui",
        position = { x = 224, y = 0 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
      on_input = function(event) 
        return false
      end
    })
end

function Component:on_entered()
  set_segmented_panel_texture({
    id = self.id,
    texture = {
      texture = "gui",
      position = { x = 224, y = 16 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
  })
end

function Component:on_exited()
  set_segmented_panel_texture({
    id = self.id,
    texture = {
      texture = "gui",
      position = { x = 224, y = 0 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
  })
end

function Component:delete()
  remove_entity(self.id)
end

return Component
