
local Screen = require "games.dungeon.screen"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"
local Button = require "games.dungeon.button"
local Screen = require "games.dungeon.screen"
local TextField = require "games.dungeon.text_field"
local TextArea = require "games.dungeon.text_area"
local ColorPicker = require "games.dungeon.color_picker"
local resources = require "games.dungeon.resources"



local CharacterCreationScreen = {}
CharacterCreationScreen.__index = CharacterCreationScreen
setmetatable(CharacterCreationScreen, { __index = Screen })

function CharacterCreationScreen:new(o)
  o = o or {}
  setmetatable(o, self)
  return o
end

function CharacterCreationScreen:open(layer)
  Screen.open(self, layer)

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width
  local panel_height = screen_dimensions.height
  local panel_x = 0
  local panel_y = 0

  self.character = {}

  create_segmented_panel({
      id = "creation_window",
      gui = true,
      layer = self.layer,
      position = { x = panel_x, y = panel_y },
      dimensions = { width = panel_width, height = panel_height },
      texture = {
        texture = "gui",
        position = { x = 192, y = 0 },
        border_size = 4,
        interior = { width = 8, height = 8 },
      },
      on_input = function(event) 
        if event.type == "mouse_button_down" then
          return true
        elseif event.type == "mouse_button_up" then
          return true
        end
        return false
      end,
  })

  create_text_line({
    id = "creation_header",
    gui = true,
    layer = self.layer + 1,
    position = { x = 0, y = 0 },
    text = "Character creation",
    font = "gothic_font",
    color = { r = 0, g = 0, b = 0, a = 255 },
  })
  local header_entity = get_entity("creation_header")
  local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
  local header_y = 10
  set_position("creation_header", header_x, header_y)

  self.current_page = sex_page
  self.current_page.open(self)

end

function CharacterCreationScreen:change_page(next_page)
  self.next_page = next_page
end

function CharacterCreationScreen:loop(delta)
  if self.next_page ~= nil then
    self.current_page.close(self)
    self.current_page = self.next_page
    self.next_page = nil
    self.current_page.open(self)
  end
end

function CharacterCreationScreen:on_input(event)
end

function CharacterCreationScreen:delete()
  -- don't call parent's delete as we are deleting everything by hand
  if self.current_page ~= nil then
    self.current_page.close(self)
  end
  remove_entity("creation_window")
  remove_entity("creation_header")
end





sex_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Pick your sex")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local button_dimensions = {
      width = 50,
      height = 20
    }

    local y = 100
    local x = screen_dimensions.width / 2 - button_dimensions.width * 3 / 2

    screen.button_male = Button:new(screen, "creation_male")
    screen.button_male:create_with_label("Male", screen.layer+1, { x = x, y = y }, button_dimensions, function() 
      print("Male")
      screen.character.sex = "male"
      screen:change_page(class_page)
    end)
    screen:add_component(screen.button_male)

    screen.button_female = Button:new(screen, "creation_female")
    screen.button_female:create_with_label("Female", screen.layer+1, { x = x + button_dimensions.width * 2, y = y }, button_dimensions, function()
      print("Female")
      screen.character.sex = "female"
      screen:change_page(class_page)
    end)
    screen:add_component(screen.button_female)
  end,

  close = function(screen)
    screen:remove_component(screen.button_male)
    screen.button_male = nil
    screen:remove_component(screen.button_female)
    screen.button_female = nil
  end,
}


