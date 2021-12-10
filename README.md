
Dot is a game engine that I'm developing trying to streamline the messiness of the SFMLGame engine I created for 
Mumu's Pilgrimage. My objective is to have an engine that anyone who obtains a game for it can mess around with and 
do whatever he wants with it. So I lay bare the game code in Lua scripts, and all assets in easy to access formats.
Mumu's Pilgrimage largely did that, but much of the game was hard-coded in C++. With Dot I intent on transitioning
that to Lua and create general interfaces to mess with the game resources, what you draw on the screen, in a more 
organized way.
It currently is incomplete even compared to it's close relative, but I will add what is missing as I develop games for it.


# The config.lua
The configuration file `config.lua` can be found in the root folder of the game. 
It is self-explanatory and you may tweak the settings to fit your game.


# The main.lua

The `scripts/main.lua` is the main file of the game. Here you will implement four functions:

```
start_game()
```
This function is called at the start of the game. Use this function to set the game up.


```
end_game()
```
This function is called when your game ends. Use this function to wrap everything up with a bow.


```
loop(delta)
```
This function is called every frame. The frame-rate is set at `config.lua`. It gives you delta, 
the elapsed time since the last frame. You don't have to print or draw anything here, as all entities you 
create will be drawn and taken care by the engine. Use this function to update values and states for your game.

```
on_input(event)
  if event.type == 'key_down' then
    print("key down: " .. tostring(event.key))
    if event.key == Input.Escape then
      close_game()
    elseif event.key == Input.R then
    elseif event.key == Input.D then
    elseif event.key == Input.F then
    elseif event.key == Input.Up then
    elseif event.key == Input.Down then
    elseif event.key == Input.Left then
    elseif event.key == Input.Right then
    end

  elseif event.type == 'key_up' then
    print("key up: " .. tostring(event.key))

  elseif event.type == 'mouse_button_down' then
    print("mouse down: " .. tostring(event.button))

  elseif event.type == 'mouse_button_up' then
    print("mouse up: " .. tostring(event.button))
    local game_pos = get_game_mouse_position()
    local gui_pos = get_gui_mouse_position()
    print("game - x: " .. tostring(game_pos.x) .. ", y: " .. tostring(game_pos.y))
    print("gui - x: " .. tostring(gui_pos.x) .. ", y: " .. tostring(gui_pos.y))

  elseif event.type == 'mouse_moved' then
    print("mouse move - x: " .. tostring(event.x) .. ", y: " .. tostring(event.y))

  elseif event.type == 'mouse_scrolled' then
    print(tostring(event.elapsed_time) .. " mouse scrolled: " .. tostring(event.delta))

  end
end
```
This function is called whenever an input event is fired by your mouse or keyboard. 
I give an example of how it might look like. It will give you an object called event that contains all the information
you need to process the input event. Its members are as follows:
- type: a string that represent the type of the event. It may be 'key_down', 'key_up', 'mouse_button_down', 
'mouse_button_up', 'mouse_moved', 'mouse_scrolled'.
- key: the key of the keyboard. The set of all keys can be obtained in `scripts/input.lua`. 
It is useful to require this module in order to identify the keys.
- button: the button of the mouse.
- delta: how much the mouse wheel has been rolled.
- x: the new x position of the cursor, if it moved.
- y: the new y position of the cursor, if it moved.
- elapsed_time: how much time has passed since the last frame.

You may use event.x and event.y to get the cursor position for the 'mouse_moved' event, but if you want to have
the mouse position in relation to the game view or to the gui view, then use the functions get_game_mouse_position
and get_gui_mouse_position. This is better this way. The difference between game view and gui view is that the game view
can be panned or scrolled around, and the gui view stays on top of everything and stays put on the screen. Usually 
HUD is drawn on the gui view, and the game world is drawn on the game view. More on that later.



# General functions:

```
close_game()
```
This closes the game.


# Resource loading:

These functions load assets to memory and ready then for use. Most of them receive a key, which you will use to reference
them in other functions, and the path to the resource, which is relative to the root directory of the game, so an 
example would be "assets/texture/sprites.png".


```
resources_load_texture(key, path)
```
Load a texture. A PNG, a JPEG, etc. An image file. It may contain a big image, or multiple tiles or sprite frames.


```
resources_load_sound(key, path)
```
Load a sound file. WAV, ogg, etc.


```
resources_load_music(key, path)
```
Load music. The file types are the same as the previous function, but this function streams the music as it plays.


