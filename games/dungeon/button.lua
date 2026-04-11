local Input = require "games.dungeon.input"

local Button = {}
Button.__index = Button
setmetatable(Button, { __index = Component })

function Button:new(screen, id, o)
  o = o or {}
  setmetatable(o, self)
  o.screen = screen
  o.id = id
  return o
end

function Button:create_with_label(label, layer, position, dimensions, on_click)
  self.child_id = self.id .. "_child"
  self.on_click = on_click
  self.enabled = true
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
      return self:on_input(event)
    end
  })

  create_text_line({
    id = self.child_id,
    gui = true,
    layer = layer + 1,
    position = { x = 0, y = 0 },
    text = label,
    font = "small_font",
    color = { r = 255, g = 255, b = 255, a = 255 },
  })

  local button_entity = get_entity(self.id)
  local child_entity = get_entity(self.child_id)
  local label_x = button_entity.position.x + (button_entity.dimensions.width / 2) - (child_entity.dimensions.width / 2)
  local label_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (child_entity.dimensions.height / 2)
  set_position(self.child_id, label_x, label_y)

end

function Button:create_with_icon(texture, layer, position, dimensions, on_click)
  self.child_id = self.id .. "_child"
  self.on_click = on_click
  self.enabled = true
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
      return self:on_input(event)
    end
  })

  create_panel({
      id = self.child_id,
      gui = true,
      layer = layer + 1,
      position = { x = 0, y = 0 },
      dimensions = texture.dimensions,
      texture = texture
  })

  local button_entity = get_entity(self.id)
  local child_entity = get_entity(self.child_id)
  local label_x = button_entity.position.x + (button_entity.dimensions.width / 2) - (child_entity.dimensions.width / 2)
  local label_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (child_entity.dimensions.height / 2)
  set_position(self.child_id, label_x, label_y)

end

function Button:on_input(event)
    if event.type == 'mouse_button_down' then
      if self.enabled == true then
        if event.button == 0 then
          set_segmented_panel_texture({
            id = self.id,
            texture = {
              texture = "gui",
              position = { x = 224, y = 32 },
              border_size = 4,
              interior = { width = 8, height = 8 },
            },
          })
          local button_entity = get_entity(self.id)
          local child_entity = get_entity(self.child_id)
          local label_x = button_entity.position.x + (button_entity.dimensions.width / 2) - (child_entity.dimensions.width / 2)
          local label_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (child_entity.dimensions.height / 2)
          set_position(self.child_id, label_x, label_y + 1)
        end
      end
      return true

    elseif event.type == "mouse_button_up" then
      if self.enabled == true then
        if event.button == 0 then
          set_segmented_panel_texture({
            id = self.id,
            texture = {
              texture = "gui",
              position = { x = 224, y = 16 },
              border_size = 4,
              interior = { width = 8, height = 8 },
            },
          })
          local button_entity = get_entity(self.id)
          local child_entity = get_entity(self.child_id)
          local label_x = button_entity.position.x + (button_entity.dimensions.width / 2) - (child_entity.dimensions.width / 2)
          local label_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (child_entity.dimensions.height / 2)
          set_position(self.child_id, label_x, label_y)
          self.on_click()
        end
      end
      return true

    elseif event.type == "mouse_cursor_enter" then
      if self.enabled == true then
        set_segmented_panel_texture({
          id = self.id,
          texture = {
            texture = "gui",
            position = { x = 224, y = 16 },
            border_size = 4,
            interior = { width = 8, height = 8 },
          },
        })
        return true
      end

    elseif event.type == "mouse_cursor_exit" then
      if self.enabled == true then
        set_segmented_panel_texture({
          id = self.id,
          texture = {
            texture = "gui",
            position = { x = 224, y = 0 },
            border_size = 4,
            interior = { width = 8, height = 8 },
          },
        })
        local button_entity = get_entity(self.id)
        local child_entity = get_entity(self.child_id)
        local label_x = button_entity.position.x + (button_entity.dimensions.width / 2) - (child_entity.dimensions.width / 2)
        local label_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (child_entity.dimensions.height / 2)
        set_position(self.child_id, label_x, label_y)
        return true
      end
    end
    return false
end

function Button:enable(bool)
  self.enabled = bool
  if self.enabled == false then
    set_segmented_panel_texture({
      id = self.id,
      texture = {
        texture = "gui",
        position = { x = 224, y = 48 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
    })
  else
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
end

function Button:delete()
  remove_entity(self.id)
  remove_entity(self.child_id)
end

return Button

