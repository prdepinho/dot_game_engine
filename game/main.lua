
local Resources = require "game.resources"
local Input = require "game.input"
local Unit = require "game.unit"

local up = false
local down = false
local left = false
local right = false

local left_mouse_down = false
local mouse_position = { x = 0, y = 0 }



local unit = {}



function start_game()

  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('game/maps/')

  load_tilemap('map32', 0, 0)

  local props = get_map_properties()
  print("map properties")
  for k, v in pairs(props) do
    print(k .. ": " .. tostring(v))
  end

  -- local my_point = get_map_object('objects', 'my_line')
  -- print('object: ')
  -- for k, v in pairs(my_point) do
  --   print(k .. ": " .. tostring(v))
  --   if k == 'position' then
  --     print('  (' .. tostring(v.x) .. ', ' .. tostring(v.y) .. ')')
  --   elseif k == 'properties' then
  --     print('properties size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv))
  --     end
  --   elseif k == 'AABB' then
  --     print('AABB size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv))
  --     end
  --   elseif k == 'points' then
  --     print('points size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv.x) .. ', ' .. tostring(pv.y))
  --     end
  --   end
  -- end

  -- set_callback({
  --   id = "bottom_layer",
  --   on_input = function(event)
  --     if event.type == "mouse_button_down" then
  --       if event.button == 0 then
  --         local tile = get_tile_under_cursor("obstacles")
  --         print("tile x: " .. tostring(tile.x) .. ", y: " .. tostring(tile.y))

  --         local ptile = get_tile_texture("obstacles", tile.x, tile.y)
  --         print('px: ' .. tostring(ptile.x) .. ', ' .. tostring(ptile.y))
  --         return true
  --       end
  --     end
  --     return false
  --   end
  -- })



  unit = Unit:new()
  unit:create(100, 100, 3, 10)


  set_draw_entities_ordered_by_position(3, true)


end



local delta_x;
local delta_y;

local delta_movement = 0;
local delta_angle = 0.0;

function loop(delta)

  if delta_angle ~= 0.0 then
    unit:rotate(delta_angle)
  end

  if delta_movement ~= 0 then
    unit:move(delta_movement)
  end


  if up then
    delta_y = -1
  elseif down then
    delta_y = 1
  else
    delta_y = 0
  end
  if left then
    delta_x = -1
  elseif right then
    delta_x = 1
  else
    delta_x = 0
  end


  local direction = ""
  if up then
    direction = direction .. "n"
  end
  if down then
    direction = direction .. "s"
  end
  if left then
    direction = direction .. "w"
  end
  if right then
    direction = direction .. "e"
  end
  if direction ~= "" then
  end
end

function on_input(event)
  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.D then
      load_tilemap("test2", 0, 0)

    elseif event.key == Input.C then
      load_tilemap("test", 0, 0)

    elseif event.key == Input.V then
      set_entity_visibility('obstacles', true)

    elseif event.key == Input.R then
      remove_tilemap()

    elseif event.key == Input.F then
      print('open fire')
      unit:fire()

    elseif event.key == Input.Up then
      up = true
      down = false
      delta_movement = 1

    elseif event.key == Input.Down then
      down = true
      up = false
      delta_movement = -1

    elseif event.key == Input.Left then
      left = true
      right = false
      delta_angle = -1.0

    elseif event.key == Input.Right then
      right = true
      left = false
      delta_angle = 1.0
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up then
      if up then
        delta_movement = 0
      end
      up = false
    elseif event.key == Input.Down then
      if down then
        delta_movement = 0
      end
      down = false
    elseif event.key == Input.Left then
      if left then
        delta_angle = 0.0
      end
      left = false
    elseif event.key == Input.Right then
      if right then
        delta_angle = 0.0
      end
      right = false
    end

  elseif event.type == 'mouse_button_down' then
    if event.button == 1 then
      left_mouse_down = true
      mouse_position = get_game_mouse_position()
    end

  elseif event.type == 'mouse_button_up' then
    if event.button == 1 then
      left_mouse_down = false
    end

  elseif event.type == 'mouse_moved' then
    if left_mouse_down then
      local pos = get_game_mouse_position()
      local delta_x = mouse_position.x - pos.x
      local delta_y = mouse_position.y - pos.y
      pan_game_view(delta_x, delta_y)
      mouse_position = get_game_mouse_position()
    end

  elseif event.type == 'mouse_scrolled' then

  end
end

function end_game()
  print('end')
end