```
resources_load_font({
    key = "small_font",
    origin = { x = 0, y = 0 },
    texture = "gui",
    height = 8,
    spacing = 1,
    letters = {
      { letter = 'A',     x = 1,       y = 12,     w = 4 },
      { letter = 'Q',     x = 160,     y = 12,     w = 7,      f = 5 },
      { letter = ' ',     x = 127,     y = 23,     w = 2 },
      { letter = '~',     x = 115,     y = 23,     w = 4 },
      { letter = 'à',     x = 1,       y = 33,     w = 4 },
      -- ...
    }
  })
```
Load a font for the text you will be writing in the game. This is a bit more complex than the other functions. It
takes an object with the following members:

- key: the key for the font
- origin: the position the font is located in the file.
- texture: the key for the image file where your font is located.
- height: the height of the letters, in pixels. All letters have the same height.
- spacing: the space between letters when you write them.
- letters: a list of all the letters in the font.
    - letter: the letter. Any letter. Even accented letters or symbols, but they must be represented by at most two bytes.
    - x: x location in the file
    - y: y location in the file
    - w: the letter width
    - f: optional. This is how far the next letter is drawn after this one when you are writing with this font. 
    The default value is the same as w. Some letters that have long appendages that go over or under other letters 
    may make use of this field, like a Roman capital Q or the lowercase f.



# Entity creation

Use the following functions to create entities on the screen. All of these functions receive some of the same
parameters that I'll explain right now:
- id: the identifier of the object. This is what you use to reference the object to the engine.
- gui: optional. Default: false. Whether the object is drawn on the gui view. If it is not, then it is drawn on the game view.
The difference is that the game view may be panned or scrolled up, right, down and left, while the gui view always
stays in place and is drawn over everything else. That makes the gui view good for drawing windows, buttons, panels, etc, while the game view is good to draw
the game graphics, the map, the sprites, the special effects.
- layer: the layer on which the object is drawn upon. Both game view and gui view have a different set of layers.
Layer 0 is the lowest. There is no limit for the amount of layers you can use, but I recommend you not using more than a dozen, to keep things from getting out of hand.
If you draw multiple entities in the same layer, which entity is drawn over the other is undetermined, so if you want
to draw something over the others, the draw it on a higher layer, and keep track of them.
- position: x and y on the screen.
- on_input: this is a callback function that is called when the mouse cursor is over the entity and you do 
an input with the mouse or the keyboard. You get an event object that contains the information you need for treating
the input. If this function returns false, it will trigger the on_input function of the entity under it, 
or the main on_input function of the game if there are no entities under it. If you want to prevent this cascading calls,
then return true after treating the event. 

In the context of entities, the on_input function fires events that contain two more types 'mouse_cursor_enter' and
'mouse_cursor_exit'. These events occur when the mouse cursor enters withing the bounds of the entity, or goes outside it.


```
create_panel({
    id = "my_panel",
    gui = false,
    layer = 1,
    position = { x = 0, y = 0 },
    dimensions = { width = 16, height = 16 },
    texture = {
      texture = "gui",
      position = { x = 208, y = 16 },
	  dimensions = { width = 16, height = 16 },
    },
    on_input = function(event) 
      return false
    end,
  })
```
This creates a panel. A panel is a rectangle image that uses a section of an image file. You may use it to draw 
static images on the screen, icons, cursors, illustrations, that sort of thing.
- dimensions: the width and height of the element.
- texture.texture: the key to the texture that the panel uses.
- texture.position: the position where I will find the section.
- texture.dimensions: the width and height of the section. If it is not the same as the dimensions of the entity, then 
it will stretch or shrink to match it.


```
create_segmented_panel({
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
      return false
    end,
  })
```
A segmented panel is a panel that can be resized without getting stretched too much. It is called like that because the panel
is segmented in nine parts: the corners, the sides and the middle. If you resize a segmented panel, the middle
segment will stretch vertically and horizontally, and the sides will stretch vertically or horizontally, and the corners
will stay the same. The segmented panel is useful for making windows, panels, buttons, and other HUD elements.
- dimensions: the width and height of the element.
- texture.texture: the key to the texture file it uses.
- position: where is the texture section in the texture file.
- border_size: the width of the borders.
- interior: the width and height of the interior of the panel.


```
create_text_line({
    id = "my_line_a",
    gui = true,
    layer = 1,
    position = { x = 20, y = 20 },
    text = "The quick brown fox jumps over the lazy dog.",
    font = "font",
    color = { r = 255, g = 255, b = 255, a = 255 },
    on_input = function(event) 
      return false
    end,
  })
```
This function creates a text line. It only draws a line, and if you write too much it will write outside the window.
- text: the text you want to write.
- font: the key to the font you want to use.
- color: the color of the text in rgba. They go from 0 to 255. 
The a part means alpha, it is optional and its is set to 255 as default. If it is less than that, the text will be transparent.


