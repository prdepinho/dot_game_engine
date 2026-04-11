local Input = require "games.dungeon.input"
local Component = require "games.dungeon.component"

local TextField = {}
TextField.__index = TextField
setmetatable(TextField, { __index = Component })

function TextField:new(screen, id, o)
  o = o or {}
  setmetatable(o, self)
  o.screen = screen
  o.id = id
  return o
end

function TextField:create(layer, position, length)
  self.text_id = self.id .. "_text"
  self.enabled = true
  self.text = ""
  create_segmented_panel({
    id = self.id,
    gui = true,
    layer = layer,
    position = position,
    dimensions = { width = length, height = 20 },
    texture = {
      texture = "gui",
      position = { x = 192, y = 16 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
    on_input = function(event) 
      return self:on_input(event)
    end
  })

  create_text_line({
    id = self.text_id,
    gui = true,
    layer = layer + 1,
    position = { x = 0, y = 0 },
    text = self.text,
    font = "small_font",
    color = { r = 0, g = 0, b = 0, a = 255 },
  })

  local button_entity = get_entity(self.id)
  local text_entity = get_entity(self.text_id)
  local text_x = button_entity.position.x + 4
  local text_y = button_entity.position.y + (button_entity.dimensions.height / 2) - (text_entity.dimensions.height / 2)
  set_position(self.text_id, text_x, text_y)
end

function TextField:focus(bool)
end

function TextField:on_input(event)
  if event.type == "focus_gained" then
    if self.enabled then
      set_text(self.text_id, self.text .. "|")
    end
    return true

  elseif event.type == "focus_lost" then
    if self.enabled then
      set_text(self.text_id, self.text)
    end
    return true

  elseif event.type == "mouse_button_down" then
    return true

  elseif event.type == 'text_entered' then
    if is_focused_entity(self.id) and self.enabled then
      if event.unicode == 0x08 then  -- backspace
        local last = utf8.offset(self.text, -1)
        self.text = string.sub(self.text, 1, last - 1)
        set_text(self.text_id, self.text .. "|")
        return true
      elseif event.unicode == 0x1B then  -- esc
        return true
      elseif event.unicode == 0x0D then  -- CR
        set_focused_entity(nil)
        return true
      else
        self.text = self.text .. utf8.char(event.unicode)
        set_text(self.text_id, self.text .. '|')
        return true
      end
    end

  end
  return false
end

function TextField:enable(bool)
  self.enabled = bool
  if self.enabled == false then
    set_segmented_panel_texture({
      id = self.id,
      texture = {
        texture = "gui",
        position = { x = 192, y = 0 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
    })
  else
    set_segmented_panel_texture({
      id = self.id,
      texture = {
        texture = "gui",
        position = { x = 192, y = 16 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
    })
  end
end

function TextField:delete()
end

return TextField