class_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Pick your class")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local classes = { 'cleric', 'fighter', 'magic_user', 'thief', 'dwarf', 'elf', 'halfling' }

    local i = 0
    local button_dimensions = {
      width = 70,
      height = 20
    }
    screen.class_buttons = {}
    for _,k in ipairs(classes) do
      local v = rules.class[k]
      local label = v.name
      local x = 10
      local y = 40 + i
      local button  = Button:new(screen, "class_button_" .. k)
      button:create_with_label(label, screen.layer+1, { x = x, y = y }, button_dimensions, function(event) 
        screen.character.class = k
        screen.class_description:set_text(v.desc)
      end)
      screen:add_component(button)
      table.insert(screen.class_buttons, button)
      i = i + 23
    end

    local x = screen_dimensions.width - 60
    local y = screen_dimensions.height - 30
    screen.class_confirm = Button:new(screen, "class_confirm_button")
    screen.class_confirm:create_with_label("Confirm", screen.layer+1, { x = x, y = y }, { width = 50, height = 20 }, function(event)
      if screen.character.class == nil then
        screen.class_description:set_text("Select a class")
      else
        screen:change_page(ability_page)
      end
    end)
    screen:add_component(screen.class_confirm)


    local desc_position = {
      x = 10 + button_dimensions.width + 10,
      y = 40
    }
    local desc_dimensions = {
      width = screen_dimensions.width - desc_position.x - 10,
      height = screen_dimensions.height - desc_position.y - 40
    }
    screen.class_description = TextArea:new(screen, "class_description_area")
    screen.class_description:create(screen.layer+1, desc_position, desc_dimensions)
    screen:add_component(screen.class_description)

  end,

  close = function(screen)
    for _,button in ipairs(screen.class_buttons) do
      screen:remove_component(button)
    end
    screen:remove_component(screen.class_confirm)
    screen.class_buttons = {}
    screen:remove_component(screen.class_description)
    screen.class_description = nil
  end,
}