```
create_text_block({
    id = "my_block",
    gui = true,
    layer = 1,
    position = { x = 20, y = 40 },
    line_length = 300,
    text = " I: Quo usque tandem abutere, Catilina, patientia nostra? quam diu etiam furor iste tuus nos eludet? quem ad finem sese effrenata iactabit audacia? Nihilne te nocturnum praesidium Palati, nihil urbis vigiliae, nihil timor populi, nihil concursus bonorum omnium, nihil hic munitissimus habendi senatus locus, nihil horum ora voltusque moverunt? Patere tua consilia non sentis, constrictam iam horum omnium scientia teneri coniurationem tuam non vides? Quid proxima, quid superiore nocte egeris, ubi fueris, quos convocaveris, quid consilii ceperis, quem nostrum ignorare arbitraris? [2] O tempora, o mores! Senatus haec intellegit. Consul videt; hic tamen vivit. Vivit? immo vero etiam in senatum venit, fit publici consilii particeps, notat et designat oculis ad caedem unum quemque nostrum. Nos autem fortes viri satis facere rei publicae videmur, si istius furorem ac tela vitemus. Ad mortem te, Catilina, duci iussu consulis iam pridem oportebat, in te conferri pestem, quam tu in nos [omnes iam diu] machinaris.",
    font = "font",
    color = { r = 255, g = 255, b = 255, a = 255 },
    on_input = function(event) 
      return false
    end,
  })
```
This function writes a text block. You have to inform the width of the text in pixels that the engine will use to
break lines. You can also break lines by writing \n in the text. If you write too much, it will keep writing lines below the screen.
- line_length: the max length of the text block. The text will not be written past it.
- text: the text.
- font: the key for the font.
- color: the color. Same as create_text_line.


```
create_sprite({
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
            { x = 0, y = 0 },
            function(id) print('fires with the second frame') end,
            { x = 0, y = 1 },
           }
        },
        {
          key = "march_se",
          fps = 5,
          frames = { { x = 1, y = 0 }, { x = 1, y = 1 } }
        },
		-- ...
      }
    },
    on_input = function(event) 
      return false
    end,
  })
```
A sprite is an animated picture. You can use it to draw character sprites or special effects. A sprite entity takes
its sprites from a single image file. All sprites in the file must be of the same size and you have to position them next
to each other in a way that you can refer to each of them with coordinates, for example: sprite 0,0, sprite 0,1, sprite 1,2.
By multiplying the coordinates with the sprite width or height you can obtain its position in the texture file.

You could instead use Panel entities to animate sprites, with a bit of hacking, but I think it's easier using the sprite entity.

After creating a sprite, don't let a frame pass without setting a looped animation to it, or the engine will crash. 
Use the sprite_start_animation function for that.

- dimensions: the width and height of the entity.
- sprite.texture: the key to the texture file.
- sprite.origin: where in the file are the sprite sections.
- sprite.dimensions: the width and height of the sprites. All frames use sprites of the same size.
- sprite.animations: a set of objects, one for each animation.
    - key: a key for the animation
    - fps: the animation speed in frames per second.
    - frames: the list of frames. Each frame has a coordinate that identifies it. 
    You may put a function before one of the frames, but only one callback function per animation will be registered.
    That function will be called when that frame is drawn. 
    It comes with the sprite's id as argument.
    This can be used to trigger effects in the middle of the animation. If you loop the animation,
    then the callback will be called only in the first cycle.


```
create_tile_layer({
    id = "my_tile_layer",
    gui = false,
    layer = 1,
    position = { x = 16, y = 16 },
    tile_dimensions = { width = 16, height = 16 },
    rows = 8,
    columns = 10,
    texture = "tiles",
    tiles = {
      {x=0,y=0}, {x=1,y=0}, {x=2,y=0}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=0,y=1}, {x=1,y=1}, {x=2,y=1}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=0,y=2}, {x=1,y=2}, {x=2,y=2}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
      {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4}, {x=4,y=4},
    },
    on_input = function(event) 
      return false
    end,
  })
```
A tile layer is an entity with many sections of equal size disposed in a grid. You can use it to draw tiled maps. 
If you use many tile layers in different game layers, you will have a layered map with ground, ceiling, and all that. 
Just like with sprites, all tiles must be in the same image file, have the same size and be disposed one next to the other
in such a way that you can refer to each of them with coordinates.

