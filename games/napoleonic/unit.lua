
local sprite_type = {

  small_infantry_sprite = {
    texture = "sprites",
    origin = { x = 128, y = 0 },
    dimensions = { height = 16, width = 16 },
    spacing = { front = 8, side = 8 },
    animations = {
      { key = "march_s",   fps = 5, frames = { { x = 0, y = 0 }, { x = 0, y = 1 } } },
      { key = "march_sw",  fps = 5, frames = { { x = 1, y = 0 }, { x = 1, y = 1 } } },
      { key = "march_w",   fps = 5, frames = { { x = 2, y = 0 }, { x = 2, y = 1 } } },
      { key = "march_nw",  fps = 5, frames = { { x = 3, y = 0 }, { x = 3, y = 1 } } },
      { key = "march_n",   fps = 5, frames = { { x = 4, y = 0 }, { x = 4, y = 1 } } },
      { key = "march_ne",  fps = 5, frames = { { x = 5, y = 0 }, { x = 5, y = 1 } } },
      { key = "march_e",   fps = 5, frames = { { x = 6, y = 0 }, { x = 6, y = 1 } } },
      { key = "march_se",  fps = 5, frames = { { x = 7, y = 0 }, { x = 7, y = 1 } } },
      { key = "fire_s",    fps = 3, frames = { function(id) end, { x = 0, y = 2 }, { x = 0, y = 0 }, } },
      { key = "fire_sw",   fps = 3, frames = { { x = 1, y = 2 } } },
      { key = "fire_w",    fps = 3, frames = { { x = 2, y = 2 } } },
      { key = "fire_nw",   fps = 3, frames = { { x = 3, y = 2 } } },
      { key = "fire_n",    fps = 3, frames = { { x = 4, y = 2 } } },
      { key = "fire_ne",   fps = 3, frames = { { x = 5, y = 2 } } },
      { key = "fire_e",    fps = 3, frames = { { x = 6, y = 2 } } },
      { key = "fire_se",   fps = 3, frames = { { x = 7, y = 2 } } },
      { key = "attack_s",  fps = 3, frames = { { x = 0, y = 3 }, { x = 0, y = 4 } } },
      { key = "attack_sw", fps = 3, frames = { { x = 1, y = 3 }, { x = 1, y = 4 } } },
      { key = "attack_w",  fps = 3, frames = { { x = 2, y = 3 }, { x = 2, y = 4 } } },
      { key = "attack_nw", fps = 3, frames = { { x = 3, y = 3 }, { x = 3, y = 4 } } },
      { key = "attack_n",  fps = 3, frames = { { x = 4, y = 3 }, { x = 4, y = 4 } } },
      { key = "attack_ne", fps = 3, frames = { { x = 5, y = 3 }, { x = 5, y = 4 } } },
      { key = "attack_e",  fps = 3, frames = { { x = 6, y = 3 }, { x = 6, y = 4 } } },
      { key = "attack_se", fps = 3, frames = { { x = 7, y = 3 }, { x = 7, y = 4 } } },
    }
  },

  small_cavalry_sprite = {
    texture = "sprites",
    origin = { x = 128, y = 80 },
    dimensions = { height = 24, width = 16 },
    spacing = { front = 16, side = 10 },
    animations = {
      { key = "march_s",   fps = 5, frames = { { x = 0, y = 0 }, { x = 0, y = 1 } } },
      { key = "march_sw",  fps = 5, frames = { { x = 1, y = 0 }, { x = 1, y = 1 } } },
      { key = "march_w",   fps = 5, frames = { { x = 2, y = 0 }, { x = 2, y = 1 } } },
      { key = "march_nw",  fps = 5, frames = { { x = 3, y = 0 }, { x = 3, y = 1 } } },
      { key = "march_n",   fps = 5, frames = { { x = 4, y = 0 }, { x = 4, y = 1 } } },
      { key = "march_ne",  fps = 5, frames = { { x = 5, y = 0 }, { x = 5, y = 1 } } },
      { key = "march_e",   fps = 5, frames = { { x = 6, y = 0 }, { x = 6, y = 1 } } },
      { key = "march_se",  fps = 5, frames = { { x = 7, y = 0 }, { x = 7, y = 1 } } },
      { key = "fire_s",    fps = 3, frames = { { x = 0, y = 0 }, { x = 0, y = 0 }, } },
      { key = "fire_sw",   fps = 3, frames = { { x = 1, y = 0 } } },
      { key = "fire_w",    fps = 3, frames = { { x = 2, y = 0 } } },
      { key = "fire_nw",   fps = 3, frames = { { x = 3, y = 0 } } },
      { key = "fire_n",    fps = 3, frames = { { x = 4, y = 0 } } },
      { key = "fire_ne",   fps = 3, frames = { { x = 5, y = 0 } } },
      { key = "fire_e",    fps = 3, frames = { { x = 6, y = 0 } } },
      { key = "fire_se",   fps = 3, frames = { { x = 7, y = 0 } } },
      { key = "attack_s",  fps = 3, frames = { { x = 0, y = 2 }, { x = 0, y = 3 } } },
      { key = "attack_sw", fps = 3, frames = { { x = 1, y = 2 }, { x = 1, y = 3 } } },
      { key = "attack_w",  fps = 3, frames = { { x = 2, y = 2 }, { x = 2, y = 3 } } },
      { key = "attack_nw", fps = 3, frames = { { x = 3, y = 2 }, { x = 3, y = 3 } } },
      { key = "attack_n",  fps = 3, frames = { { x = 4, y = 2 }, { x = 4, y = 3 } } },
      { key = "attack_ne", fps = 3, frames = { { x = 5, y = 2 }, { x = 5, y = 3 } } },
      { key = "attack_e",  fps = 3, frames = { { x = 6, y = 2 }, { x = 6, y = 3 } } },
      { key = "attack_se", fps = 3, frames = { { x = 7, y = 2 }, { x = 7, y = 3 } } },
    }
  },

  small_artillery_sprite = {
    texture = "sprites",
    origin = { x = 128, y = 176 },
    dimensions = { height = 16, width = 16 },
    spacing = { front = 8, side = 13 },
    animations = {
      { key = "march_s",   fps = 5, frames = { { x = 0, y = 0 }, { x = 0, y = 1 } } },
      { key = "march_sw",  fps = 5, frames = { { x = 1, y = 0 }, { x = 1, y = 1 } } },
      { key = "march_w",   fps = 5, frames = { { x = 2, y = 0 }, { x = 2, y = 1 } } },
      { key = "march_nw",  fps = 5, frames = { { x = 3, y = 0 }, { x = 3, y = 1 } } },
      { key = "march_n",   fps = 5, frames = { { x = 4, y = 0 }, { x = 4, y = 1 } } },
      { key = "march_ne",  fps = 5, frames = { { x = 5, y = 0 }, { x = 5, y = 1 } } },
      { key = "march_e",   fps = 5, frames = { { x = 6, y = 0 }, { x = 6, y = 1 } } },
      { key = "march_se",  fps = 5, frames = { { x = 7, y = 0 }, { x = 7, y = 1 } } },
      { key = "fire_s",    fps = 3, frames = { { x = 0, y = 0 }, { x = 0, y = 0 }, } },
      { key = "fire_sw",   fps = 3, frames = { { x = 1, y = 0 } } },
      { key = "fire_w",    fps = 3, frames = { { x = 2, y = 0 } } },
      { key = "fire_nw",   fps = 3, frames = { { x = 3, y = 0 } } },
      { key = "fire_n",    fps = 3, frames = { { x = 4, y = 0 } } },
      { key = "fire_ne",   fps = 3, frames = { { x = 5, y = 0 } } },
      { key = "fire_e",    fps = 3, frames = { { x = 6, y = 0 } } },
      { key = "fire_se",   fps = 3, frames = { { x = 7, y = 0 } } },
      { key = "attack_s",  fps = 3, frames = { { x = 0, y = 0 } } },
      { key = "attack_sw", fps = 3, frames = { { x = 1, y = 0 } } },
      { key = "attack_w",  fps = 3, frames = { { x = 2, y = 0 } } },
      { key = "attack_nw", fps = 3, frames = { { x = 3, y = 0 } } },
      { key = "attack_n",  fps = 3, frames = { { x = 4, y = 0 } } },
      { key = "attack_ne", fps = 3, frames = { { x = 5, y = 0 } } },
      { key = "attack_e",  fps = 3, frames = { { x = 6, y = 0 } } },
      { key = "attack_se", fps = 3, frames = { { x = 7, y = 0 } } },
    }
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

function Unit:create(unit_id, x, y, rank, file, layer, unit_type)
  self.sprite = sprite_type[unit_type]
  self.file = file
  self.rank = rank
  local w = file * self.sprite.spacing.side
  local h = rank * self.sprite.spacing.front
  self.unit_id = unit_id
  self.base = {
    id = "base_" .. unit_id,
    layer = layer-1,
    position = { x = x, y = y },
    dimensions = { width = w, height = h },
    texture = {
      texture = "gui",
      position = { x = 0, y = 0 },
      dimensions = { width = 0, height = 0 },
    }
  }
  create_panel(self.base)

  set_origin(self.base.id, w / 2, h / 2)
  -- set_show_outline({id=self.base.id, show=true, color={r=255, g=255, b=255}})
  -- set_show_origin({id=self.base.id, show=true, color={r=0, g=0, b=0}})


  self.rank = rank
  self.file = file
  self.sprites = {}

  for yy = 0, rank - 1, 1 do
    for xx = 0, file - 1, 1 do
      local id = "sprite_" .. unit_id .. "_" .. tostring(xx) .. "_" .. tostring(yy)
      local sprite_x = x - (self.base.dimensions.width / 2 - (self.sprite.spacing.side / 2)) + (xx * self.sprite.spacing.side)
      local sprite_y = y + (self.sprite.spacing.front / 2) + (yy * self.sprite.spacing.front) - (h / 2)
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
        layer = layer,
        position = { x = sprite_x, y = sprite_y, },
        dimensions = { width = self.sprite.dimensions.width, height = self.sprite.dimensions.height },
        sprite = self.sprite
      }
      create_sprite(sprite)
      -- set_show_outline({id = id, show = true, color = {r = 255, g = 255, b = 255, a = 255}})
      sprite_start_animation(id, "march_n", true)
      set_origin(id, sprite.dimensions.width / 2, sprite.dimensions.height)
      self.sprites[id] = { distance = distance, angle = angle, }
    end
  end

end

function Unit:rotate(angle)
  rotate_entity(self.base.id, angle)
  local rotation = get_rotation(self.base.id)
  local center = get_entity(self.base.id).position
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
  local rotation = get_rotation(self.base.id)
  local rads = math.rad(rotation)
  local dx = math.sin(rads) * delta
  local dy = math.cos(rads + math.pi) * delta
  move_entity(self.base.id, dx, dy)
  for k, v in pairs(self.sprites) do
    move_entity(k, dx, dy)
  end
end

function Unit:attack()
  local base_rotation = get_rotation(self.base.id)
  for k, v in pairs(self.sprites) do
    sprite_start_animation(k, "attack_" .. get_direction(base_rotation), true)
  end
end

function Unit:fire()
  local base_rotation = get_rotation(self.base.id)
  local base_direction = get_direction(base_rotation)

  for i = 0, self.file - 1, 1 do
    local id = 'sprite_' .. self.unit_id .. "_" .. tostring(i) .. '_0'
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
          { key = "smoke_loop", fps = 5, frames = { { x = 0, y = 4 }, { x = 1, y = 4 }, { x = 0, y = 4 }, { x = 1, y = 4 }, { x = 0, y = 4 }, function(id) remove_entity(id) end, { x = 1, y = 4 }, } },
          { key = "fire_s", fps = 3, frames = { { x = 0, y = 0 }, { x = 0, y = 1 }, } },
          { key = "fire_se", fps = 3, frames = { { x = 1, y = 0 }, { x = 1, y = 1 }, } },
          { key = "fire_e", fps = 3, frames = { { x = 2, y = 0 }, { x = 2, y = 1 }, } },
          { key = "fire_ne", fps = 3, frames = { { x = 3, y = 0 }, { x = 3, y = 1 }, } },
          { key = "fire_n", fps = 3, frames = { { x = 4, y = 0 }, { x = 4, y = 1 }, } },
          { key = "fire_nw", fps = 3, frames = { { x = 5, y = 0 }, { x = 5, y = 1 }, } },
          { key = "fire_w", fps = 3, frames = { { x = 6, y = 0 }, { x = 6, y = 1 }, } },
          { key = "fire_sw", fps = 3, frames = { { x = 7, y = 0 }, { x = 7, y = 1 }, } },
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


return Unit