ability_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Roll ability scores")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local abilities = { 'str', 'int', 'wis', 'dex', 'con', 'cha' }
    local plus_abilities = rules.class[screen.character.class].preferred_abilities
    local minus_abilities = { 'str', 'int', 'wis' }

    for i = #minus_abilities, 1, -1 do
      if table.contains(rules.class[screen.character.class].preferred_abilities, minus_abilities[i]) then
        table.remove(minus_abilities, i)
      end
    end

    screen.character.abilities = { str = 10, dex = 10, int = 10, con = 10, wis = 10, cha = 10 }
    screen.ability_points = 0

    local i = 0
    screen.ability_buttons = {}
    for i = 1, #abilities, 1 do

      local ability = abilities[i]
      local label = ability .. ":"
      local x = 10
      local y = 20 + i * 20

      if table.contains(minus_abilities, ability) then
        local minus_button  = Button:new(screen, "ability_minus_button_" .. ability)
        minus_button:create_with_label("-", screen.layer+1, { x = x, y = y }, { width = 16, height = 12 }, function(event) 
          print('minus ' .. tostring(ability))
          if screen.character.abilities[ability] > 9 then
            screen.character.abilities[ability] = screen.character.abilities[ability] - 1
            set_text("ability_label_value_" .. ability, screen.character.abilities[ability])
            screen.ability_points = screen.ability_points + 1
            set_text("ability_points", "points: " .. tostring(screen.ability_points))
          else
            print("cannot take")
          end
          screen.ability_description:set_text(rules.ability_score[ability].desc)
        end)
        screen:add_component(minus_button)
        table.insert(screen.ability_buttons, minus_button)
      end

      x = x + 22
      create_text_line({
        id = "ability_label_" .. ability,
        gui = true,
        layer = screen.layer + 1,
        position = { x = x, y = y },
        text = label,
        font = "small_font",
        color = { r = 0, g = 0, b = 0, a = 255 },
        on_input = function(event) 
          if event.type == 'mouse_button_down' then
            screen.ability_description:set_text(rules.ability_score[ability].desc)
            return true
          end
          return false
        end,
      })

      x = x + 24
      create_text_line({
        id = "ability_label_value_" .. ability,
        gui = true,
        layer = screen.layer + 1,
        position = { x = x, y = y },
        text = tostring(screen.character.abilities[ability]),
        font = "small_font",
        color = { r = 0, g = 0, b = 0, a = 255 },
        on_input = function(event) 
          if event.type == 'mouse_button_down' then
            screen.ability_description:set_text(rules.ability_score[ability].desc)
            return true
          end
          return false
        end,
      })

      x = x + 14
      if table.contains(plus_abilities, ability) then
        local plus_button  = Button:new(screen, "ability_plus_button_" .. ability)
        plus_button:create_with_label("+", screen.layer+1, { x = x, y = y }, { width = 16, height = 12 }, function(event) 
          print('plus ' .. tostring(ability))
          if screen.character.abilities[ability] < 18 and screen.ability_points > 1 then
            screen.character.abilities[ability] = screen.character.abilities[ability] + 1
            set_text("ability_label_value_" .. ability, screen.character.abilities[ability])
            screen.ability_points = screen.ability_points - 2
            set_text("ability_points", "points: " .. tostring(screen.ability_points))
          else
            print("cannot increase")
          end
          screen.ability_description:set_text(rules.ability_score[ability].desc)
        end)
        screen:add_component(plus_button)
        table.insert(screen.ability_buttons, plus_button)
      end

    end

    local x = screen_dimensions.width - 60
    local y = screen_dimensions.height - 30
    screen.ability_confirm = Button:new(screen, "ability_confirm_button")
    screen.ability_confirm:create_with_label("Confirm", screen.layer+1, { x = x, y = y }, { width = 50, height = 20 }, function(event)
      screen:change_page(alignment_page)
    end)
    screen:add_component(screen.ability_confirm)

    y = y - 30
    screen.ability_roll = Button:new(screen, "ability_roll_button")
    screen.ability_roll:create_with_label("Roll", screen.layer+1, { x = 10, y = y }, { width = 50, height = 20 }, function(event)
      local valid = false
      while valid == false do
        screen.character.abilities = { 
          str = rules.roll_dice("3d6"),
          dex = rules.roll_dice("3d6"),
          int = rules.roll_dice("3d6"),
          con = rules.roll_dice("3d6"),
          wis = rules.roll_dice("3d6"),
          cha = rules.roll_dice("3d6")
        }
        valid = true
        for k,v in pairs(screen.character.abilities) do
          valid = valid and rules.class[screen.character.class].minimum_ability[k] <= v
        end
        print("valid: " ..tostring(valid))
        for k,v in pairs(screen.character.abilities) do
          print("  " .. k .. ": " .. tostring(v))
        end
      end

      for k,v in pairs(screen.character.abilities) do
        set_text("ability_label_value_" .. k, tostring(v))
      end
      screen.ability_points = 0
      set_text("ability_points", "points: " .. tostring(screen.ability_points))
    end)
    screen:add_component(screen.ability_roll)

    local desc_position = {
      x = 10 + 70 + 10,
      y = 40
    }
    local desc_dimensions = {
      width = screen_dimensions.width - desc_position.x - 10,
      height = screen_dimensions.height - desc_position.y - 40
    }
    screen.ability_description = TextArea:new(screen, "ability_description_area")
    screen.ability_description:create(screen.layer+1, desc_position, desc_dimensions)
    screen:add_component(screen.ability_description)

    x = 10
    y = screen_dimensions.height - 80
    create_text_line({
      id = "ability_points",
      gui = true,
      layer = screen.layer + 1,
      position = { x = x, y = y },
      text = "points: " .. tostring(screen.ability_points),
      font = "small_font",
      color = { r = 0, g = 0, b = 0, a = 255 },
      on_input = function(event) 
        return false
      end,
    })

  end,

  close = function(screen)
    local abilities = { 'str', 'int', 'wis', 'dex', 'con', 'cha' }
    for i = 1, #abilities, 1 do
      local ability = abilities[i]
      remove_entity("ability_label_" .. ability)
      remove_entity("ability_label_value_" .. ability)
    end
    remove_entity("ability_points")
    for _,button in ipairs(screen.ability_buttons) do
      screen:remove_component(button)
    end
    screen.ability_buttons = {}
    screen:remove_component(screen.ability_confirm)
    screen.ability_confirm = nil
    screen:remove_component(screen.ability_roll)
    screen.ability_roll = nil
    screen:remove_component(screen.ability_description)
    screen.ability_description = nil
  end,
}

