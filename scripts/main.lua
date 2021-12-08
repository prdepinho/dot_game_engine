
local Resources = require "scripts.resources"
local Input = require "scripts.input"

local up = false
local down = false
local left = false
local right = false
local current_animation = ""


local infantry_sprite = {
  texture = "sprites",
  origin = { x = 0, y = 0 },
  dimensions = { height = 16, width = 16 },
  animations = {
    {
      key = "march_s",
      fps = 5,
      frames = { { x = 0, y = 0 }, { x = 0, y = 1 } }
    },
    {
      key = "march_se",
      fps = 5,
      frames = { { x = 1, y = 0 }, { x = 1, y = 1 } }
    },
    {
      key = "march_e",
      fps = 5,
      frames = { { x = 2, y = 0 }, { x = 2, y = 1 } }
    },
    {
      key = "march_ne",
      fps = 5,
      frames = { { x = 3, y = 0 }, { x = 3, y = 1 } }
    },
    {
      key = "march_n",
      fps = 5,
      frames = { { x = 4, y = 0 }, { x = 4, y = 1 } }
    },
    {
      key = "march_nw",
      fps = 5,
      frames = { { x = 5, y = 0 }, { x = 5, y = 1 } }
    },
    {
      key = "march_w",
      fps = 5,
      frames = { { x = 6, y = 0 }, { x = 6, y = 1 } }
    },
    {
      key = "march_sw",
      fps = 5,
      frames = { { x = 7, y = 0 }, { x = 7, y = 1 } }
    },
    {
      key = "fire_s",
      fps = 3,
      frames = { 
        function(id)
          print('fire: ' .. id) 
          local smoke = {
            id = id .. "_gun_smoke",
            layer = 2,
            position = { x = my_sprite.position.x, y = my_sprite.position.y + 16 },
            dimensions = { width = 16, height = 16 },
            sprite = {
              texture = "effects",
              origin = { x = 0, y = 0 },
              dimensions = { height = 16, width = 16 },
              animations = {
                {
                  key = "smoke_loop",
                  fps = 5,
                  frames = {
                    { x = 0, y = 4 },
                    { x = 1, y = 4 },
                  }
                },
                {
                  key = "fire_s",
                  fps = 6,
                  frames = { 
                    { x = 0, y = 0 },
                    { x = 0, y = 1 },
                  }
                }
              }
            }
          }
          create_sprite(smoke)
          sprite_start_animation("my_sprite_gun_smoke", "smoke_loop", true)
          sprite_start_animation("my_sprite_gun_smoke", "fire_s", false)
        end,
        { x = 0, y = 2 },
        { x = 0, y = 0 },
      }
    },
    {
      key = "fire_se",
      fps = 5,
      frames = { { x = 1, y = 2 } }
    },
    {
      key = "fire_e",
      fps = 5,
      frames = { { x = 2, y = 2 } }
    },
    {
      key = "fire_ne",
      fps = 5,
      frames = { { x = 3, y = 2 } }
    },
    {
      key = "fire_n",
      fps = 5,
      frames = { { x = 4, y = 2 } }
    },
    {
      key = "fire_nw",
      fps = 5,
      frames = { { x = 5, y = 2 } }
    },
    {
      key = "fire_w",
      fps = 5,
      frames = { { x = 6, y = 2 } }
    },
    {
      key = "fire_sw",
      fps = 5,
      frames = { { x = 7, y = 2 } }
    },

  }
}



