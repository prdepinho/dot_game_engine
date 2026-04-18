
local Input = require "games.dungeon.input"
local Component = require "games.dungeon.component"

local TextArea = {}
TextArea.__index = TextArea
setmetatable(TextArea, { __index = Component })

function TextArea:new(screen, id, o)
  o = o or {}
  setmetatable(o, self)
  o.screen = screen
  o.id = id
  return o
end

function TextArea:create(layer, position, dimensions)
  self.text_id = self.id .. "_text"
  self.text = ""
  create_segmented_panel({
    id = self.id,
    gui = true,
    layer = layer,
    position = position,
    dimensions = dimensions,
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

  create_text_block({
    id = self.text_id,
    gui = true,
    layer = layer + 1,
    position = { x = 0, y = 0 },
    line_length = dimensions.width - 5,
    text = self.text,
    font = "small_font",
    color = { r = 0, g = 0, b = 255, a = 255 }
  })

  local area_entity = get_entity(self.id)
  local text_entity = get_entity(self.text_id)
  local text_x = area_entity.position.x + 4
  local text_y = area_entity.position.y + 4
  set_position(self.text_id, text_x, text_y)

  set_dimensions(self.text_id, area_entity.dimensions.width, area_entity.dimensions.height)
  set_entity_view({
    id = self.text_id,
    position = {
      x = area_entity.position.x + 4,
      y = area_entity.position.y + 4,
    },
    dimensions = {
      width = area_entity.dimensions.width - 6,
      height = area_entity.dimensions.height - 6
    }
  })
end

function TextArea:set_text(text)
  self.text = text
  set_text(self.text_id, text)

  local area_entity = get_entity(self.id)
  local text_entity = get_entity(self.text_id)

  local diff = area_entity.dimensions.height - text_entity.dimensions.height

  if diff < 0 then
    set_position(self.text_id, text_entity.position.x, area_entity.position.y + diff)
  end
end

function TextArea:on_input(event)
  if event.type == "mouse_button_down" then
    return true

  elseif event.type == 'mouse_scrolled' then
    local delta_x = 0
    local delta_y = event.delta * 10
    -- pan_entity_view(self.text_id, delta_x, delta_y * -1)
    move_entity(self.text_id, delta_x, delta_y)
    return true

  elseif event.type == "key_down" then
  end
  return false
end

function TextArea:set_visibility(bool)
  set_entity_visibility(self.id, bool)
  set_entity_visibility(self.text_id, bool)
end


function TextArea:delete()
  remove_entity(self.id)
  remove_entity_view(self.text_id)
  remove_entity(self.text_id)
end

return TextArea
