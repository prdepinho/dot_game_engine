
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
        end,
        { x = 0, y = 2 },
        { x = 0, y = 0 },
      }
    },
    {
      key = "fire_se",
      fps = 3,
      frames = { { x = 1, y = 2 } }
    },
    {
      key = "fire_e",
      fps = 3,
      frames = { { x = 2, y = 2 } }
    },
    {
      key = "fire_ne",
      fps = 3,
      frames = { { x = 3, y = 2 } }
    },
    {
      key = "fire_n",
      fps = 3,
      frames = { { x = 4, y = 2 } }
    },
    {
      key = "fire_nw",
      fps = 3,
      frames = { { x = 5, y = 2 } }
    },
    {
      key = "fire_w",
      fps = 3,
      frames = { { x = 6, y = 2 } }
    },
    {
      key = "fire_sw",
      fps = 3,
      frames = { { x = 7, y = 2 } }
    },

  }
}


function get_direction(angle)
  if angle > 338 then
    return "n"
  elseif angle > 293 then
    return "nw"
  elseif angle > 247 then
    return "w"
  elseif angle > 203 then
    return "sw"
  elseif angle > 160 then
    return "s"
  elseif angle > 113 then
    return "se"
  elseif angle > 68 then
    return "e"
  elseif angle > 23 then
    return "ne"
  else 
    return "n"
  end
end




local Unit = {}

function Unit:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Unit:rotate(angle)
  rotate_entity("base", angle)
  local rotation = get_rotation("base")
  local center = get_entity('base').position
  local animation = "march_" .. get_direction(rotation)
  print(animation)
  for k, v in pairs(self.sprites) do
    local rads = math.rad(rotation) + v.angle
    local pos = get_entity(k).position
    local dx = center.x + math.sin(rads) * v.distance
    local dy = center.y + math.cos(rads + math.pi) * v.distance
    set_position(k, dx, dy)
    sprite_start_animation(k, animation, true)
  end
end

function Unit:move(delta)
  local rotation = get_rotation("base")
  local rads = math.rad(rotation)
  local dx = math.sin(rads) * delta
  local dy = math.cos(rads + math.pi) * delta
  move_entity("base", dx, dy)
  for k, v in pairs(self.sprites) do
    move_entity(k, dx, dy)
  end
end

function Unit:fire()
  local base_rotation = get_rotation('base')
  local base_direction = get_direction(base_rotation)

  for i = 0, self.file - 1, 1 do
    local id = 'sprite_' .. tostring(i) .. '_0'
    local rotation = get_rotation(id)
    local rads = math.rad(rotation)
    local pos = get_entity(id).position
    local dx = pos.x + math.sin(rads)
    local dy = pos.y + math.cos(rads + math.pi)
    print('dx: ' .. tostring(dx) .. ', dy: ' .. tostring(dy))

    local smoke = {
      id = id .. "_gun_smoke",
      layer = 4,
      position = { x = dx, y = dy },
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
              { x = 0, y = 4 },
              { x = 1, y = 4 },
              { x = 0, y = 4 },
              function(id)
                remove_entity(id)
              end,
              { x = 1, y = 4 },
            }
          },
          {
            key = "fire_s",
            fps = 6,
            frames = { { x = 0, y = 0 }, { x = 0, y = 1 }, }
          },
          {
            key = "fire_se",
            fps = 3,
            frames = { { x = 1, y = 0 }, { x = 1, y = 1 }, }
          },
          {
            key = "fire_e",
            fps = 3,
            frames = { { x = 2, y = 0 }, { x = 2, y = 1 }, }
          },
          {
            key = "fire_ne",
            fps = 3,
            frames = { { x = 3, y = 0 }, { x = 3, y = 1 }, }
          },
          {
            key = "fire_n",
            fps = 3,
            frames = { { x = 4, y = 0 }, { x = 4, y = 1 }, }
          },
          {
            key = "fire_nw",
            fps = 3,
            frames = { { x = 5, y = 0 }, { x = 5, y = 1 }, }
          },
          {
            key = "fire_w",
            fps = 3,
            frames = { { x = 6, y = 0 }, { x = 6, y = 1 }, }
          },
          {
            key = "fire_sw",
            fps = 3,
            frames = { { x = 7, y = 0 }, { x = 7, y = 1 }, }
          },
        }
      }
    }
    create_sprite(smoke)
    if base_direction == 'n' then
      set_origin(smoke.id, 8, 16)
      move_entity(smoke.id, 0, -16)

    elseif base_direction == 'nw' then
      set_origin(smoke.id, 16, 16)
      move_entity(smoke.id, -8, -16)

    elseif base_direction == 'w' then
      set_origin(smoke.id, 16, 16)
      move_entity(smoke.id, -8, 0)

    elseif base_direction == 'sw' then
      set_origin(smoke.id, 16, 0)
      move_entity(smoke.id, -8, 0)

    elseif base_direction == 's' then
      set_origin(smoke.id, 16, 0)
      move_entity(smoke.id, 8, 0)

    elseif base_direction == 'se' then
      set_origin(smoke.id, 0, 0)
      move_entity(smoke.id, 8, 0)

    elseif base_direction == 'e' then
      set_origin(smoke.id, 0, 16)
      move_entity(smoke.id, 8, 0)

    elseif base_direction == 'ne' then
      set_origin(smoke.id, 0, 16)
      move_entity(smoke.id, 8, -16)

    end
    sprite_start_animation(smoke.id, "smoke_loop", true)
    sprite_start_animation(smoke.id, "fire_" .. base_direction, false)
    sprite_start_animation(id, "fire_" .. base_direction, false)

  end