function start_game()

  Resources:load_assets()
  Resources:load_font()


  local my_tile_layer = {
    id = "my_tile_layer",
    gui = false,
    layer = 1,
    position = { x = 0, y = 0 },
    tile_dimensions = { width = 16, height = 16 },
    rows = 16,
    columns = 20,
    texture = "tiles",
    tiles = {
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
    },
    -- on_input = function(event)
    --   if event.type == "mouse_button_down" then
    --     tile = get_tile_under_cursor("my_tile_layer")
    --     print("tile x: " .. tostring(tile.x) .. ", y: " .. tostring(tile.y))
    --     return true
    --   end
    --   return false
    -- end
  }
  create_tile_layer(my_tile_layer)


  -- local i = 19
  local i = 29
  for yy = 0, i, 1 do
    for xx = 0, i, 1 do
      local sprite = {
        id = "my_sprite_" .. tostring(xx) .. "_" .. tostring(yy),
        gui = false,
        layer = 2,
        position = { x = 8 * xx, y = 8 * yy },
        dimensions = { width = 16, height = 16 },
        on_input = function(event)
          return false
        end,
        sprite = infantry_sprite
      }
      -- print('create sprite: [' .. sprite.id .. ']: ' .. tostring(xx) .. ", " .. tostring(yy))
      create_sprite(sprite)
      sprite_start_animation(sprite.id, "march_s", true)

    end
  end


  set_draw_entities_ordered_by_position(2, true)


  cavalry = {
    id = "cavalry",
    gui = false,
    layer = 2,
    position = { x = 66, y = 66 },
    dimensions = { width = 16, height = 16 },
    on_input = function(event)
      if event.type == "mouse_button_down" then
        local tile = get_entity("cavalry")
        print("id: " .. tile.id .. ", layer: " .. tostring(tile.layer) .. ", type: " .. tile.type .. ", gui: " .. tostring(tile.gui))
        print("x: " .. tostring(tile.position.x) .. ", y: " .. tostring(tile.position.y))
        print("w: " .. tostring(tile.dimensions.width) .. ", h: " .. tostring(tile.dimensions.height))
        return true

      elseif event.type == 'key_down' then
        local tile = get_entity("cavalry")

        if event.key == Input.Up then
          print("up layer")
          set_layer(tile.id, tile.layer + 1)
          return true

        elseif event.key == Input.Down then
          print("down layer")
          set_layer(tile.id, tile.layer - 1)
          return true

        elseif event.key == Input.D then
          remove_entity('cavalry')
          return true

        end
      end

      return false
    end,
    sprite = {
      texture = "sprites",
      origin = { x = 0, y = 96 },
      dimensions = { height = 32, width = 16 },
      animations = {
        {
          key = "march_s",
          fps = 5,
          frames = { { x = 0, y = 0 }, { x = 0, y = 1 } }
        },
        {
          key = "march_se",
          fps = 5,
          frames = { { x = 1, y = 0 }, { x = 1, y = 1 } }
        },
        {
          key = "march_e",
          fps = 5,
          frames = { { x = 2, y = 0 }, { x = 2, y = 1 } }
        },
        {
          key = "march_ne",
          fps = 5,
          frames = { { x = 3, y = 0 }, { x = 3, y = 1 } }
        },
        {
          key = "march_n",
          fps = 5,
          frames = { { x = 4, y = 0 }, { x = 4, y = 1 } }
        },
        {
          key = "march_nw",
          fps = 5,
          frames = { { x = 5, y = 0 }, { x = 5, y = 1 } }
        },
        {
          key = "march_w",
          fps = 5,
          frames = { { x = 6, y = 0 }, { x = 6, y = 1 } }
        },
        {
          key = "march_sw",
          fps = 5,
          frames = { { x = 7, y = 0 }, { x = 7, y = 1 } }
        },
      }
    },
  }
  -- create_sprite(cavalry)
  -- sprite_start_animation("cavalry", "march_s", true)


end



local delta_x;
local delta_y;

function loop(delta)

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

  pan_game_view(delta_x, delta_y)


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
    local animation = "march_" .. direction
    if current_animation ~= animation then
      print('animation: ' .. animation)
      -- sprite_start_animation("cavalry", animation, true)
      current_animation = animation
    end
  end
end

function on_input(event)
  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.F then
      -- sprite_start_animation("cavalry", "fire_s", false)

    elseif event.key == Input.Up then
      print('up')
      up = true
      down = false

    elseif event.key == Input.Down then
      print('down')
      down = true
      up = false

    elseif event.key == Input.Left then
      print('left')
      left = true
      right = false

    elseif event.key == Input.Right then
      print('right')
      right = true
      left = false
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up then
      up = false
    elseif event.key == Input.Down then
      down = false
    elseif event.key == Input.Left then
      left = false
    elseif event.key == Input.Right then
      right = false
    end

  elseif event.type == 'mouse_button_down' then
    print(tostring(event.elapsed_time) .. " mouse down: " .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    -- print(tostring(event.elapsed_time) .. " mouse up: " .. tostring(event.button))
    -- local game_pos = get_game_mouse_position()
    -- local gui_pos = get_gui_mouse_position()
    -- print("game - x: " .. tostring(game_pos.x) .. ", y: " .. tostring(game_pos.y))
    -- print("gui - x: " .. tostring(gui_pos.x) .. ", y: " .. tostring(gui_pos.y))

  elseif event.type == 'mouse_moved' then
    -- print(tostring(event.elapsed_time) .. " mouse move - x: " .. tostring(event.x) .. ", y: " .. tostring(event.y))

  elseif event.type == 'mouse_scrolled' then
    -- print(tostring(event.elapsed_time) .. " mouse scrolled: " .. tostring(event.delta))

  end
end

function end_game()
  print('end')
end

