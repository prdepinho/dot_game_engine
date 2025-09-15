
local rules = require "games.dungeon.rules"


local Character = {}

function Character:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Character:create(class)
  self.sprite = {
    head   = { x = 0, y = 0 },
    body   = { x = 0, y = 0 },
    weapon = { x = 0, y = 0 },
    shield = { x = 0, y = 0 }
  }
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
  self.weapon = {code = "", name = "unarmed",   type = "weapon"}
  self.armor  = {code = "", name = "unarmored", type = "armor"}
  self.shield = {code = "", name = "no_shield", type = "shield"}
  self.ammo   = {code = "", name = "no_ammo",   type = "ammo", quantity = 0}
  self.inventory = { 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
    {code = "", name = "no_item", type = "item"}, 
  }
  self.conditions = {}
end

function Character:equip_weapon(weapon_code)
  self.sprite.weapon = rules.weapon[weapon_code].sprite
  self.weapon.code = weapon_code
  self.weapon.name = rules.weapon[weapon_code].name
end

function Character:equip_armor(armor_code)
  self.sprite.armor = rules.armor[armor_code].sprite
  self.armor.code = armor_code
  self.armor.name = rules.armor[armor_code].name
end

function Character:equip_shield(shield_code)
  self.sprite.shield = rules.shield[shield_code].sprite
  self.shield.code = shield_code
  self.shield.name = rules.shield[shield_code].name
end

function Character:equip_ammo(ammo_code, quantity)
  self.ammo.code = ammo_code
  self.ammo.name = rules.ammo[ammo_code].name
  self.ammo.quantity = quantity
end

return Character
