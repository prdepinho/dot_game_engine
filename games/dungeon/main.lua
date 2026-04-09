
local Resources = require "games.dungeon.resources"
local GameScreen = require "games.dungeon.game_screen"
local MenuScreen = require "games.dungeon.menu_screen"


local screen = nil


function start_game()

  print('dungeon')
  Resources:load_assets()
  Resources:load_font()
  set_tilemap_path('games/dungeon/maps/')

  math.randomseed(os.time())

  screen = MenuScreen:new()
  screen:open()

end

function loop(delta)
  screen:loop()
end

function on_input(event)
  screen:on_input(event)
end

function end_game()
  screen:close()
  print('end')
end



