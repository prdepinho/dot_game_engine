
local Resources = require "games.dungeon.resources"
local Input = require "games.dungeon.input"
local Dialog = require "games.dungeon.dialog"
local Token = require "games.dungeon.token"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"
local Button = require "games.dungeon.button"
local TextField = require "games.dungeon.text_field"
local Screen = require "games.dungeon.screen"


local MenuScreen = {}
MenuScreen.__index = MenuScreen
setmetatable(MenuScreen, { __index = Screen })

function MenuScreen:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function MenuScreen:open()
  Screen.open(self)

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width / 2
  local panel_height = screen_dimensions.height / 2
  local panel_x = screen_dimensions.width / 2 - panel_width / 2
  local panel_y = screen_dimensions.height / 2 - panel_height / 2

  create_segmented_panel({
      id = "window",
      gui = true,
      layer = 1,
      position = { x = panel_x, y = panel_y },
      dimensions = { width = panel_width, height = panel_height },
      texture = {
        texture = "gui",
        position = { x = 192, y = 0 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
      on_input = function(event) 
        if event.type == 'mouse_button_down' then
          if event.button == 0 then
            print("Tickles")
            return true
          end
        end
        return false
      end,
  })

  local button = Button:new(self, "button")
  button:create("Botão", 2, { x = 100, y = 100 }, { width = 100, height = 20 }, function() print("click") end)
  self:add_component(button)

  local disable_button = Button:new(self, "disable_button")
  disable_button:create("Fête", 2, { x = 100, y = 130 }, { width = 100, height = 20 }, function()
    self.components['button']:enable(not self.components['button'].enabled)
    self.components['text_field']:enable(not self.components['text_field'].enabled)
  end)
  self:add_component(disable_button)

  local text_field = TextField:new(self, "text_field")
  text_field:create(2, { x = 50, y = 50 }, 100)
  self:add_component(text_field)


  set_focused_entity("text_field")

end

function MenuScreen:loop(delta)
  Screen.loop(self, delta)
end

function MenuScreen:on_input(event)
  Screen.on_input(self, event)
  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()
    end
  end
end

function MenuScreen:close()
  Screen.close(self)
  remove_entity("window")
end


return MenuScreen