alignment_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Select your alignment")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local alignments = { 'order', 'neutrality', 'chaos' }

    local i = 0
    screen.alignment_buttons = {}
    for _,k in ipairs(alignments) do
      local v = rules.alignment[k]
      local label = v.name
      local x = 20
      local y = 50 + i
      local button  = Button:new(screen, "alignment_button_" .. k)
      button:create_with_label(label, screen.layer+1, { x = x, y = y }, { width = 60, height = 20 }, function(event) 
        screen.character.alignment = k
        screen.alignment_description:set_text(v.desc)
      end)
      screen:add_component(button)
      table.insert(screen.alignment_buttons, button)
      i = i + 25
    end

    local x = screen_dimensions.width - 60
    local y = screen_dimensions.height - 30
    screen.alignment_confirm = Button:new(screen, "creation_alignment_confirm_button")
    screen.alignment_confirm:create_with_label("Confirm", screen.layer+1, { x = x, y = y }, { width = 50, height = 20 }, function(event)
      if screen.character.alignment == nil then
        screen.alignment_description:set_text("Select an aligment")
      else
        screen:change_page(color_page)
      end
    end)
    screen:add_component(screen.alignment_confirm)


    local desc_position = {
      x = 10 + 70 + 10,
      y = 40
    }
    local desc_dimensions = {
      width = screen_dimensions.width - desc_position.x - 10,
      height = screen_dimensions.height - desc_position.y - 40
    }
    screen.alignment_description = TextArea:new(screen, "alignment_description_area")
    screen.alignment_description:create(screen.layer+1, desc_position, desc_dimensions)
    screen:add_component(screen.alignment_description)

  end,

  close = function(screen)
    for _,button in ipairs(screen.alignment_buttons) do
      screen:remove_component(button)
    end
    screen.ability_buttons = {}
    screen:remove_component(screen.alignment_confirm)
    screen.alignment_confirm = nil
    screen:remove_component(screen.alignment_description)
    screen.alignment_description = nil
  end,
}

