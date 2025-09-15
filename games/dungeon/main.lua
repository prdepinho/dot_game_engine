
local Resources = require "games.dungeon.resources"
local Input = require "games.dungeon.input"
local Dialog = require "games.dungeon.dialog"
local Token = require "games.dungeon.token"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"


local wheel_down = false
local mouse_position = { x = 0, y = 0 }


function start_game()

  print('dungeon')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/dungeon/maps/')

  load_tilemap('sample_dungeon', 0, 0)

  local props = get_map_properties()
  print("map properties")
  for k, v in pairs(props) do
    print(k .. ": " .. tostring(v))
  end

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width / 2
  local panel_height = screen_dimensions.height / 2
  local panel_x = screen_dimensions.width / 2 - panel_width / 2
  local panel_y = screen_dimensions.height / 2 - panel_height / 2

  for i = 2, 18, 1 do
    local exp = rules.experience_for_level("fighter", i)
    print("lv: " .. tostring(i) .. " -> " .. tostring(exp))
  end

  -- set_draw_entities_ordered_by_position(unit_layer, true)
  create_text_line({
      id = "my_line_a",
      gui = true,
      layer = 1,
      position = { x = 20, y = 20 },
      text = "The quick brown fox jumps over the lazy dog.",
      font = "tiny_font",
      color = { r = 0, g = 0, b = 0, a = 255 },
      on_input = function(event) 
        return false
      end,
    })
  create_text_line({
      id = "my_line_b",
      gui = true,
      layer = 1,
      position = { x = 20, y = 50 },
      text = "The quick brown fox jumps over the lazy dog.",
      font = "small_font",
      color = { r = 0, g = 0, b = 0, a = 255 },
      on_input = function(event) 
        return false
      end,
    })

  create_sprite({
      id = "my_sprite_head",
      gui = false,
      layer = 1,
      position = { x = 100, y = 100 },
      dimensions = { width = 16, height = 16 },
      sprite = {
        texture = "sprites",
        origin = { x = 96, y = 416 },
        dimensions = { height = 16, width = 16 },
        animations = {
          {
            key = "stand",
            fps = 5,
            frames = { { x = 0, y = 0 } }
          },
        }
      }
    })
  sprite_start_animation("my_sprite_head", "stand", true)

  create_sprite({
      id = "my_sprite",
      gui = false,
      layer = 4,
      position = { x = 100, y = 100 },
      dimensions = { width = 16, height = 16 },
      sprite = {
        texture = "sprites",
        origin = { x = 0, y = 0 },
        dimensions = { height = 16, width = 16 },
        animations = {
          {
            key = "stand",
            fps = 5,
            frames = { { x = 0, y = 0 } }
          },
        }
      }
    })
  sprite_start_animation("my_sprite", "stand", true)

  create_sprite({
      id = "my_sprite_weapon",
      gui = false,
      layer = 2,
      position = { x = 100, y = 100 },
      dimensions = { width = 16, height = 16 },
      sprite = {
        texture = "sprites",
        origin = { x = 384, y = 416 },
        dimensions = { height = 16, width = 16 },
        animations = {
          {
            key = "stand",
            fps = 5,
            frames = { { x = 0, y = 0 } }
          },
        }
      }
    })
    sprite_start_animation("my_sprite_weapon", "stand", true)

end


function loop(delta)

end

function on_input(event)
  -- print('input: ' .. tostring(event.type))
  -- print('button: ' .. tostring(event.button))
  -- print('key: ' .. tostring(event.key))
  -- print('coords: ' .. tostring(event.x) .. ', ' .. tostring(event.y))
  -- print('delta: ' .. tostring(event.delta))

  -- mouse map panning
  if event.type == 'mouse_button_down' then
    if event.button == 2 then
      wheel_down = true
      mouse_position = get_game_mouse_position()
    end

  elseif event.type == 'mouse_button_up' then
    if event.button == 2 then
      wheel_down = false
    end

  elseif event.type == 'mouse_moved' then
    if wheel_down then
      local pos = get_game_mouse_position()
      local delta_x = mouse_position.x - pos.x
      local delta_y = mouse_position.y - pos.y
      pan_game_view(delta_x, delta_y)
      mouse_position = get_game_mouse_position()
    end
  end

  -- mouse move order
  if event.type == 'mouse_button_up' then
    if event.button == 1 then
      local pos = get_game_mouse_position()
    end
  end


  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.C then

    elseif event.key == Input.V then
      set_entity_visibility('obstacles', true)

    elseif event.key == Input.R then
      remove_tilemap()

    elseif event.key == Input.E then

    elseif event.key == Input.F then

    elseif event.key == Input.T then
      -- toggle_fullscreen()

    elseif event.key == Input.Up or event.key == Input.W then

    elseif event.key == Input.Down or event.key == Input.S then

    elseif event.key == Input.Left or event.key == Input.A then

    elseif event.key == Input.Right or event.key == Input.D then
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up or event.key == Input.W then
    elseif event.key == Input.Down or event.key == Input.S then
    elseif event.key == Input.Left or event.key == Input.A then
    elseif event.key == Input.Right or event.key == Input.D then
    end

  elseif event.type == 'mouse_button_down' then
    print('mouse button: ' .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    if event.button == 0 then
      local pos = get_game_mouse_position()
      local tile = get_tile('grass', pos.x, pos.y)
    end

  elseif event.type == 'mouse_moved' then

  elseif event.type == 'mouse_scrolled' then
    if event.delta == 1 then
      print('up')
      zoom_game_view(0.9)
    else
      print('down')
      zoom_game_view(1.1)
    end

  end
end

function end_game()
  print('end')
end



