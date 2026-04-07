
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

-- If any point of the half-tile is on a free tile, then it is a free half-tile.
-- Except if it is an open door, then only the middle half-tile free.
function is_half_tile_free(pix_x, pix_y)
  local points = {
    { x = pix_x,   y = pix_y   },
    { x = pix_x+8, y = pix_y   },
    { x = pix_x+8, y = pix_y+8 },
    { x = pix_x,   y = pix_y+8 },
  }

  local open_door = true

  for _,pos in ipairs(points) do
    local tile = get_tile("floor", pos.x, pos.y)
    local props = get_tile_properties(tile.id)

    if props.type ~= "wall" and props.type ~= "door" then
      return true
    end

    open_door = open_door and (props.type == "door" and props.state == "open")
  end

  if open_door then 
    return true
  end
  
  return false
end


local bread_count = 0
local breadcrumb_paths = {}

function set_breadcrumbs(path)
  local global_tex_x = 64
  local global_tex_y = 480
  local tiles = {
    { x = 8*0, y = 8*1 },
  }

  local breadcrumbs = {}

  local directions = {
    ["0,-1"]  = "up",
    ["0,1"]   = "down",
    ["1,0"]   = "right",
    ["-1,0"]  = "left",
  }

  local direction_tex_map = {
    ["up->right"]      = { x = 8*2, y = 8*1 },
    ["up->down"]       = { x = 8*0, y = 8*1 },
    ["up->left"]       = { x = 8*3, y = 8*1 },
    ["right->up"]      = { x = 8*2, y = 8*1 },
    ["right->down"]    = { x = 8*2, y = 8*0 },
    ["right->left"]    = { x = 8*1, y = 8*1 },
    ["down->up"]       = { x = 8*0, y = 8*1 },
    ["down->right"]    = { x = 8*2, y = 8*0 },
    ["down->left"]     = { x = 8*3, y = 8*0 },
    ["left->up"]       = { x = 8*3, y = 8*1 },
    ["left->right"]    = { x = 8*1, y = 8*1 },
    ["left->down"]     = { x = 8*3, y = 8*0 },
    ["center->up"]     = { x = 8*4, y = 8*1 },
    ["center->right"]  = { x = 8*6, y = 8*1 },
    ["center->down"]   = { x = 8*4, y = 8*0 },
    ["center->left"]   = { x = 8*7, y = 8*1 },
    ["up->center"]     = { x = 8*5, y = 8*1 },
    ["right->center"]  = { x = 8*6, y = 8*0 },
    ["down->center"]   = { x = 8*5, y = 8*0 },
    ["left->center"]   = { x = 8*7, y = 8*0 },
    ["center->center"] = { x = 8*1, y = 8*0 },
  }

  for i = 1, #path do
    local prev_tile = i ~= 1 and path[i-1] or nil
    local next_tile = i ~= #path and path[i+1] or nil
    local tile = path[i]
    local x = tile.x * 8
    local y = tile.y * 8

    local direction_in  = prev_tile == nil and "center" or directions[tostring(prev_tile.x - tile.x) .. "," .. tostring(prev_tile.y - tile.y)]
    local direction_out = next_tile == nil and "center" or directions[tostring(next_tile.x - tile.x) .. "," .. tostring(next_tile.y - tile.y)]

    local tex = direction_tex_map[ direction_in .. "->" .. direction_out ]

    local tex_x = global_tex_x + tex.x
    local tex_y = global_tex_y + tex.y

    table.insert(breadcrumbs, { x = x, y = y, width = 8, height = 8, texture = { x = tex_x, y = tex_y, width = 8, height = 8 } })
  end

  local id = "breadcrumb_path_" .. bread_count
  bread_count = (bread_count + 1) 
  create_layered_panel({
      id = id,
      gui = false,
      layer = 1,
      position = { x = 0, y = 0 },
      dimensions = { width = 0, height = 0 },
      texture = "tiles",
      layers = breadcrumbs
    })
  table.insert(breadcrumb_paths, id)
end

