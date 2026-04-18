
local Input = require "games.dungeon.input"
local Resources = require "games.dungeon.resources"
local GameScreen = require "games.dungeon.game_screen"
local MenuScreen = require "games.dungeon.menu_screen"
local CharacterCreationScreen = require "games.dungeon.character_creation_screen"
local ColorPicker = require "games.dungeon.color_picker"


screens = {}


function start_game()

  print('dungeon')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/dungeon/maps/')

  math.randomseed(os.time())

end

function loop(delta)
  for i = #screens, 1, -1 do
    local screen = screens[i]
    if screen.running == true then
      screen:loop(delta)
    else
      screen:delete()
      table.remove(screens, i)
    end
  end
end

function on_input(event)
  for _,screen in ipairs(screens) do
    screen:on_input(event)
  end

  local layer = #screens + 3

  if event.type == "text_entered" then

    if event.unicode  == string.byte('1') then
      local screen = GameScreen:new()
      table.insert(screens, screen)
      screen:open(layer)

    elseif event.unicode == string.byte('2') then
      local screen = MenuScreen:new()
      table.insert(screens, screen)
      screen:open(layer)

    elseif event.unicode == string.byte('3') then
      local screen = CharacterCreationScreen:new()
      table.insert(screens, screen)
      screen:open(layer)

    elseif event.unicode == string.byte('4') then
      local screen = ColorPicker:new()
      local colors = {
        { r = 0xaa, g = 0xa3, b = 0xaa },  -- aa a3 aa
        { r = 0xbc, g = 0x86, b = 0x3d },  -- bc 86 3d
        { r = 0x3a, g = 0x02, b = 0x36 },  -- 3a 02 36
        { r = 0xf2, g = 0xe4, b = 0xc8 },  -- f2 e4 c8
        { r = 0xf2, g = 0xb7, b = 0x66 },  -- f2 b7 66
        { r = 0xdb, g = 0xa3, b = 0x26 },  -- db a3 26
        { r = 0x71, g = 0xb7, b = 0x87 },  -- 71 b7 87
        { r = 0x85, g = 0x98, b = 0x1d },  -- 85 98 1d
        { r = 0x36, g = 0x6b, b = 0x15 },  -- 36 6b 15
        { r = 0x8b, g = 0x5f, b = 0x23 },  -- 8b 5f 23
        { r = 0x7d, g = 0x65, b = 0x7c },  -- 7d 65 7c
        { r = 0x6b, g = 0x21, b = 0x79 },  -- 6b 21 79
        { r = 0x8f, g = 0x0e, b = 0x2b },  -- 8f 0e 2b
        { r = 0xd2, g = 0x35, b = 0x35 },  -- d2 35 35
      }
      table.insert(screens, screen)
      screen:open(layer, colors)

    end

  elseif event.type == "key_down" then
    if event.key == Input.BackSpace then
      if #screens > 0 then
        screens[#screens]:delete()
        table.remove(screens, #screens)
      end

    elseif event.key == Input.Escape then
      close_game()

    elseif event.key == Input.Tab then
      local ids = get_entity_ids()
      print("Entities (" .. tostring(#ids) .. "):")
      for i,id in ipairs(ids) do
        print(tostring(i) .. ': ' .. id)
      end
    end
  end
end

function end_game()
  for _,screen in ipairs(screens) do
    screen:delete()
  end
  print('end')
end



function table.contains(list, element)
  for _,elm in ipairs(list) do
    if elm == element then
      return true
    end
  end
  return false
end
