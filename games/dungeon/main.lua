
local Resources = require "games.dungeon.resources"
local Input = require "games.dungeon.input"
local Dialog = require "games.dungeon.dialog"
local Token = require "games.dungeon.token"
local Character = require "games.dungeon.character"
local rules = require "games.dungeon.rules"


local wheel_down = false
local mouse_position = { x = 0, y = 0 }
local tile_cursor = { x = 0, y = 0 }

local characters = {}
local selected_character = nil


local head_index = 1
local class_index = 1
local weapon_index = 1
local shield_index = 1
local armor_index = 1

local class_list = {}
for k,v in pairs(rules.class) do
  table.insert(class_list, k)
end

local weapon_list = {}
for k,v in pairs(rules.weapon) do
  table.insert(weapon_list, k)
end

local shield_list = {}
for k,v in pairs(rules.shield) do
  table.insert(shield_list, k)
end

local armor_list = {}
for k,v in pairs(rules.armor) do
  table.insert(armor_list, k)
end

math.randomseed(os.time())

function get_tile_cursor(pix_x, pix_y)
  local cursor = { x = 0, y = 0 }
  cursor.x = math.floor(pix_x / 8) * 8
  cursor.y = math.floor(pix_y / 8) * 8
  return cursor
end

function move_character_to_tile(character, pix_x, pix_y)
  local cursor = get_tile_cursor(pix_x, pix_y)
  local pos = { x = 0, y = 0 }
  pos.x = cursor.x - 4
  pos.y = cursor.y - 8
  character:set_position(pos.x, pos.y)
end

function move_character(character, pix_x, pix_y)
  local pos = { x = 0, y = 0 }
  pos.x = pix_x - 4
  pos.y = pix_y - 8
  character:set_position(pos.x, pos.y)
end


