
local Resources = require "games.napoleonic.resources"
local Input = require "games.napoleonic.input"
local Unit = require "games.napoleonic.unit"
local Dialog = require "games.napoleonic.dialog"
local Token = require "games.napoleonic.token"

local Orders = {
  orders = {},
}

function Orders:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Orders:add_move_order(unit, dst)
  local order = {
    unit = unit,
    dst = { x = math.floor(dst.x), y = math.floor(dst.y) },
    moves = {},
  }
  self:trace_route(order)
  table.insert(self.orders, order)
end

function Orders:add_change_formation_order(unit, formation)
  local order = {
    unit = unit,
    moves = {},
  }
  table.insert(order.moves, self:make_change_formation_move(order.unit, formation))
  table.insert(self.orders, order)
end


function Orders:trace_route(order)
  local dsts = self:split_route(order)
  for _,dst in ipairs(dsts) do
    table.insert(order.moves, self:make_turn_move(order.unit, dst))
    table.insert(order.moves, self:make_march_move(order.unit, dst))
  end
end

function Orders:split_route(order)
  local dsts = {
    { x = order.dst.x, y = order.dst.y }
  }
  return dsts
end

function Orders:make_change_formation_move(unit, formation)
  return {
    type = "change_formation",
    unit = unit,
    formation = formation,
    speed = 0.1,
    delta = 0,
    step = 0,
    max_steps = 10,
    running = true,
  }
end

function Orders:make_turn_move(unit, dst)
  local position = get_entity(unit.base.id).position
  if position.x == dst.x and position.y == dst.y then
    return {
      type = "none",
      running = false,
    }
  end
  local rotation = get_rotation(unit.base.id)

  local delta = { x = dst.x - position.x, y = dst.y - position.y }
  local rads = 0
  local angle = 0

  if delta.x > 0 and delta.y <= 0 then
    rads = math.atan(delta.x / delta.y)
    angle = math.abs(rads * 180 / math.pi)
  elseif delta.x > 0 and delta.y > 0 then
    rads = math.atan(delta.y / delta.x)
    angle = math.abs(rads * 180 / math.pi) + 90
  elseif delta.x <= 0 and delta.y > 0 then
    rads = math.atan(delta.x / delta.y)
    angle = math.abs(rads * 180 / math.pi) + 90 * 2
  elseif delta.x <= 0 and delta.y <= 0 then
    rads = math.atan(delta.y / delta.x)
    angle = math.abs(rads * 180 / math.pi) + 90 * 3
  end

  local distance_clock = (angle - rotation) % 360
  local distance_counter = (rotation - angle) % 360
  local turn_delta = distance_counter > distance_clock and 1 or -1

  return {
    type = "turn",
    unit = unit,
    objective = angle,
    delta = turn_delta,
    speed = 100,
    running = true,
  }
end

function Orders:make_march_move(unit, dst)
  local position = get_entity(unit.base.id).position
  if position.x == dst.x and position.y == dst.y then
    return {
      type = "none",
      running = false,
    }
  end
  local delta_x = math.abs(position.x - dst.x)
  local delta_y = math.abs(position.y - dst.y)
  local distance = math.sqrt(delta_x * delta_x + delta_y * delta_y)
  return {
    type = "march",
    unit = unit,
    objective = dst,
    delta = 1,
    speed = 100,
    running = true,
  }
end

function Orders:execute_orders_loop(elapsed_time)
  for i,order in ipairs(self.orders) do
    if #order.moves > 0 then
      local move = order.moves[1]

      if move.type == "turn" then

        local rotation = get_rotation(move.unit.base.id)
        local delta = move.speed * elapsed_time * move.delta
        local remaining_rotation = 0
        if move.delta > 0 then
          remaining_rotation = (move.objective - rotation) % 360
        else
          remaining_rotation = (rotation - move.objective) % 360
        end
        if remaining_rotation <= math.abs(delta) then
          delta = remaining_rotation
          move.running = false
        end
        -- print('remaining rotation: ' .. tostring(remaining_rotation) .. ', delta: ' .. delta)
        move.unit:rotate(delta)

      elseif move.type == "march" then
        local position = get_entity(move.unit.base.id).position
        local delta = move.speed * elapsed_time * move.delta
        local delta_x = math.abs(position.x - move.objective.x)
        local delta_y = math.abs(position.y - move.objective.y)
        local remaining_distance = math.sqrt(delta_x * delta_x + delta_y + delta_y)
        if delta >= remaining_distance then
          delta = remaining_distance
          move.running = false
        end
        if move.last_distance and move.last_distance < remaining_distance then
          delta = 0
          move.running = false
        end
        move.last_distance = remaining_distance
        move.unit:move(delta)

      elseif move.type == "change_formation" then
        if move.step == 0 then
          local rank = move.unit.file
          local file = move.unit.rank
          move.unit:change_formation(move.formation)
          move.step = move.step + 1
          move.unit:set_visible(not move.unit.visible)
        end
        move.delta = move.delta + elapsed_time
        if move.delta >= move.speed then
          move.delta = 0
          move.step = move.step + 1
          move.unit:set_visible(not move.unit.visible)
        end
        if move.step == move.max_steps then
          move.running = false
        end
      end

      if not move.running then
        table.remove(order.moves, 1)
        print("move '" .. move.type .. "' complete")
      end
    end
    if #order.moves == 0 then
      table.remove(self.orders, i)
      print("order complete")
    end
  end