function delete_breadcrumbs()
  for i,id in ipairs(breadcrumb_paths) do
    remove_entity(id)
  end
  breadcrumb_paths = {}
end


function start_game()

  print('dungeon')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/dungeon/maps/')

  load_tilemap('sample_dungeon', 4, 4)  -- offset of 4 pixels

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

      -- path finding -----------------------

      local tilemap_dimensions = get_tilemap_dimensions()
      local rows = tilemap_dimensions.rows * 2
      local columns = tilemap_dimensions.columns * 2
      print("rows: " .. tostring(tilemap_dimensions.rows))
      print("columns: " .. tostring(tilemap_dimensions.columns))
      local graph = {}
      for y = 0, rows -1 do
        for x = 0, columns -1 do
          graph[x + y * columns + 1] = is_half_tile_free(x * 8, y * 8)
        end
      end

      print("length: " .. tostring(#graph))
      print("rows: " .. tostring(rows) .. ", columns: " .. tostring(columns) .. " => " .. tostring(rows * columns))

      for y = 0, rows -1 do
        local line = ""
        for x = 0, columns -1 do
          line = line .. tostring(graph[x + y * columns + 1] == true and '.' or 'x')
        end
        print(line)
      end

      local entity = get_entity(selected_character.sprite)
      local begin_x = (entity.position.x + 4) / 8
      local begin_y = (entity.position.y + 8) / 8
      local end_x = tile_cursor.x / 8
      local end_y = tile_cursor.y / 8
      print(tostring(begin_x) .. ", " .. tostring(begin_y) .. " -> " .. tostring(end_x) .. ", " .. tostring(end_y))

      local path = find_path({
        graph = graph,
        rows = rows,
        columns = columns,
        start = { x = begin_x, y = begin_y, },
        destination = { x = end_x, y = end_y }
      })
      print(tostring(type(path)) .. ": " .. tostring(path))
      for i,node in ipairs(path) do
        print(tostring(i) .. ": " .. tostring(node.x) .. ", " .. tostring(node.y))
      end

      -- delete_breadcrumbs()
      set_breadcrumbs(path)
      ----------------------------


      if #path > 0 then
        local pos = { x = 0, y = 0 }
        if selected_character ~= nil then
          move_character(selected_character, tile_cursor.x, tile_cursor.y)
        end
      end

    elseif event.button == 0 then
      for i,character in ipairs(characters) do
        local entity = get_entity(character.sprite)
        local pos = get_game_mouse_position()

        if entity_contains(character.sprite, pos.x, pos.y) then
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

    if is_half_tile_free(tile_cursor.x, tile_cursor.y) then
      set_show_outline( { id = "tile_cursor", show = true, color = { r = 255, g = 255, b = 255, a = 255 } } )
    else
      set_show_outline( { id = "tile_cursor", show = true, color = { r = 255, g = 0, b = 0, a = 255 } } )
    end

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

    elseif event.key == Input.D then
      delete_breadcrumbs()

    elseif event.key == Input.P then
      local entity = get_entity(selected_character.sprite)
      local pos_x = (entity.position.x + 4) / 8
      local pos_y = (entity.position.y + 8) / 8
      print("Character position: " .. tostring(pos_x) .. ", " .. tostring(pos_y))

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
      local tile = get_tile_under_cursor("floor")
      print("Tile: " .. tostring(tile.id) .. ", x: " .. tostring(tile.x) .. ", y: " .. tostring(tile.y))
      local props = get_tile_properties(tile.id)
      for key,value in pairs(props) do
        print(" - " .. key .. ": " .. value)
      end

    elseif event.key == Input.O then
      local tile = get_tile_under_cursor("floor")
      local props = get_tile_properties(tile.id)

      if props.type == "door" then
        local next_tile_id = 0
        if props.state == "open" then
          next_tile_id = props.closed_tile
        else
          next_tile_id = props.open_tile
        end
        print("target: " .. tostring(next_tile_id))
        if next_tile_id > 0 then
          set_tile("floor", tile.x, tile.y, next_tile_id)
        end
      end


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



