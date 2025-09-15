local unit_types = {
  line_infantry = {
    position = { x = 0, y = 0 },
    dimensions = { height = 6, width = 16 },
  },
  light_infantry = {
    position = { x = 16, y = 9 },
    dimensions = { height = 6, width = 16 },
  },
  guard_infantry = {
    position = { x = 16, y = 16 },
    dimensions = { height = 6, width = 16 },
  },
  artillery = {
    position = { x = 18, y = 0 },
    dimensions = { height = 5, width = 11 },
  },
  light_cavalry = {
    position = { x = 0, y = 7 },
    dimensions = { height = 8, width = 13 },
  },
  heavy_cavalry = {
    position = { x = 0, y = 16 },
    dimensions = { height = 8, width = 13 },
  },
}

local color_tokens = {
  blue_token = {
    texture = "sprites",
    origin = { x = 320, y = 32 },
    types = unit_types,
  },
  red_token = {
    texture = "sprites",
    origin = { x = 368, y = 32 },
    types = unit_types,
  },
  yellow_token = {
    texture = "sprites",
    origin = { x = 416, y = 32 },
    types = unit_types,
  },
  black_token = {
    texture = "sprites",
    origin = { x = 320, y = 64 },
    types = unit_types,
  },
  green_token = {
    texture = "sprites",
    origin = { x = 368, y = 64 },
    types = unit_types,
  },
}


local Token = {}

function Token:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Token:create(id, layer, color, token_type, x, y)
  local color_token = color_tokens[color .. '_token']
  local unit_type = color_token.types[token_type]
  self.panel = {
    id = id,
    layer = layer,
    position = { x = x, y = y },
    dimensions = {
      width = unit_type.dimensions.width,
      height = unit_type.dimensions.height
    },
    texture = {
      texture = color_token.texture,
      position = { 
        x = color_token.origin.x + unit_type.position.x,
        y = color_token.origin.y + unit_type.position.y,
      },
      dimensions = {
        width = unit_type.dimensions.width,
        height = unit_type.dimensions.height,
      },
    }
  }
  create_panel(self.panel)
  set_origin(self.panel.id, self.panel.dimensions.width / 2, self.panel.dimensions.height / 2)
end

function Token:rotate(angle)
  rotate_entity(self.panel.id, angle)
end

function Token:move(delta)
  local rads = math.rad(get_rotation(self.panel.id))
  local dx = math.sin(rads) * delta
  local dy = math.cos(rads + math.pi) * delta
  move_entity(self.panel.id, dx, dy)
end

function Token:fire()
  print('Token:fire() not implemented')
end

return Token
