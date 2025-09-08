
local Dialog = {}

function Dialog:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Dialog:create(x, y, w, h)
  self.panel = {
    id = "my_component_panel",
    gui = true,
    layer = 3,
    position = { x = x, y = y },
    dimensions = { width = w, height = h },
    texture = {
      texture = "gui",
      position = { x = 192, y = 0 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
    on_input = function(event) 

      if event.type == 'mouse_button_down' then
        self.panel.button = 'down'
        print('button ' .. self.panel.button)
        return true

      elseif event.type == 'mouse_button_up' then
        if self.panel.button == 'down' then
          print('click')
        end
        self.panel.button = 'up'
        print('button ' .. self.panel.button)
        return true
      end

      return false
    end,
  }
  create_segmented_panel(self.panel)

  self.line = {
    id = 'my_text_line',
    layer = 4,
    position = { x = x + 20, y = y + 20 },
    gui = true,
    text = 'foobar',
    font = 'small_font',
    color = { r = 0, g = 0, b = 0, a = 255 }
  }
  create_text_line(self.line)

end


return Dialog
