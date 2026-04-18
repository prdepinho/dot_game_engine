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
  self.callback = nil
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

  local field_entity = get_entity(self.id)
  local text_entity = get_entity(self.text_id)
  local text_x = field_entity.position.x + 4
  local text_y = field_entity.position.y + (field_entity.dimensions.height / 2) - (text_entity.dimensions.height / 2)
  set_position(self.text_id, text_x, text_y)

  set_entity_view({ 
    id = self.text_id,
    position = {
      x = field_entity.position.x + 4,
      y = field_entity.position.y + 4
    },
    dimensions = {
      width = field_entity.dimensions.width - 6,
      height = field_entity.dimensions.height - 6
    }
  })
end

function TextField:set_text(text)
  self.text = text
  if is_focused_entity(self.id) then
    set_text(self.text_id, text .. '|')
  else
    set_text(self.text_id, text)
  end

  local field_entity = get_entity(self.id)
  local text_entity = get_entity(self.text_id)

  local diff = field_entity.dimensions.width - 4 - text_entity.dimensions.width

  if diff >= 0 then
    set_position(self.text_id, field_entity.position.x + 4, text_entity.position.y)

  else
    set_position(self.text_id, field_entity.position.x + diff , text_entity.position.y)
  end

end

function TextField:on_input(event)
  local rval = false
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
        if #self.text > 0 then
          local last = utf8.offset(self.text, -1)
          local text = string.sub(self.text, 1, last - 1)
          self:set_text(text)
        end
        rval = true
      elseif event.unicode == 0x1B then  -- esc
        rval = true
      elseif event.unicode == 0x0D then  -- CR
        -- set_focused_entity(nil)
        rval = true
      else
        local entity = get_entity(self.id)
        local text_entity = get_entity(self.text_id)
        self:set_text(self.text .. utf8.char(event.unicode))
        rval = true
      end

      if self.callback ~= nil then
        self.callback(event.unicode)
      end
    end

  elseif event.type == "key_down" then
    if is_focused_entity(self.id) and self.enabled then
      if event.key == Input.Escape then
        set_focused_entity(nil)
      end
    end
    return true

  end
  return rval
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

function TextField:set_visibility(bool)
  set_entity_visibility(self.id, bool)
  set_entity_visibility(self.text_id, bool)
end

function TextField:delete()
  remove_entity(self.id)
  remove_entity_view(self.text_id)
  remove_entity(self.text_id)
end

return TextField
