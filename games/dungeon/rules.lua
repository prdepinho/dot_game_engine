
local rules = {}

function rules.roll_dice(formula)
  -- find the 'd' symbol (necessary) and the operator '+' or '-' symbols (optional, default is 1)
  d = formula:find('d')
  operator = formula:find('[+-]')

  quantity = 1
  faces = 1
  sum = 0

  -- dice quantity (optional)
  quantity = tonumber(formula:sub(0, d-1))
  if quantity == nil or quantity <= 0 then
    quantity = 1
  end

  -- faces in dice (necessary)
  if operator ~= nil then
    faces = tonumber(formula:sub(d+1, operator-1))

    -- sum (optional, it is there only if there is a '+' or '-' operator)
    if formula:sub(operator, operator) == '+' then
      sum = tonumber(formula:sub(operator+1, formula:len()))
    elseif formula:sub(operator, operator) == '-' then
      sum = tonumber(formula:sub(operator, formula:len()))
    end

  else
    faces = tonumber(formula:sub(d+1, formula:len()))
  end

  local result = 0
  for i = 1, quantity do
    local die = math.random(1, faces)
    result = result + die
  end
  return result + sum
end

rules.armor = {
  unarmored       = { name = "Unarmored",      ac = 9, icon = { x = 0, y = 0 }, sprite = { x = 16*0, y = 16*0 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "" },
  padded_armor    = { name = "Padded Armor",   ac = 7, icon = { x = 0, y = 0 }, sprite = { x = 16*0, y = 16*1 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "Textile armor made of multiple layers of linen. A gambeson." },
  chain_mail      = { name = "Chain Mail",     ac = 5, icon = { x = 0, y = 0 }, sprite = { x = 16*0, y = 16*2 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = false }, desc = "Riveted chain armor worn over padding." },
  plate_mail      = { name = "Plate Mail",     ac = 3, icon = { x = 0, y = 0 }, sprite = { x = 16*0, y = 16*3 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = false }, desc = "Steel cuirass or plates attached to a textile or leather cover." },
  suit_armor      = { name = "Suit of Armor",  ac = 1, icon = { x = 0, y = 0 }, sprite = { x = 16*0, y = 16*3 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = false }, desc = "Complete steel knightly armor." },
}

rules.shield = {
  no_shield       = { name = "No Shield",      ac_bonus = 0, icon = { x = 0, y = 0 }, sprite = { x = 16*0,  y = 16*0  }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "" },
  heater_shield   = { name = "Heater Shield",  ac_bonus = 1, icon = { x = 0, y = 0 }, sprite = { x = 16*24, y = 16*28 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = false }, desc = "Diamond shaped shield, light and easy to carry." },
  round_shield    = { name = "Round Shield",   ac_bonus = 1, icon = { x = 0, y = 0 }, sprite = { x = 16*25, y = 16*28 }, classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = false }, desc = "Round shaped shield, light and easy to carry." },
}

rules.weapon = {
  unarmed         = { name = "Unarmed",          damage = "1d1",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 0,    y = 0    }, sprite = { x = 0,     y = 0     }, character_sprite = { x = 16*1, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "" },
  hand_axe        = { name = "Hand Axe",         damage = "1d6",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*24, y = 16*26 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "A one handed bladed weapon." },
  battle_axe      = { name = "Battle Axe",       damage = "1d8",    to_hit_bonus = 0, hands = 2, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*25, y = 16*26 }, character_sprite = { x = 16*3, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A two handed bladed weapon." },
  long_bow        = { name = "Long Bow",         damage = "1d8",    to_hit_bonus = 0, hands = 2, ranged = true,  range = 6, ammo_category = "arrow",  cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*26, y = 16*26 }, character_sprite = { x = 16*0, y = 0 }, effect = "",       classes = { cleric = false, dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A powerful ranged weapon." },
  short_bow       = { name = "Short Bow",        damage = "1d6",    to_hit_bonus = 0, hands = 2, ranged = true,  range = 6, ammo_category = "arrow",  cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*27, y = 16*26 }, character_sprite = { x = 16*0, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "A ranged weapon" },
  club            = { name = "Club",             damage = "1d4",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*28, y = 16*26 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "A simple bludgeon made of wood." },
  crossbow        = { name = "Crossbow",         damage = "1d10",   to_hit_bonus = 0, hands = 2, ranged = true,  range = 6, ammo_category = "bolt",   cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*29, y = 16*26 }, character_sprite = { x = 16*3, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "A powerful ranged weapon that is easy to use." },
  dagger          = { name = "Dagger",           damage = "1d4",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = true,  icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*30, y = 16*26 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "A small blade." },
  silver_dagger   = { name = "Silver Dagger",    damage = "1d4",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = true,  icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*30, y = 16*26 }, character_sprite = { x = 16*2, y = 0 }, effect = "silver", classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "A dagger made of silver." },
  mace            = { name = "Mace",             damage = "1d6",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*31, y = 16*26 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A steel bludgeon with knobs." },
  polearm         = { name = "Polearm",          damage = "1d10",   to_hit_bonus = 0, hands = 2, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*24, y = 16*27 }, character_sprite = { x = 16*3, y = 0 }, effect = "",       classes = { cleric = false, dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A halberd or a poleaxe, a powerful two handed weapon." },
  sling           = { name = "Sling",            damage = "1d4",    to_hit_bonus = 0, hands = 2, ranged = true,  range = 6, ammo_category = "bullet", cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*25, y = 16*27 }, character_sprite = { x = 16*1, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = true,  thief = true  }, desc = "A simple ranged weapon that is easy to use." },
  spear           = { name = "Spear",            damage = "1d6",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*26, y = 16*27 }, character_sprite = { x = 16*3, y = 0 }, effect = "",       classes = { cleric = false, dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A long thrusting weapon." },
  staff           = { name = "Staff",            damage = "1d6",    to_hit_bonus = 0, hands = 2, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*27, y = 16*27 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = true,  thief = true  }, desc = "A wooden staff." },
  arming_sword    = { name = "Arming Sword",     damage = "1d8",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*28, y = 16*27 }, character_sprite = { x = 16*1, y = 0 }, effect = "",       classes = { cleric = false, dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A knighly sword used as a side arm." },
  short_sword     = { name = "Short Sword",      damage = "1d6",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*29, y = 16*27 }, character_sprite = { x = 16*1, y = 0 }, effect = "",       classes = { cleric = false, dwarf = true,  elf = true,  fighter = true,  halfling = true,  magic_user = false, thief = true  }, desc = "A short sword." },
  long_sword      = { name = "Long Sword",       damage = "1d10",   to_hit_bonus = 0, hands = 2, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*30, y = 16*27 }, character_sprite = { x = 16*3, y = 0 }, effect = "",       classes = { cleric = false, dwarf = false, elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A long knighly sword." },
  war_hammer      = { name = "War Hammer",       damage = "1d6",    to_hit_bonus = 0, hands = 1, ranged = false, range = 1, ammo_category = "",       cutthroat = false, icon = { x = 16*0, y = 16*0 }, sprite = { x = 16*31, y = 16*27 }, character_sprite = { x = 16*2, y = 0 }, effect = "",       classes = { cleric = true,  dwarf = true,  elf = true,  fighter = true,  halfling = false, magic_user = false, thief = false }, desc = "A hammer with a spike at the other end." },
}

rules.ammo = {
  no_ammo         = { name = "No ammo",       category = "",        damage_bonus = 0, range_bonus = 0, stack_capacity = 60, icon = {x = 16*0, y = 16*0}, sprite = { x = 0,     y = 0     }, projectile_effect = "",       quantity = 0, desc = "" },
  arrow           = { name = "Arrow",         category = "arrow",   damage_bonus = 0, range_bonus = 0, stack_capacity = 60, icon = {x = 16*0, y = 16*0}, sprite = { x = 16*25, y = 16*27 }, projectile_effect = "arrow",  quantity = 0, desc = "Arrows for bows." },
  bolt            = { name = "Bolt",          category = "bolt",    damage_bonus = 0, range_bonus = 0, stack_capacity = 60, icon = {x = 16*0, y = 16*0}, sprite = { x = 16*26, y = 16*27 }, projectile_effect = "bolt",   quantity = 0, desc = "Crossbow bolts." },
  bullet          = { name = "Sling Bullet",  category = "bullet",  damage_bonus = 0, range_bonus = 0, stack_capacity = 60, icon = {x = 16*0, y = 16*0}, sprite = { x = 16*27, y = 16*27 }, projectile_effect = "bullet", quantity = 0, desc = "Bullets for the sling." },
}

rules.item = {
  no_item         = { name = "No item",        icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  money           = { name = "Money",          icon = { x = 16*0, y = 16*0 },   stack_capacity = 124,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Copper coins." },
  backpack        = { name = "Backpack",       icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Holds 400cn" },
  bedroll         = { name = "Bedroll",        icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Bedroll and clothes for hot climate." },
  winter_bedroll  = { name = "Winter Bedroll", icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Bedroll and clothes for cold climate." },
  codex           = { name = "Codex",          icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Codex of 8 skins in quarto format, 64 pages, bound in leather." },
  flask_oil       = { name = "Flask of Oil",   icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Flask of 12oz of oil." },
  garlic          = { name = "Garlic",         icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Three cloves of garlic." },
  grappling_hook  = { name = "Grappling Hook", icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  hammer          = { name = "Hammer",         icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  holy_symbol     = { name = "Holy Symbol",    icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  holy_water      = { name = "Holy Water",     icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Flask of 1oz of holy water." },
  ink_and_quill   = { name = "Ink and Quill",  icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Vial of 1oz of ink, a quill and tools for writing." },
  iron_spikes     = { name = "Iron Spikes",    icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "A dozen iron spikes." },
  lantern         = { name = "Lantern",        icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Light 30' radius, for 2 turns per 1oz of oil." },
  lock_and_key    = { name = "Lock and Key",   icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  parchment       = { name = "Parchment",      icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "One animal skin, 4 spell scrolls." },
  mirror          = { name = "Mirror",         icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Hand steel mirror." },
  iron_rations    = { name = "Iron Rations",   icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Preserved rations, 1 person per week." },
  rations         = { name = "Rations",        icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Unpreserved rations, 1 person per week." },
  rope            = { name = "Rope",           icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "50' of rope." },
  small_sack      = { name = "Small Sack",     icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Holds 200cn." },
  large_sack      = { name = "Large Sack",     icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Holds 600cn." },
  shovel          = { name = "Shovel",         icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  scroll          = { name = "Scroll",         icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "One skin, 8 pages." },
  thieves_tools   = { name = "Thieves' Tools", icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  tinder_box      = { name = "Tinder Box",     icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  torch           = { name = "Torch",          icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Light 30' radius, for 6 turns." },
  water_skin      = { name = "Water Skin",     icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Two pints of water." },
  wine_skin       = { name = "Wine Skin",      icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "Two pints of wine." },
  wooden_stake    = { name = "Wooden Stake",   icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "" },
  wolfsbane       = { name = "Wolfsbane",      icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "One bunch." },
  pole            = { name = "Pole",           icon = { x = 16*0, y = 16*0 },   stack_capacity = nil,   range_radius = 0, effect_radius = 0, usable = false, use = "", quantity = 0,          desc = "10' long." },
}

rules.ability_modifier = {
  --  ability score:            3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18
  experience      = { 0, 0, 0,-10,-10,-10, -5, -5, -5,  0,  0,  0,  0,  5,  5,  5, 10, 10, 10 },  -- preferred ability
  to_hit          = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- str
  to_damage       = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- str
  force_doors     = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- str
  armor_class     = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- dex
  missile_to_hit  = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- dex
  initiative      = { 0, 0, 0, -2, -1, -1, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  1,  1,  2 },  -- dex
  hit_points      = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- con
  languages       = { 0, 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- int
  literacy        = { 0, 0, 0,  0,  0,  0,  0,  0,  0,  1,  1,  1,  1,  3,  3,  3,  3,  3,  3 },  -- int - 0: illiterate, 1: can read, 3: can read and write
  save_vs_spells  = { 0, 0, 0, -3, -2, -2, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  2,  2,  3 },  -- wis
  reaction        = { 0, 0, 0, -2, -1, -1, -1, -1, -1,  0,  0,  0,  0,  1,  1,  1,  1,  1,  2 },  -- cha
  retainers       = { 0, 0, 0,  1,  2,  2,  3,  3,  3,  4,  4,  4,  4,  5,  5,  5,  6,  6,  7 },  -- cha
  retainer_morale = { 0, 0, 0,  4,  5,  5,  6,  6,  6,  7,  7,  7,  7,  8,  8,  8,  9,  9, 10 }   -- cha
}

rules.head = {
  { sprite = { x = 16*0, y = 16*25 } },
  { sprite = { x = 16*1, y = 16*25 } },
  { sprite = { x = 16*2, y = 16*25 } },
  { sprite = { x = 16*3, y = 16*25 } },
  { sprite = { x = 16*4, y = 16*25 } },
  { sprite = { x = 16*5, y = 16*25 } },
  { sprite = { x = 16*6, y = 16*25 } },
  { sprite = { x = 16*7, y = 16*25 } },
  { sprite = { x = 16*8, y = 16*25 } },
  { sprite = { x = 16*9, y = 16*25 } },

  { sprite = { x = 16*0, y = 16*26 } },
  { sprite = { x = 16*1, y = 16*26 } },
  { sprite = { x = 16*2, y = 16*26 } },
  { sprite = { x = 16*3, y = 16*26 } },
  { sprite = { x = 16*4, y = 16*26 } },
  { sprite = { x = 16*6, y = 16*26 } },
  { sprite = { x = 16*7, y = 16*26 } },

  { sprite = { x = 16*0, y = 16*27 } },
  { sprite = { x = 16*1, y = 16*27 } },
  { sprite = { x = 16*2, y = 16*27 } },
  { sprite = { x = 16*3, y = 16*27 } },
  { sprite = { x = 16*6, y = 16*27 } },
  { sprite = { x = 16*7, y = 16*27 } },
  { sprite = { x = 16*8, y = 16*27 } },
  { sprite = { x = 16*9, y = 16*27 } },

  { sprite = { x = 16*6, y = 16*28 } },
  { sprite = { x = 16*7, y = 16*28 } },
}

rules.sex = {
  male   = { name = "male",   sprite = { x = 0,  y = 0 } },
  female = { name = "female", sprite = { x = 80, y = 0 } },
}

rules.class = {
  cleric = {
    name = "cleric",
    sprite = { x = 0, y = 0, height = 16 },
    preferred_abilities = { "wis" },
    minimum_ability = { str = 3, dex = 3, con = 3, int = 3, wis = 3, cha = 3 },
    experience = 1500,
    hit_die = 6,
    hp_increment = 1,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 4,
    saving_throws = {
      death =     11,
      wands =     12,
      paralize =  14,
      breath =    16,
      spell =     15
    },
    saving_throws_progression = {
      death =     3,
      wands =     2,
      paralize =  2,
      breath =    2,
      spell =     3
    }
    -- 
  },
  dwarf = {
    name = "dwarf",
    sprite = { x = 0, y = 256, height = 14 },
    preferred_abilities = { "str" },
    minimum_ability = { str = 3, dex = 3, con = 9, int = 3, wis = 3, cha = 3 },
    experience = 2250,
    hit_die = 10,
    hp_increment = 3,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 3,
    saving_throws = {
      death =     8,
      wands =     9,
      paralize =  10,
      breath =    13,
      spell =     12
    },
    saving_throws_progression = {
      death =     2,
      wands =     2,
      paralize =  2,
      breath =    3,
      spell =     2
    }
    -- heatvision
    -- 2 out of 6 to find traps, secrets and slopes in rocks, caves or stone buildings.
    -- languages: common, dwarf, goblin, gnome, kobold
    -- max level 12
  },
  elf = {
    name = "elf",
    sprite = { x = 0, y = 192, height = 15 },
    preferred_abilities = { "str", "int" },
    minimum_ability = { str = 3, dex = 3, con = 3, int = 9, wis = 3, cha = 3 },
    experience = 4000,
    hit_die = 6,
    hp_increment = 2,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 3,
    saving_throws = {
      death =     12,
      wands =     13,
      paralize =  13,
      breath =    15,
      spell =     15
    },
    saving_throws_progression = {
      death =     2,
      wands =     2,
      paralize =  2,
      breath =    3,
      spell =     2
    }
    -- heatvision
    -- detect secrets
    -- starting spell: read magic
    -- immune to paralysis from ghasts and ghouls
    -- languages: elvish, gnoll, hobgoblin and gnoll
    -- max level 10
  },
  fighter = {
    name = "fighter",
    sprite = { x = 0, y = 64, height = 16 },
    preferred_abilities = { "str" },
    minimum_ability = { str = 3, dex = 3, con = 3, int = 3, wis = 3, cha = 3 },
    experience = 2000,
    hit_die = 8,
    hp_increment = 2,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 3,
    saving_throws = {
      death =     12,
      wands =     13,
      paralize =  14,
      breath =    15,
      spell =     16
    },
    saving_throws_progression = {
      death =     2,
      wands =     2,
      paralize =  2,
      breath =    2,
      spell =     2
    }
  },
  halfling = {
    name = "halfling",
    sprite = { x = 0, y = 320, height = 13 },
    preferred_abilities = { "str", "dex" },
    minimum_ability = { str = 3, dex = 9, con = 9, int = 3, wis = 3, cha = 3 },
    experience = 2000,
    hit_die = 6,
    hp_increment = 1,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 3,
    saving_throws = {
      death =     8,
      wands =     9,
      paralize =  10,
      breath =    13,
      spell =     12
    },
    saving_throws_progression = {
      death =     2,
      wands =     2,
      paralize =  2,
      breath =    3,
      spell =     2
    }
    -- +1 to missile weapons and to initiative
    -- outdoors -> 90% move silently
    -- indoors -> 33% move silently
    -- -2 to hit by creatures larger than human sized
    -- max level 8
  },
  magic_user = {
    name = "magic_user",
    sprite = { x = 0, y = 128, height = 16 },
    preferred_abilities = { "int" },
    minimum_ability = { str = 3, dex = 3, con = 3, int = 3, wis = 3, cha = 3 },
    experience = 2500,
    hit_die = 4,
    hp_increment = 1,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 5,
    saving_throws = {
      death =     13,
      wands =     13,
      paralize =  13,
      breath =    16,
      spell =     14
    },
    saving_throws_progression = {
      death =     2,
      wands =     3,
      paralize =  2,
      breath =    2,
      spell =     2
    }
    -- starts with read magic
  },
  thief = {
    name = "thief",
    sprite = { x = 0, y = 160, height = 16 },
    preferred_abilities = { "dex" },
    minimum_ability = { str = 3, dex = 3, con = 3, int = 3, wis = 3, cha = 3 },
    experience = 1250,
    hit_die = 4,
    hp_increment = 2,
    thac0 = 19,
    thac0_propression = 2,
    level_progression = 4,
    saving_throws = {
      death =     14,
      wands =     15,
      paralize =  13,
      breath =    16,
      spell =     14
    },
    saving_throws_progression = {
      death =     2,
      wands =     2,
      paralize =  2,
      breath =    2,
      spell =     2
    },
    thief_skills = {
      open_locks =        15,
      find_remove_traps = 10,
      climb_wall =        50,
      move_silently =     20,
      hide_in_shadows =   10,
      pick_pockets =      20,
      hear_noise =        30,
      use_magic_scrolls = 0,
      read_language =     0
    },
    thief_skills_progression = 30
    -- backstab: with a dagger -> +4 to hit, d12 damage
    -- Level 4: read language 80%
    -- Level 10: use magic scrolls 90%
  }
}


function rules.experience_for_level(class, level)
  if level <= 9 then
    return rules.class[class].experience * 2 ^ (level - 2)
  else
    local step = rules.class[class].experience * 2 ^ (8 - 2)
    return (rules.class[class].experience * 2 ^ (9 - 2)) + step * (level - 9)
  end
end


return rules