function start_game()

  print('dungeon')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/dungeon/maps/')

  load_tilemap('sample_dungeon', 4, 4)  -- offset of 4pxls

  local props = get_map_properties()
  print("map properties")
  for k, v in pairs(props) do
    print(k .. ": " .. tostring(v))
  end

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width / 2
  local panel_height = screen_dimensions.height / 2
  local panel_x = screen_dimensions.width / 2 - panel_width / 2
  local panel_y = screen_dimensions.height / 2 - panel_height / 2

  -- for i = 2, 18, 1 do
  --   local exp = rules.experience_for_level("fighter", i)
  --   print("lv: " .. tostring(i) .. " -> " .. tostring(exp))
  -- end

  -- set_draw_entities_ordered_by_position(unit_layer, true)
  -- create_text_line({
  --     id = "my_line_a",
  --     gui = true,
  --     layer = 1,
  --     position = { x = 20, y = 20 },
  --     text = "The quick brown fox jumps over the lazy dog.",
  --     font = "tiny_font",
  --     color = { r = 0, g = 0, b = 0, a = 255 },
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })
  -- create_text_line({
  --     id = "my_line_b",
  --     gui = true,
  --     layer = 1,
  --     position = { x = 20, y = 50 },
  --     text = "The quick brown fox jumps over the lazy dog.",
  --     font = "small_font",
  --     color = { r = 0, g = 0, b = 0, a = 255 },
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

    local new_character = Character:new()
    new_character:create("foo", rules.class.cleric, rules.sex.male)
    new_character:set_sprite()
    move_character_to_tile(new_character, 50, 150)
    set_show_outline({id = new_character.sprite, show = true, color = { r = 255, g = 255, b = 255, a = 155 } })
    table.insert(characters, new_character)

    selected_character = new_character


    create_panel({
        id = "tile_cursor",
        gui = false,
        layer = 9,
        position = { x = 0, y = 0 },
        dimensions = { width = 8, height = 8 },
        texture = {
          texture = "gui",
          position = { x = 0, y = 0 },
        dimensions = { width = 0, height = 0 },
        },
        on_input = function(event) 
          return false
        end,
      })
    set_show_outline(
      {
        id = "tile_cursor",
        show = true,
        color = { r = 255, g = 255, b = 255, a = 255 },
      }
    )
end


function loop(delta)
end

function on_input(event)
  -- print('input: ' .. tostring(event.type))
  -- print('button: ' .. tostring(event.button))
  -- print('key: ' .. tostring(event.key))
  -- print('coords: ' .. tostring(event.x) .. ', ' .. tostring(event.y))
  -- print('delta: ' .. tostring(event.delta))

  -- mouse map panning
  if event.type == 'mouse_button_down' then
    if event.button == 2 then
      wheel_down = true
      mouse_position = get_game_mouse_position()

    elseif event.button == 1 then
      local pos = { x = 0, y = 0 }
      if selected_character ~= nil then
        move_character(selected_character, tile_cursor.x, tile_cursor.y)
      end

    elseif event.button == 0 then
      for i,character in ipairs(characters) do
        local entity = get_entity(character.sprite)
        local pos = get_game_mouse_position()

        if pos.x > entity.position.x and pos.x <= entity.position.x + entity.dimensions.width and pos.y > entity.position.y and pos.y <= entity.position.y + entity.dimensions.height then
          
          set_show_outline({id = selected_character.sprite, show = false, color = { r = 255, g = 255, b = 255, a = 155 } })
          selected_character = character
          print('selected character: ' .. selected_character.name)
          print(" - class: " .. selected_character.class.name)
          set_show_outline({id = selected_character.sprite, show = true, color = { r = 255, g = 255, b = 255, a = 155 } })
          break
        end

      end
    end


  elseif event.type == 'mouse_button_up' then
    if event.button == 2 then
      wheel_down = false
    end

  elseif event.type == 'mouse_moved' then
    local pos = get_game_mouse_position()
    tile_cursor.x = math.floor(pos.x / 8) * 8
    tile_cursor.y = math.floor(pos.y / 8) * 8
    set_position("tile_cursor", tile_cursor.x, tile_cursor.y)

    if wheel_down then
      local pos = get_game_mouse_position()
      local delta_x = mouse_position.x - pos.x
      local delta_y = mouse_position.y - pos.y
      pan_game_view(delta_x, delta_y)
      mouse_position = get_game_mouse_position()
      -- print('position: ' .. tostring(mouse_position.x) .. ', ' .. tostring(mouse_position.y))
    end
  end

  -- mouse move order
  if event.type == 'mouse_button_up' then
    if event.button == 1 then
      local pos = get_game_mouse_position()
    end
  end


  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.V then
      set_entity_visibility('obstacles', true)

    elseif event.key == Input.R then
      remove_tilemap()

    elseif event.key == Input.E then

    elseif event.key == Input.N then
      local new_character = Character:new()
      new_character:create("foo_" .. #characters, rules.class.cleric, rules.sex.male)
      
      if math.random(1, 2) == 1 then
        new_character.sex = rules.sex.male
      else
        new_character.sex = rules.sex.female
      end
      new_character.class = rules.class[class_list[math.random(1, #class_list)]]
      new_character.head = rules.head[math.random(1, #rules.head)]
      new_character:equip_armor(armor_list[math.random(1, #armor_list)])
      new_character:equip_weapon(weapon_list[math.random(1, #weapon_list)])
      new_character:equip_shield(shield_list[math.random(1, #shield_list)])

      new_character:set_sprite()
      local pos = get_game_mouse_position()
      move_character_to_tile(new_character, pos.x, pos.y)
      table.insert(characters, new_character)

    elseif event.key == Input.T then
      -- toggle_fullscreen()

    elseif event.key == Input.S then
      if selected_character ~= nil then
        if selected_character.sex.name == rules.sex.male.name then
          selected_character.sex = rules.sex.female
          print("set to female")
        else
          selected_character.sex = rules.sex.male
          print("set to male")
        end
        selected_character:set_sprite()
      end

    elseif event.key == Input.C then
      if selected_character ~= nil then
        class_index = (class_index % #class_list) + 1
        selected_character.class = rules.class[class_list[class_index]]
        print("class: " .. selected_character.class.name)
        selected_character:set_sprite()
      end

    elseif event.key == Input.Up then
      if selected_character ~= nil then
        head_index = (head_index % #rules.head) + 1
        selected_character.head = rules.head[head_index]
        print("head: " .. head_index)
        selected_character:set_sprite()
      end

    elseif event.key == Input.Down then
      if selected_character ~= nil then
        armor_index = (armor_index % #armor_list) + 1
        selected_character:equip_armor(armor_list[armor_index])
        print("armor: " .. selected_character.armor.name)
        selected_character:set_sprite()
      end

    elseif event.key == Input.Left then
      if selected_character ~= nil then
        shield_index = (shield_index % #shield_list) + 1
        selected_character:equip_shield(shield_list[shield_index])
        print("shield: " .. selected_character.shield.name)
        selected_character:set_sprite()
      end

    elseif event.key == Input.Right then
      if selected_character ~= nil then
        weapon_index = (weapon_index % #weapon_list) + 1
        selected_character:equip_weapon(weapon_list[weapon_index])
        print("weapon: " .. selected_character.weapon.name)
        selected_character:set_sprite()
      end
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up or event.key == Input.W then
    elseif event.key == Input.Down or event.key == Input.S then
    elseif event.key == Input.Left or event.key == Input.A then
    elseif event.key == Input.Right or event.key == Input.D then
    end

  elseif event.type == 'mouse_button_down' then
    print('mouse button: ' .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    if event.button == 0 then
      local pos = get_game_mouse_position()
      local tile = get_tile('grass', pos.x, pos.y)
    end

  elseif event.type == 'mouse_moved' then

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