color_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Pick your colors")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local x = screen_dimensions.width - 60
    local y = screen_dimensions.height - 30
    screen.color_confirm = Button:new(screen, "color_confirm_button")
    screen.color_confirm:create_with_label("Confirm", screen.layer+1, { x = x, y = y }, { width = 50, height = 20 }, function(event)
      screen:change_page(name_page)
    end)
    screen:add_component(screen.color_confirm)


    local sprite_dimensions = {
      width = 16 * 2,
      height = 16 * 2
    }
    local sprite_position = {
      x = screen_dimensions.width / 2 - sprite_dimensions.width / 2,
      y = screen_dimensions.height / 2 - sprite_dimensions.height / 2
    }
    create_layered_panel({
      id = "color_sprite",
      gui = true,
      layer = screen.layer + 1,
      position = sprite_position,
      dimensions = sprite_dimensions,
      layers = {
          { x = 0, y = 0, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = 0, y = 0, width = 0, height = 0 } },
          { x = 0, y = 0, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = 0, y = 0, width = 0, height = 0 } },
          { x = 0, y = 0, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = 0, y = 0, width = 0, height = 0 } },
          { x = 0, y = 0, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = 0, y = 0, width = 0, height = 0 } },
      },
      texture = "sprites",
      on_input = function(event) 
        return false
      end,
    })

    load_shader_fragment({
      id = "color_sprite",
      path = "games/dungeon/swap.frag"
    })

    screen.character.head = 1
    screen.character.colors = {
      primary   = { r = 0xbc, g = 0x86, b = 0x3d },
      secondary = { r = 0x8f, g = 0x0e, b = 0x2b },
      skin      = { r = 0xf2, g = 0xb7, b = 0x66 },
      eyes      = { r = 0x3a, g = 0x02, b = 0x36 },
    }

    color_page.update_sprite(screen.character, sprite_dimensions)
    color_page.update_sprite_colors(screen.character.colors)

    screen.color_picker_screen = ColorPicker:new()
    screen.color_picker_screen:open(screen.layer + 3, resources.colors)
    screen.color_picker_screen:set_visibility(false)

    local button_dimensions = {
      width = 80,
      height = 20
    }

    local x = sprite_position.x + sprite_dimensions.width / 2 - button_dimensions.width / 2
    local y = sprite_position.y - button_dimensions.height * 2 - 10
    screen.head_button = Button:new(screen, "color_head_button")
    screen.head_button:create_with_label("Swap head", screen.layer+1, { x = x, y = y }, button_dimensions, function (event)
      screen.character.head = screen.character.head % #rules.head + 1
      color_page.update_sprite(screen.character, sprite_dimensions)
      color_page.update_sprite_colors(screen.character.colors)
    end)
    screen:add_component(screen.head_button)

    x = sprite_position.x - 2 - button_dimensions.width
    y = sprite_position.y - 6 - button_dimensions.height
    screen.primary_button = Button:new(screen, "color_primary_button")
    screen.primary_button:create_with_label("Primary color", screen.layer+1, { x = x, y = y }, button_dimensions, function(event)
      screen.color_picker_screen.callback = function (color) 
        screen.color_picker_screen:set_visibility(false)
        screen.character.colors.primary = color
        color_page.update_sprite_colors(screen.character.colors)
      end
      screen.color_picker_screen:set_visibility(true)
    end)
    screen:add_component(screen.primary_button)

    x = sprite_position.x - 2 - button_dimensions.width
    y = sprite_position.y + 6 + sprite_dimensions.height
    screen.secondary_button = Button:new(screen, "color_secondary_button")
    screen.secondary_button:create_with_label("Secondary color", screen.layer+1, { x = x, y = y }, button_dimensions, function(event)
      screen.color_picker_screen.callback = function (color) 
        screen.color_picker_screen:set_visibility(false)
        screen.character.colors.secondary = color
        color_page.update_sprite_colors(screen.character.colors)
      end
      screen.color_picker_screen:set_visibility(true)
    end)
    screen:add_component(screen.secondary_button)

    x = sprite_position.x + 2 + sprite_dimensions.width
    y = sprite_position.y - 6 - button_dimensions.height
    screen.skin_button = Button:new(screen, "color_skin_button")
    screen.skin_button:create_with_label("Skin color", screen.layer+1, { x = x, y = y }, button_dimensions, function(event)
      screen.color_picker_screen.callback = function (color) 
        screen.color_picker_screen:set_visibility(false)
        screen.character.colors.skin = color
        color_page.update_sprite_colors(screen.character.colors)
      end
      screen.color_picker_screen:set_visibility(true)
    end)
    screen:add_component(screen.skin_button)

    x = sprite_position.x + 2 + sprite_dimensions.width
    y = sprite_position.y + 6 + sprite_dimensions.height
    screen.eyes_button = Button:new(screen, "color_eyes_button")
    screen.eyes_button:create_with_label("Eyes color", screen.layer+1, { x = x, y = y }, button_dimensions, function(event)
      screen.color_picker_screen.callback = function (color) 
        screen.color_picker_screen:set_visibility(false)
        screen.character.colors.eyes = color
        color_page.update_sprite_colors(screen.character.colors)
      end
      screen.color_picker_screen:set_visibility(true)
    end)
    screen:add_component(screen.eyes_button)

  end,

  update_sprite = function (character, sprite_dimensions)
    local weap = rules.weapon.unarmed
    local armr = rules.armor.unarmored
    local shld = rules.shield.no_shield
    local sex = rules.sex[character.sex]
    local class = rules.class[character.class]
    local head = rules.head[character.head]

    local sprite_body_x = sex.sprite.x + class.sprite.x + armr.sprite.x + weap.character_sprite.x
    local sprite_body_y = sex.sprite.y + class.sprite.y + armr.sprite.y + weap.character_sprite.y

    set_layered_panel_texture({
        id = "color_sprite",
        layers = {
            { x = 0, y = 16 - class.sprite.height, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = head.sprite.x, y = head.sprite.y, width = 16, height = 16 } },
            { x = 0, y = 0,                        width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = sprite_body_x, y = sprite_body_y, width = 16, height = 16 } },
            { x = 0, y = 16 - class.sprite.height, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = weap.sprite.x, y = weap.sprite.y, width = 16, height = 16 } },
            { x = 0, y = 16 - class.sprite.height, width = sprite_dimensions.width, height = sprite_dimensions.height, texture = { x = shld.sprite.x, y = shld.sprite.y, width = 16, height = 16 } },
        },
        texture = "sprites",
    })
  end,

  update_sprite_colors = function (colors)
    set_shader_uniform({
      id = "color_sprite",
      uniforms = {
        { key = "texture",      type = "texture", value = "sprites" },
        { key = "oldColors[0]", type = "vec4",    value = { x = 0xbc/255.0, y = 0x86/255.0, z = 0x3d/255.0, w = 1.0 } }, -- bc863d light brown
        { key = "oldColors[1]", type = "vec4",    value = { x = 0x8f/255.0, y = 0x0e/255.0, z = 0x2b/255.0, w = 1.0 } }, -- 8f0e2b dark brown
        { key = "oldColors[2]", type = "vec4",    value = { x = 0xf2/255.0, y = 0xb7/255.0, z = 0x66/255.0, w = 1.0 } }, -- f2b766 skin
        { key = "oldColors[3]", type = "vec4",    value = { x = 0x6b/255.0, y = 0x21/255.0, z = 0x79/255.0, w = 1.0 } }, -- 6b2179 eyes
        { key = "newColors[0]", type = "vec4",    value = { x =   colors.primary.r/255.0,   y = colors.primary.g/255.0,   z = colors.primary.b/255.0, w = 1.0 } },
        { key = "newColors[1]", type = "vec4",    value = { x = colors.secondary.r/255.0, y = colors.secondary.g/255.0, z = colors.secondary.b/255.0, w = 1.0 } },
        { key = "newColors[2]", type = "vec4",    value = { x =      colors.skin.r/255.0,      y = colors.skin.g/255.0,      z = colors.skin.b/255.0, w = 1.0 } },
        { key = "newColors[3]", type = "vec4",    value = { x =      colors.eyes.r/255.0,      y = colors.eyes.g/255.0,      z = colors.eyes.b/255.0, w = 1.0 } },
      }
    })
  end,

  close = function(screen)
    screen.color_picker_screen:delete()
    screen:remove_component(screen.head_button)
    screen.head_button = nil
    screen:remove_component(screen.primary_button)
    screen.primary_button = nil
    screen:remove_component(screen.secondary_button)
    screen.secondary_button = nil
    screen:remove_component(screen.skin_button)
    screen.skin_button = nil
    screen:remove_component(screen.eyes_button)
    screen.eyes_button = nil
    screen:remove_component(screen.color_confirm)
    screen.color_confirm = nil
    remove_entity("color_sprite")
  end,
}

