
local count = 0.0
local Resources = require "scripts.resources"
local Input = require "scripts.input"


local delta_x = 0.0
local delta_y = 0.0


local up = false
local down = false
local left = false
local right = false
local current_animation = ""

function start_game()

  Resources:load_assets()
  Resources:load_font()


  local my_tile_layer = {
    id = "my_tile_layer",
    gui = false,
    layer = 1,
    position = { x = 16, y = 16 },
    tile_dimensions = { width = 16, height = 16 },
    rows = 8,
    columns = 10,
    texture = "tiles",
    tiles = {
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
      {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1}, {x=0,y=1},
    },
    on_input = function(event)
      if event.type == "mouse_button_down" then
        tile = get_tile_under_cursor("my_tile_layer")
        print("tile x: " .. tostring(tile.x) .. ", y: " .. tostring(tile.y))
        return true
      end
      return false
    end
  }
  create_tile_layer(my_tile_layer)

  set_tile("my_tile_layer", 3, 2, 4, 1)
  


  local my_panel = {
    id = "my_panel",
    gui = false,
    layer = 1,
    position = { x = 0, y = 0 },
    dimensions = { width = 16, height = 16 },
    texture = {
      texture = "gui",
      dimensions = { width = 16, height = 16 },
      position = { x = 208, y = 16 },
    },
  }
  create_panel(my_panel)


  local my_line_a = {
    id = "my_line_a",
    gui = true,
    layer = 1,
    position = { x = 20, y = 20 },
    text = "The quick brown fox jumps over the lazy dog.",
    font = "font",
    color = { r = 255, g = 255, b = 255, a = 255 },
  }
  create_text_line(my_line_a)

  local my_block = {
    id = "my_block",
    gui = true,
    layer = 1,
    position = { x = 20, y = 40 },
    line_length = 300,
    text = " I: Quo usque tandem abutere, Catilina, patientia nostra? quam diu etiam furor iste tuus nos eludet? quem ad finem sese effrenata iactabit audacia? Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae, nihil timor populi, nihil concursus bonorum omnium, nihil hic munitissimus habendi senatus locus, nihil horum ora voltusque moverunt? Patere tua consilia non sentis, constrictam iam horum omnium scientia teneri coniurationem tuam non vides? Quid proxima, quid superiore nocte egeris, ubi fueris, quos convocaveris, quid consilii ceperis, quem nostrum ignorare arbitraris? [2] O tempora, o mores! Senatus haec intellegit. Consul videt; hic tamen vivit. Vivit? immo vero etiam in senatum venit, fit publici consilii particeps, notat et designat oculis ad caedem unum quemque nostrum. Nos autem fortes viri satis facere rei publicae videmur, si istius furorem ac tela vitemus. Ad mortem te, Catilina, duci iussu consulis iam pridem oportebat, in te conferri pestem, quam tu in nos [omnes iam diu] machinaris.",
    font = "font",
    color = { r = 255, g = 255, b = 255, a = 255 },
  }
  create_text_block(my_block)


  local x = 50;
  local y = 50;
  local width = 400;
  local height = 300;
  local margin = 10;
  local layer = 2;

  local my_component_panel = {
    id = "my_component_panel",
    gui = true,
    layer = layer,
    position = { x = x, y = y },
    dimensions = { width = width, height = height },
    texture = {
      texture = "gui",
      position = { x = 192, y = 0 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
    on_input = function(event) 
      if event.type == "mouse_cursor_enter" then
        print('panel: cursor enter')
      elseif event.type == "mouse_cursor_exit" then
        print('panel: cursor exit')
      elseif event.type == "mouse_button_down" then
        print("panel: button down")
      elseif event.type == "mouse_button_up" then
        print("panel: button up")
      end
    end,
  }
  create_segmented_panel(my_component_panel)

  local my_component_block = {
    id = "my_component_block",
    gui = true,
    layer = layer + 1,
    position = { x = x + margin, y = y + margin },
    line_length = width - 2 * margin,
    text = " I: Quo usque tandem abutere, Catilina, patientia nostra? quam diu etiam furor iste tuus nos eludet? quem ad finem sese effrenata iactabit audacia? Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae, nihil timor populi, nihil concursus bonorum omnium, nihil hic munitissimus habendi senatus locus, nihil horum ora voltusque moverunt? Patere tua consilia non sentis, constrictam iam horum omnium scientia teneri coniurationem tuam non vides? Quid proxima, quid superiore nocte egeris, ubi fueris, quos convocaveris, quid consilii ceperis, quem nostrum ignorare arbitraris? [2] O tempora, o mores! Senatus haec intellegit. Consul videt; hic tamen vivit. Vivit? immo vero etiam in senatum venit, fit publici consilii particeps, notat et designat oculis ad caedem unum quemque nostrum. Nos autem fortes viri satis facere rei publicae videmur, si istius furorem ac tela vitemus. Ad mortem te, Catilina, duci iussu consulis iam pridem oportebat, in te conferri pestem, quam tu in nos [omnes iam diu] machinaris.",
    font = "font",
    color = { r = 0, g = 0, b = 0, a = 255 },
  }
  create_text_block(my_component_block)

  local click_time = os.time()
  local my_button_panel = {
    id = "my_button_panel",
    gui = true,
    layer = layer + 2,
    position = { x = x + width / 2, y = y + height - 10 - 14 },
    dimensions = { width = 38, height = 14 },
    texture = {
      texture = "gui",
      position = { x = 208, y = 16 },
      border_size = 4,
      interior = { width = 8, height = 8 },
    },
    on_input = function(event) 
      if event.type == "mouse_cursor_enter" then
        print('button: cursor enter')
        set_segmented_panel_texture({
          id = "my_button_panel",
          texture = "gui",
          position = { x = 208, y = 0 },
          border_size = 4,
          interior = { width = 8, height = 8 },
        })
        return true
      elseif event.type == "mouse_cursor_exit" then
        print('button: cursor exit')
        set_segmented_panel_texture({
          id = "my_button_panel",
          texture = "gui",
          position = { x = 208, y = 16 },
          border_size = 4,
          interior = { width = 8, height = 8 },
        })
        return true
      elseif event.type == "mouse_button_down" then
        print("button: button down")
        click_time = os.time()
        set_segmented_panel_texture({
          id = "my_button_panel",
          texture = "gui",
          position = { x = 208, y = 32 },
          border_size = 4,
          interior = { width = 8, height = 8 },
        })
        return true
      elseif event.type == "mouse_button_up" then
        print("button: button up")
        if os.time() - click_time < 1 then
          print("CLICK")
        end
        set_segmented_panel_texture({
          id = "my_button_panel",
          texture = "gui",
          position = { x = 208, y = 0 },
          border_size = 4,
          interior = { width = 8, height = 8 },
        })
        return true
      elseif event.type == "key_up" then
      elseif event.type == "mouse_moved" then
      elseif event.type == "mouse_scrolled" then
      end
      return false
    end,
  }
  create_segmented_panel(my_button_panel)


  local my_sprite = {
    id = "my_sprite",
    gui = false,
    layer = 2,
    position = { x = 0, y = 0 },
    dimensions = { width = 16, height = 16 },
    sprite = {
      texture = "sprites",
      origin = { x = 0, y = 0 },
      dimensions = { height = 16, width = 16 },
      animations = {
        {
          key = "march_s",
          fps = 5,
          frames = {
            function(id) print('walk: ' .. id) end,
            { x = 0, y = 0 },
            { x = 0, y = 1 }
          }
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
          fps = 5,
          frames = { 
            function(id) print('fire: ' .. id) end,
            { x = 0, y = 2 },
            { x = 0, y = 0 },
          }
        },
        {
          key = "fire_se",
          fps = 5,
          frames = { { x = 1, y = 2 } }
        },
        {
          key = "fire_e",
          fps = 5,
          frames = { { x = 2, y = 2 } }
        },
        {
          key = "fire_ne",
          fps = 5,
          frames = { { x = 3, y = 2 } }
        },
        {
          key = "fire_n",
          fps = 5,
          frames = { { x = 4, y = 2 } }
        },
        {
          key = "fire_nw",
          fps = 5,
          frames = { { x = 5, y = 2 } }
        },
        {
          key = "fire_w",
          fps = 5,
          frames = { { x = 6, y = 2 } }
        },
        {
          key = "fire_sw",
          fps = 5,
          frames = { { x = 7, y = 2 } }
        },

      }
    },
  }
  create_sprite(my_sprite)
  sprite_start_animation("my_sprite", "march_s", true)


end

function loop(delta)
  count = count + delta
  -- print('loop: ' .. tostring(count))

  -- pan_game_view(delta_x, delta_y)
  move_entity('my_sprite', delta_x, delta_y)


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
    local animation = "march_" .. direction
    if current_animation ~= animation then
      print('animation: ' .. animation)
      sprite_start_animation("my_sprite", animation, true)
      current_animation = animation
    end
  end
end

function on_input(event)
  if event.type == 'key_down' then
    -- print(tostring(event.elapsed_time) .. " key down: " .. tostring(event.key))
    if event.key == Input.Escape then
      close_game()

    elseif event.key == Input.R then
      remove_entity("my_component_block")
      remove_entity("my_component_panel")
      remove_entity("my_button_panel")

    elseif event.key == Input.D then
      -- remove_entity("my_panel")

    elseif event.key == Input.F then
      sprite_start_animation("my_sprite", "fire_s", false)

    elseif event.key == Input.Up then
      delta_y = -1
      -- resize_entity("my_panel", 0, -10)
      print('up')
      up = true
      down = false

    elseif event.key == Input.Down then
      delta_y = 1
      -- resize_entity("my_panel", 0, 10)
      print('down')
      down = true
      up = false

    elseif event.key == Input.Left then
      delta_x = -1
      -- resize_entity("my_panel", -10, 0)
      print('left')
      left = true
      right = false

    elseif event.key == Input.Right then
      delta_x = 1
      -- resize_entity("my_panel", 10, 0)
      print('right')
      right = true
      left = false
    end

  elseif event.type == 'key_up' then
    -- print(tostring(event.elapsed_time) .. " key up: " .. tostring(event.key))

    if event.key == Input.Up then
      up = false
    elseif event.key == Input.Down then
      down = false
    elseif event.key == Input.Left then
      left = false
    elseif event.key == Input.Right then
      right = false
    end

  elseif event.type == 'mouse_button_down' then
    print(tostring(event.elapsed_time) .. " mouse down: " .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    -- print(tostring(event.elapsed_time) .. " mouse up: " .. tostring(event.button))
    -- local game_pos = get_game_mouse_position()
    -- local gui_pos = get_gui_mouse_position()
    -- print("game - x: " .. tostring(game_pos.x) .. ", y: " .. tostring(game_pos.y))
    -- print("gui - x: " .. tostring(gui_pos.x) .. ", y: " .. tostring(gui_pos.y))

  elseif event.type == 'mouse_moved' then
    -- print(tostring(event.elapsed_time) .. " mouse move - x: " .. tostring(event.x) .. ", y: " .. tostring(event.y))

  elseif event.type == 'mouse_scrolled' then
    -- print(tostring(event.elapsed_time) .. " mouse scrolled: " .. tostring(event.delta))

  end
end

function end_game()
  print('end')
end

