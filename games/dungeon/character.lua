
local rules = require "games.dungeon.rules"


local Character = {}

function Character:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Character:create(name, class, sex)
  self.name = name
  self.sprite = name.."_sprite"
  self.sex = sex
  self.head = rules.head[1]
  self.class = class
  self.level = 0
  self.abilities = {
    str = 10,
    dex = 10,
    con = 10,
    int = 10,
    wis = 10,
    cha = 10
  }
  self.hit_points = {
    current = 0,
    total   = 0
  }
  self.armor_class = 0
  self.experience = {
    current    = 0,
    next_level = 0
  }
  self.saving_throws = {
    death    = 0,
    wands    = 0,
    paralize = 0,
    breath   = 0,
    spell    = 0
  }
  self.weapon = {code = "unarmed",   name = "unarmed",   type = "weapon"}
  self.armor  = {code = "unarmored", name = "unarmored", type = "armor"}
  self.shield = {code = "no_shield", name = "no_shield", type = "shield"}
  self.ammo   = {code = "no_ammo",   name = "no_ammo",   type = "ammo", quantity = 0}
  self.inventory = { 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
    {code = "no_item", name = "no_item", type = "item"}, 
  }
  self.conditions = {}

  create_layered_panel({
    id = self.sprite,
    gui = false,
    layer = 1,
    position = { x = 0, y = 0 },
    dimensions = { width = 16, height = 16 },
    layers = {
        { x = 0, y = 0, width = 16, height = 16, texture = { x = 0, y = 0, width = 0, height = 0 } },
        { x = 0, y = 0, width = 16, height = 16, texture = { x = 0, y = 0, width = 0, height = 0 } },
        { x = 0, y = 0, width = 16, height = 16, texture = { x = 0, y = 0, width = 0, height = 0 } },
        { x = 0, y = 0, width = 16, height = 16, texture = { x = 0, y = 0, width = 0, height = 0 } },
    },
    texture = "sprites",
    on_input = function(event) 
      return false
    end,
  })
end

function Character:set_sprite()
  local weap = rules.weapon[self.weapon.code]
  local armr = rules.armor[self.armor.code]
  local shld = rules.shield[self.shield.code]

  local sprite_body_x = self.sex.sprite.x + self.class.sprite.x + armr.sprite.x + weap.character_sprite.x
  local sprite_body_y = self.sex.sprite.y + self.class.sprite.y + armr.sprite.y + weap.character_sprite.y

  set_layered_panel_texture({
      id = self.sprite,
      layers = {
          { x = 0, y = 16 - self.class.sprite.height, width = 16, height = 16, texture = { x = self.head.sprite.x, y = self.head.sprite.y, width = 16, height = 16 } },
          { x = 0, y = 0,                             width = 16, height = 16, texture = { x = sprite_body_x,      y = sprite_body_y,      width = 16, height = 16 } },
          { x = 0, y = 16 - self.class.sprite.height, width = 16, height = 16, texture = { x = weap.sprite.x,      y = weap.sprite.y,      width = 16, height = 16 } },
          { x = 0, y = 16 - self.class.sprite.height, width = 16, height = 16, texture = { x = shld.sprite.x,      y = shld.sprite.y,      width = 16, height = 16 } },
      },
      texture = "sprites",
  })
end

function Character:set_position(pix_x, pix_y)
  set_position(self.sprite, pix_x, pix_y)
end

function Character:equip_weapon(weapon_code)
  self.weapon.code = weapon_code
  self.weapon.name = rules.weapon[weapon_code].name
end

function Character:equip_armor(armor_code)
  self.armor.code = armor_code
  self.armor.name = rules.armor[armor_code].name
end

function Character:equip_shield(shield_code)
  self.shield.code = shield_code
  self.shield.name = rules.shield[shield_code].name
end

function Character:equip_ammo(ammo_code, quantity)
  self.ammo.code = ammo_code
  self.ammo.name = rules.ammo[ammo_code].name
  self.ammo.quantity = quantity
end

return Character