end

local orders = Orders:new()


local up = false
local down = false
local left = false
local right = false

local wheel_down = false
local mouse_position = { x = 0, y = 0 }

local selected = nil
local units = {}
local token = {}
local token2 = {}


function start_game()

  print('napoleonic')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/napoleonic/maps/')

  load_tilemap('wagram', 0, 0)

  local props = get_map_properties()
  print("map properties")
  for k, v in pairs(props) do
    print(k .. ": " .. tostring(v))
  end

  -- local my_point = get_map_object('objects', 'my_line')
  -- print('object: ')
  -- for k, v in pairs(my_point) do
  --   print(k .. ": " .. tostring(v))
  --   if k == 'position' then
  --     print('  (' .. tostring(v.x) .. ', ' .. tostring(v.y) .. ')')
  --   elseif k == 'properties' then
  --     print('properties size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv))
  --     end
  --   elseif k == 'AABB' then
  --     print('AABB size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv))
  --     end
  --   elseif k == 'points' then
  --     print('points size: ' .. tostring(#v))
  --     for pk, pv in pairs(v) do
  --       print('  -' .. pk .. ": " .. tostring(pv.x) .. ', ' .. tostring(pv.y))
  --     end
  --   end
  -- end

  -- set_callback({
  --   id = "bottom_layer",
  --   on_input = function(event)
  --     if event.type == "mouse_button_down" then
  --       if event.button == 0 then
  --         local tile = get_tile_under_cursor("obstacles")
  --         print("tile x: " .. tostring(tile.x) .. ", y: " .. tostring(tile.y))

  --         local ptile = get_tile_texture("obstacles", tile.x, tile.y)
  --         print('px: ' .. tostring(ptile.x) .. ', ' .. tostring(ptile.y))
  --         return true
  --       end
  --     end
  --     return false
  --   end
  -- })

  local screen_dimensions = get_screen_dimensions()
  local panel_width = screen_dimensions.width / 2
  local panel_height = screen_dimensions.height / 2
  local panel_x = screen_dimensions.width / 2 - panel_width / 2
  local panel_y = screen_dimensions.height / 2 - panel_height / 2

  -- dialog = Dialog:new()
  -- dialog:create(panel_x, panel_y, panel_width, panel_height)

  -- local font = "small_cursive_font"
  -- local color = { r = 0, g = 0, b = 0, a = 255}

  -- create_text_line({
  --     id = "my_line_a",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 10 },
  --     text = "Ésther. Dungeons & Dragons. Kakaroto. Hakhahaka Arara na arapuca. Kaka. Águia, às favas. ó aqui, ó. Põe isso no chão, menino. No âmago do meu coração. Âmago, entendeu? Amor, amor.",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })
  -- create_text_line({
  --     id = "my_line_b",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 30 },
  --     text = "Aa Ba Ca Da Ea Fa Ga Ha Ia Ja Ka La Ma Na Oa Pa Qa Ra Sa Ta Ua Va Wa Xa Ya Za",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

  -- create_text_line({
  --     id = "my_line_c",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 50 },
  --     text = "abcdefghijklmnopqrstuvwxyz",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

  -- create_text_line({
  --     id = "my_line_d",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 70 },
  --     text = "The quick brown fox jumps over the lazy dog.",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

  -- create_text_line({
  --     id = "my_line_e",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 90 },
  --     text = "(80)1234567890 { return 'false'; }",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

  -- create_text_block({
  --     id = "my_block",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 110 },
  --     line_length = 800,
  --     text = " I: Quo usque tandem abutere, Catilina, patientia nostra? quam diu etiam furor iste tuus nos eludet? quem ad finem sese effrenata iactabit audacia? Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae, nihil timor populi, nihil concursus bonorum omnium, nihil hic munitissimus habendi senatus locus, nihil horum ora voltusque moverunt? Patere tua consilia non sentis, constrictam iam horum omnium scientia teneri coniurationem tuam non vides? Quid proxima, quid superiore nocte egeris, ubi fueris, quos convocaveris, quid consilii ceperis, quem nostrum ignorare arbitraris? [2] O tempora, o mores! Senatus haec intellegit. Consul videt; hic tamen vivit. Vivit? immo vero etiam in senatum venit, fit publici consilii particeps, notat et designat oculis ad caedem unum quemque nostrum. Nos autem fortes viri satis facere rei publicae videmur, si istius furorem ac tela vitemus. Ad mortem te, Catilina, duci iussu consulis iam pridem oportebat, in te conferri pestem, quam tu in nos [omnes iam diu] machinaris.",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })

  -- create_text_block({
  --     id = "my_block",
  --     gui = true,
  --     layer = 4,
  --     position = { x = 10, y = 110 },
  --     line_length = 800,
  --     text = "We hold these Truths to be self-evident, that all Men are created equal, that they are endowed by their Creator with certain unalienable Rights, that among these are Life, Liberty, and the pursuit of Happiness -- That to secure these Rights, Governments are instituted among Men, deriving their just Powers from the Consent of the Governed, that whenever any Form of Government becomes destructive of these Ends, it is the Right of the People to alter or abolish it, and to institute a new Government, laying its Foundation on such Principles, and organizing its Powers in such Form, as to them shall seem most likely to effect their Safety and Happiness. Prudence, indeed, will dictate that Governments long established should not be changed for light and transient Causes; and accordingly all Experience hath shewn, that Mankind are more disposed to suffer, while Evils are sufferable, than to right themselves by abolishing the Forms to which they are accustomed. But when a long Train of Abuses and Usurpations, pursuing invariably the same Object, evinces a Design to reduce them under absolute Despotism, it is their Right, it is their Duty, to throw off such Government, and to provide new Guards for their future Security. Such has been the patient Sufferance of these Colonies; and such is now the Necessity which constrains them to alter their former Systems of Government. The History of the Present King of Great-Britain is a History of repeated Injuries and Usurpations, all having in direct Object the Establishment of an absolute Tyranny over these States. To prove this, let Facts be submitted to a candid World.",
  --     font = font,
  --     color = color,
  --     on_input = function(event) 
  --       return false
  --     end,
  --   })



  local unit_layer = 12
  local rank = 2
  local file = 6

  units[#units+1] = Unit:new()
  units[#units]:create("unit1", 100, 100, "infantry", "small", unit_layer, "small_infantry_sprite")
  select_unit(units[#units])

  units[#units+1] = Unit:new()
  units[#units]:create("unit2", 200, 100, "cavalry", "small", unit_layer, "small_cavalry_sprite")

  units[#units+1] = Unit:new()
  units[#units]:create("unit3", 300, 100, "artillery", "small", unit_layer, "small_artillery_sprite")

  units[#units+1] = Unit:new()
  units[#units]:create("unit4", 100, 200, "infantry", "medium", unit_layer, "small_infantry_sprite")
  select_unit(units[#units])

  units[#units+1] = Unit:new()
  units[#units]:create("unit5", 200, 200, "cavalry", "medium", unit_layer, "small_cavalry_sprite")

  units[#units+1] = Unit:new()
  units[#units]:create("unit6", 300, 200, "artillery", "medium", unit_layer, "small_artillery_sprite")

  units[#units+1] = Unit:new()
  units[#units]:create("unit7", 100, 300, "infantry", "large", unit_layer, "small_infantry_sprite")
  select_unit(units[#units])

  units[#units+1] = Unit:new()
  units[#units]:create("unit8", 200, 300, "cavalry", "large", unit_layer, "small_cavalry_sprite")

  units[#units+1] = Unit:new()
  units[#units]:create("unit9", 300, 300, "artillery", "large", unit_layer, "small_artillery_sprite")

  -- for i = 1, 10, 1 do
  --   for j = 1, 10, 1 do
  --     local x = 100 + i * 50
  --     local y = 100 + j * 50
  --     local id = "unit_" .. tostring(i) .. "_" .. tostring(j)
  --     units[#units + 1] = Unit:new()
  --     units[#units]:create(id, x, y, "infantry", "medium", unit_layer, "small_infantry_sprite")
  --   end
  -- end

  token = Token:new()
  token:create('token1', unit_layer, 'blue', 'guard_infantry', 100, 100)

  token2 = Token:new()
  token2:create('token2', unit_layer, 'blue', 'guard_infantry', 200, 200)

  set_draw_entities_ordered_by_position(unit_layer, true)


end



local delta_x;
local delta_y;


local speed = 300  -- px / s

local delta_movement = 0;
local delta_angle = 0.0;

function loop(delta)

  orders:execute_orders_loop(delta)


  if delta_angle ~= 0.0 then
    selected:rotate(speed * delta * delta_angle)
    local angle = get_rotation(selected.base.id)
    print("angle: " .. tostring(angle))
  end

  if delta_movement ~= 0 then
    selected:move(speed * delta * delta_movement)
  end



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
  end
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
    end

  elseif event.type == 'mouse_button_up' then
    if event.button == 2 then
      wheel_down = false
    end

  elseif event.type == 'mouse_moved' then
    if wheel_down then
      local pos = get_game_mouse_position()
      local delta_x = mouse_position.x - pos.x
      local delta_y = mouse_position.y - pos.y
      pan_game_view(delta_x, delta_y)
      mouse_position = get_game_mouse_position()
    end
  end

  -- mouse move order
  if event.type == 'mouse_button_up' then
    if event.button == 1 then
      local pos = get_game_mouse_position()
      orders:add_move_order(selected, pos)
      orders:add_change_formation_order(selected, 'column')
    end
  end


  if event.type == 'key_down' then
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.C then
      selected:attack()

    elseif event.key == Input.V then
      set_entity_visibility('obstacles', true)

    elseif event.key == Input.R then
      remove_tilemap()

    elseif event.key == Input.E then
      local rotation = get_rotation(selected.base.id)
      print('rotation: ' .. tostring(rotation))

    elseif event.key == Input.F then
      print('open fire')
      selected:fire()

    elseif event.key == Input.T then
      -- toggle_fullscreen()
      if selected.formation == 'line' then
        orders:add_change_formation_order(selected, 'column')
      else
        orders:add_change_formation_order(selected, 'line')
      end

    elseif event.key == Input.Up or event.key == Input.W then
      up = true
      down = false
      delta_movement = 1

    elseif event.key == Input.Down or event.key == Input.S then
      down = true
      up = false
      delta_movement = -1

    elseif event.key == Input.Left or event.key == Input.A then
      left = true
      right = false
      delta_angle = -1.0

    elseif event.key == Input.Right or event.key == Input.D then
      right = true
      left = false
      delta_angle = 1.0
    end

  elseif event.type == 'key_up' then
    if event.key == Input.Up or event.key == Input.W then
      if up then
        delta_movement = 0
      end
      up = false
    elseif event.key == Input.Down or event.key == Input.S then
      if down then
        delta_movement = 0
      end
      down = false
    elseif event.key == Input.Left or event.key == Input.A then
      if left then
        delta_angle = 0.0
      end
      left = false
    elseif event.key == Input.Right or event.key == Input.D then
      if right then
        delta_angle = 0.0
      end
      right = false
    end

  elseif event.type == 'mouse_button_down' then
    print('mouse button: ' .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    if event.button == 0 then
      local pos = get_game_mouse_position()
      local tile = get_tile('grass', pos.x, pos.y)

      print("----")
      print('coords: ' .. tostring(pos.x) .. ', ' .. tostring(pos.y))
      -- print('tile: ' .. tostring(tile.x) .. ', ' .. tostring(tile.y))
      for _,unit in ipairs(units) do
        for k,v in pairs(unit.sprites) do
          local contains = entity_contains(k, pos.x, pos.y)
          if contains then
            print('contains: ' .. unit.base.id)
            select_unit(unit)
            goto endloop
          end
        end
      end
      ::endloop::

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


function select_unit(unit)
  if selected then
    set_show_outline({id=selected.base.id, show=false, color={r=255, g=255, b=255}})
  end
  selected = unit
  set_show_outline({id=selected.base.id, show=true, color={r=255, g=255, b=255}})
end