- tile_dimensions: the width and height of the tiles.
- rows: how many rows.
- columns: how many columns.
- texture: the key to the texture file.
- tiles: a list of coordinates to each tile. The size of this list should be rows * columns.


# Manipulation functions

```
remove_entity(id)
```
The previous section showed how to create various types of entities. This is the function you use to remove them.
Just pass the id for the entity you want out.


```
move_entity(id, delta_x, delta_y)
```
This moves an entity on the screen. The delta values are the amount it will move.


```
resize_entity(id, delta_w, delta_h)
```
This resizes an entity by the delta amount. This only works on Panel and Segmented Panels right now.


```
set_position(id, x, y)
```
Change the position of an entity.


```
set_dimensions(id, width, height)
```
Change the dimensions of an entity. It only works with Panels and Segmented Panels for now.



```
set_panel_texture({
  id = "my_panel",
  texture = {
    texture = "gui",
    position = { x = 0, y = 0 },
    dimensions = { width = 16, height = 16 },
  },
  })
```
This changes the texture of a panel. It is similar to create_panel.


```
set_segmented_panel_texture({
  id = "my_seg_panel",
  texture = {
    texture = "gui",
    position = { x = 192, y = 0 },
    border_size = 4,
    interior = { width = 8, height = 8 },
  },
  })
```
This changes the texture of a segmented panel. It is similar to create_segmented_panel.


```
set_tile(id, x, y, tx, ty)
```
This function changes the tile of a Tile Layer. The tile to change is in coordinates x, y. 
The new tile is in coordinates tx, ty.


```
get_entity(id)
```
Return an object with information about an entity as follows:
- id: the id of the entity
- gui: bool, whether the id is drawn on the gui view.
- layer: the layer it is drawn on
- type: the type of the entity. This is a string and may be 'panel', 'segmented_panel', 'text', 'sprite' or 'tile_layer'.
- position: x, y position on the screen
- dimensions: width, height of the entity



```
sprite_start_animation(id, key, loop)
```
This function starts an animation for a Sprite entity.
Pass the key for the animation you ant to play and check whether it will loop or play just once.
An animation that loops keeps playing even after it has finished.
If you play an animation that doesn't loop, then, after it finishes, 
a previously set looping animation will resume playing.


```
sprite_stop_animation(id)
```
Stop an animation from a Sprite entity.


```
get_tile_under_cursor(id)
```
This returns an object {x, y} with the coordinates of the tile your mouse cursor was over for a specific Tile Layer.


```
get_game_mouse_position()
```
This returns an object {x, y} with the pixel position of your mouse cursor on the game view.


```
get_gui_mouse_position()
```
This returns an object {x, y} with the pixel position of your mouse cursor on the gui view.


```
pan_game_view(delta_x, delta_y)
```
Pan, or scroll, the game view.


```
set_show_outline(
  {
    id = "my_sprite",
    show = true,
    color = { r = 255, g = 255, b = 255, a = 255 },
  }
)
```
Show the outline of an entity. It is useful to know its bounds and where you have to place the mouse cursor
in order to trigger its on_input method. Color is optional. It's default to black.


```
set_show_origin(
  {
    id = "my_sprite",
    show = true,
    color = { r = 255, g = 255, b = 255, a = 255 },
  }
)
```
Show the origin point of an entity. Color is optional and defaults to black.


```
set_draw_entities_ordered_by_position(2, true)
```
Sometimes using layers is not enough to draw entities in the order you want. If the game uses
a top-down perspective, or isometric, entities closest to you should appear on top of those farther away in order
to maintain the sense of perspective. Use this function for that. If you set a layer to true,
the game will reorder entities to draw them from top to bottom, right to left.
In engine this is achieved by quick-sorting all entities in that layer every frame before drawing them.
The sorting doesn't take more time than the drawing itself, so there isn't any noticeable delay.
If you want to stop that, then set the layer to false. This functionality is only available for the game view.




```
set_origin("my_entity", w / 2, h / 2)
```

Change the origin point of an entity. It affects the position of the entity and its rotation.
By default it is on the top left corner. If you want to position it in the
middle of the entity, then set it to half its width and half its height.


```
get_rotation("my_entity")
```
Get the rotation an entity is at. The value comes in degrees, so you might want to convert it to radians afterward.
The default is 0, and it goes positive rotating clockwise, until it gets to 0 again, which is 360 degrees.


```
rotate_entity("my_entity", angle)
```
This rotates an entity over its origin point. Angles are given in degrees,
so if your angle is in radians, you have to convert it to degrees.
A positive angle rotates clockwise, and a negative angle rotates anti-clockwise.
