
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

local cavalry_sprite = {
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
  local sprite = cavalry_sprite
  local front_spacing = sprite.dimensions.height / 2
  local side_spacing = sprite.dimensions.width / 2
  local w = file * sprite.dimensions.width / 2
  local h = rank * sprite.dimensions.height / 2
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

  set_origin(base.id, w / 2, h / 2)
  set_show_outline({id=base.id, show=true, color={r=255, g=255, b=255}})
  set_show_origin({id=base.id, show=true, color={r=0, g=0, b=0}})


  self.rank = rank
  self.file = file
  self.sprites = {}

  for yy = 0, rank - 1, 1 do
    for xx = 0, file - 1, 1 do
      local id = "sprite_" .. tostring(xx) .. "_" .. tostring(yy)
      local sprite_x = x - (base.dimensions.width / 2 - (side_spacing / 2)) + (xx * side_spacing)
      local sprite_y = y + (front_spacing / 2) + (yy * front_spacing) - (h / 2)
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
        dimensions = { width = sprite.dimensions.width, height = sprite.dimensions.height },
        sprite = sprite
      }
      create_sprite(sprite)
      sprite_start_animation(id, "march_n", true)
      set_origin(id, sprite.dimensions.width / 2, sprite.dimensions.height)
      self.sprites[id] = { distance = distance, angle = angle, }
    end
  end

end

return Unit
