
local Resources = require "games.dungeon.resources"
local Input = require "games.dungeon.input"
local Dialog = require "games.dungeon.dialog"
local Token = require "games.dungeon.token"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"
local Button = require "games.dungeon.button"


local MenuScreen = {}

function MenuScreen:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function MenuScreen:open()
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

  self.components = {}

  local button = Button:new()
  button:create("button", "Click me", 2, { x = 100, y = 100 }, { width = 100, height = 20 }, function() print("click") end)
  self.components['button'] = button

  local disable_button = Button:new()
  disable_button:create("disable_button", "Disable", 2, { x = 100, y = 130 }, { width = 100, height = 20 }, function()
    self.components['button']:enable(not self.components['button'].enabled)
  end)
  self.components['disable_button'] = disable_button

end

function MenuScreen:loop(delta)
end

function MenuScreen:on_input(event)
  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()
    end

  elseif event.type == 'mouse_moved' then
    for _,component in pairs(self.components) do
      local pos = get_gui_mouse_position()
      if entity_contains(component.id, pos.x, pos.y) then
        if component.highlighted == false then
          component:on_entered()
          component.highlighted = true
          print("inside button")
        end
      else
        if component.highlighted == true then
          component:on_exited()
          component.highlighted = false
          print("outside button")
        end
      end
    end
  end
end

function MenuScreen:close()
  remove_entity("window")
  for _,component in ipairs(self.components) do
    component:delete()
  end
end


return MenuScreen