name_page = {
  open = function(screen)
    local screen_dimensions = get_screen_dimensions()
    set_text("creation_header", "Input your name")
    local header_entity = get_entity("creation_header")
    local header_x = screen_dimensions.width / 2 - header_entity.dimensions.width / 2
    local header_y = header_entity.position.y
    set_position("creation_header", header_x, header_y)

    local x = screen_dimensions.width - 60
    local y = screen_dimensions.height - 30
    screen.name_confirm = Button:new(screen, "name_confirm_button")
    screen.name_confirm:create_with_label("Confirm", screen.layer+1, { x = x, y = y }, { width = 50, height = 20 }, function(event)
      screen.character.name = screen.name_field.text
      print("sex: " .. screen.character.sex)
      print("class: " .. screen.character.class)
      print("alignment: " .. screen.character.alignment)
      print("name: " .. screen.character.name)
    end)
    screen:add_component(screen.name_confirm)


    x = screen_dimensions.width / 2 - 100 / 2
    y = screen_dimensions.height / 2 - 10
    screen.name_field = TextField:new(screen, "name_field")
    screen.name_field:create(screen.layer+1, { x = x, y = y }, 100)
    screen:add_component(screen.name_field)

    screen.name_field.callback = function(unicode)
      if unicode == 0x0D then  -- CR
        screen.character.name = screen.name_field.text
        print("sex: " .. screen.character.sex)
        print("class: " .. screen.character.class)
        print("alignment: " .. screen.character.alignment)
        print("name: " .. screen.character.name)
      end
    end
  end,

  close = function(screen)
    screen:remove_component(screen.name_confirm)
    screen.ability_buttons = {}
    screen:remove_component(screen.name_field)
    screen.name_field = nil
  end,
}

return CharacterCreationScreen

