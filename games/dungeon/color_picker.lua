
local Screen = require "games.dungeon.screen"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"
local Button = require "games.dungeon.button"
local Screen = require "games.dungeon.screen"
local TextField = require "games.dungeon.text_field"
local TextArea = require "games.dungeon.text_area"


local ColorPicker = {}
ColorPicker.__index = ColorPicker
setmetatable(ColorPicker, { __index = Screen })

function ColorPicker:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function ColorPicker:open(layer, colors)
  Screen.open(self, layer)

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width / 2
  local panel_height = screen_dimensions.height / 2
  local panel_x = screen_dimensions.width / 2 - panel_width / 2
  local panel_y = screen_dimensions.height / 2 - panel_height / 2

  self.colors = colors
  self.selected_color = nil

  create_segmented_panel({
      id = "color_picker_window",
      gui = true,
      layer = self.layer,
      position = { x = panel_x, y = panel_y },
      dimensions = { width = panel_width, height = panel_height },
      texture = {
        texture = "gui",
        position = { x = 224, y = 0 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
      on_input = function(event) 
        if event.type == "mouse_button_down" then
          return true
        elseif event.type == "mouse_button_up" then
          return true
        elseif event.type == "mouse_moved" then
          return true
        end
        return false
      end,
  })


  local columns = math.ceil(math.sqrt(#self.colors))
  local button_width = 20
  local button_height = 20

  local buttons_x = panel_x + panel_width / 2 - button_width * columns / 2
  local buttons_y = panel_y + panel_height / 2 - button_height * columns / 2

  for i,color in ipairs(self.colors) do
    local j = math.floor(i / columns)
    local x = buttons_x + math.floor(i / columns) * button_width
    local y = buttons_y + math.floor(i % columns) * button_height
    local texture = { texture = "tiles", position = { x = 0, y = 48 }, dimensions = { width = 16, height = 16 } }
    local button  = Button:new(self, "pick_color_button_" .. i)
    button:create_with_icon(texture, self.layer+1, { x = x, y = y }, { width = button_width, height = button_height }, function(event) 
      self.selected_color = color
      self.running = false
      if self.callback ~= nil then
        self.callback(color)
      end
    end)
    self:add_component(button)

    load_shader_fragment({ id = button.child_id, path = "games/dungeon/swap.frag" })
    set_shader_uniform({
      id = button.child_id,
      uniforms = {
        { key = "texture",      type = "texture", value = "tiles" },
        { key = "oldColors[0]", type = "vec4",    value = { x = 0xff/255.0,    y = 0xff/255.0,    z = 0xff/255.0,    w = 1.0 } },
        { key = "newColors[0]", type = "vec4",    value = { x = color.r/255.0, y = color.g/255.0, z = color.b/255.0, w = 1.0 } },
        }
    })
  end

end

function ColorPicker:set_visibility(bool)
  Screen.set_visibility(self, bool)
  set_entity_visibility("color_picker_window", bool)
end

function ColorPicker:loop(delta)
end

function ColorPicker:on_input(event)
end

function ColorPicker:delete()
  Screen.delete(self)
  remove_entity("color_picker_window")
end


return ColorPicker