end

function Unit:create(x, y, rank, file)
  local w = file * 8
  local h = rank * 8
  local base = {
    id = "base",
    layer = 2,
    position = { x = x, y = y },
    dimensions = { width = w, height = h },
    texture = {
      texture = "gui",
      position = { x = 0, y = 0 },
      dimensions = { width = 0, height = 0 },
    }
  }
  create_panel(base)

  set_origin(base.id, w / 2, 0)
  set_show_outline({id=base.id, show=true, color={r=255, g=255, b=255}})
  set_show_origin({id=base.id, show=true, color={r=0, g=0, b=0}})


  self.rank = rank
  self.file = file
  self.sprites = {}

  for yy = 0, rank - 1, 1 do
    for xx = 0, file - 1, 1 do
      local id = "sprite_" .. tostring(xx) .. "_" .. tostring(yy)
      local sprite_x = x - (base.dimensions.width / 2 - 4) + (xx * 8)
      local sprite_y = y + 4 + (yy * 8)
      local dx = sprite_x - x
      local dy = sprite_y - y
      local distance = math.sqrt(dx * dx + dy * dy)
      local angle = math.asin((sprite_x - x) / distance)
      if sprite_y > y then
        angle = math.pi - angle
      end
      if tostring(angle) == tostring(0/0) or tostring(angle) == tostring(-(0/0)) then
        angle = 0.0
      end

      local sprite = {
        id = id,
        layer = 3,
        position = { x = sprite_x, y = sprite_y, },
        dimensions = { width = 16, height = 16 },
        sprite = infantry_sprite
      }
      create_sprite(sprite)
      sprite_start_animation(id, "march_n", true)
      set_origin(id, 8, 16)
      self.sprites[id] = { distance = distance, angle = angle, }
    end
  end

end


local unit = {}







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


  unit = Unit:new()
  unit:create(100, 100, 2, 20)

  set_draw_entities_ordered_by_position(3, true)


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
  -- pan_game_view(delta_x, delta_y)


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
      -- print('animation: ' .. animation)
      -- sprite_start_animation("cavalry", animation, true)
      -- current_animation = animation
    end
  end
end

function on_input(event)
  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.F then
      -- sprite_start_animation("cavalry", "fire_s", false)
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
    local pos = get_game_mouse_position()
    print("mouse down: " .. tostring(event.button) .. ", x: " .. tostring(pos.x) .. ", y: " .. tostring(pos.y))
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

