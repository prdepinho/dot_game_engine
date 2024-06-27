
local Resources = require "games.cards.resources"
local Input = require "games.cards.input"
local Dialog = require "games.cards.dialog"

local left_mouse_down = false
local mouse_position = { x = 0, y = 0 }

function start_game()

  Resources:load_assets()
  Resources:load_font()

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

  -- my_panel = {
  --   id = "my_component_panel",
  --   gui = true,
  --   layer = 2,
  --   position = { x = 500, y = 500 },
  --   dimensions = { width = 100, height = 80 },
  --   texture = {
  --     texture = "gui",
  --     position = { x = 0, y = 0 },
  --     border_size = 4,
  --     interior = { width = 8, height = 8 },
  --   },
  --   on_input = function(event) 
  --     if event.type == 'mouse_button_down' then
  --       my_panel.button = 'down'
  --       print('button ' .. my_panel.button)
  --       return true
  --     elseif event.type == 'mouse_button_up' then
  --       if my_panel.button == 'down' then
  --         print('click')
  --       end
  --       my_panel.button = 'up'
  --       print('button ' .. my_panel.button)
  --       return true
  --     end
  --     return false
  --   end,
  -- }
  -- create_segmented_panel(my_panel)

  card = {
      id = "card_panel",
      gui = false,
      layer = 1,
      position = { x = 0, y = 0 },
      dimensions = { width = 745*2/5, height = 1040*2/5 },
      texture = {
        texture = "2ed_150",
        position = { x = 0, y = 0 },
        dimensions = { width = 745, height = 1040 },
      },
      on_input = function(event) 
        print("it's me")
      end,
    }
  create_panel(card)

  card_thumb = {
      id = "card_thumb_panel",
      gui = false,
      layer = 1,
      position = { x = 500, y = 100 },
      dimensions = { width = 592*1/5, height = 478*1/5 },
      texture = {
        texture = "2ed_100",
        position = { x = 74, y = 100 },
        dimensions = { width = 592, height = 478 },
      },
      on_input = function(event) 
        print("it's me")
      end,
    }
  create_panel(card_thumb)


  dialog = Dialog:new()
  dialog:create()

  set_draw_entities_ordered_by_position(3, true)

end



function loop(delta)
end

function on_input(event)
  -- print('input: ' .. tostring(event.type))
  -- print('button: ' .. tostring(event.button))
  -- print('key: ' .. tostring(event.key))
  -- print('coords: ' .. tostring(event.x) .. ', ' .. tostring(event.y))
  -- print('delta: ' .. tostring(event.delta))

  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.D then

    elseif event.key == Input.C then

    elseif event.key == Input.V then
      set_entity_visibility('obstacles', true)

    elseif event.key == Input.R then

    elseif event.key == Input.F then

    elseif event.key == Input.T then
      toggle_fullscreen()

    elseif event.key == Input.Up then

    elseif event.key == Input.Down then

    elseif event.key == Input.Left then

    elseif event.key == Input.Right then
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up then
    elseif event.key == Input.Down then
    elseif event.key == Input.Left then
    elseif event.key == Input.Right then
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
    if event.button == 0 then
      local pos = get_game_mouse_position()
      print('coords: ' .. tostring(pos.x) .. ', ' .. tostring(pos.y))
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

