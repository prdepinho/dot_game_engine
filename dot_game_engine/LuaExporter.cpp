#include "LuaExporter.h"
#include "Resources.h"
#include "Game.h"
#include "Sprite.h"
#include "TileMap.h"
#include <stdio.h>
#include <string>
#include <iostream>

namespace LuaExporter {

	static int close_game(lua_State *state) {
		Game::close();
		return 1;
	}

	static int resources_load_texture(lua_State *state) {
		std::string key = lua_tostring(state, -2);
		std::string path = lua_tostring(state, -1);
		bool rval = Resources::load_texture(key, path);
		lua_pushboolean(state, rval);
		return 1;
	}

	static int resources_load_sound(lua_State *state) {
		std::string key = lua_tostring(state, -2);
		std::string path = lua_tostring(state, -1);
		bool rval = Resources::load_sound(key, path);
		lua_pushboolean(state, rval);
		return 1;
	}

	static int resources_load_music(lua_State *state) {
		std::string key = lua_tostring(state, -2);
		std::string path = lua_tostring(state, -1);
		bool rval = Resources::load_music(key, path);
		lua_pushboolean(state, rval);
		return 1;
	}

	static int resources_load_font(lua_State *state) {
		LuaObject obj = Game::get_lua().get_child_object();
		std::string key = obj.get_string("key");
		int ox = obj.get_int("origin.x");
		int oy = obj.get_int("origin.y");
		int height = obj.get_int("height");
		int spacing = obj.get_int("spacing");
		std::string texture = obj.get_string("texture");

		Resources::set_font(key, height, spacing, texture);

		std::map<std::string, LuaObject> letters = obj.get_map("letters");
		for (auto it = letters.begin(); it != letters.end(); ++it) {
			LuaObject elm = it->second;

			std::string letter = elm.get_string("letter");
			int x = elm.get_int("x");
			int y = elm.get_int("y");
			int w = elm.get_int("w");
			int f = elm.get_int("f", w);

			int letter_code = 0;
			memcpy(&letter_code, letter.c_str(), letter.size());
			Resources::set_font_letter(key, letter_code, x + ox, y + oy, w, f);
		}

		lua_pushboolean(state, true);
		return 1;
	}



	static int create_sprite(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			int width = obj.get_int("dimensions.width");
			int height = obj.get_int("dimensions.height");
			bool gui = obj.get_boolean("gui", false);
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;

			std::string texture = obj.get_string("sprite.texture");
			int origin_x = obj.get_int("sprite.origin.x");
			int origin_y = obj.get_int("sprite.origin.y");
			int texture_height = obj.get_int("sprite.dimensions.height");
			int texture_width = obj.get_int("sprite.dimensions.width");
			AnimationResources resources;
			resources.texture = texture;
			resources.texture_height = texture_height;
			resources.texture_width = texture_width;
			std::map<std::string, LuaObject> animations = obj.get_map("sprite.animations");
			for (auto it = animations.begin(); it != animations.end(); ++it) {
				std::string key = it->second.get_string("key");
				float fps = (float)it->second.get_float("fps");
				Animation an;
				an.key = key;
				an.fps = fps;

				// std::map<std::string, LuaObject> frames = it->second.get_map("frames");
				// for (auto that = frames.begin(); that != frames.end(); ++that) {
				LuaObject *frame_list = it->second.get_object("frames");
				for (int i = 0; i < frame_list->size(); i++) {
					LuaObject &elm = (*frame_list)[i];
					if (elm.get_type() == LuaObject::FUNCTION) {
						an.activation_frame = i;
						an.callback = elm;
					}
					else {
						int index_x = elm.get_int("x");
						int index_y = elm.get_int("y");
						int texture_x = origin_x + texture_width * index_x;
						int texture_y = origin_y + texture_height * index_y;
						sf::VertexArray vertices;
						vertices.setPrimitiveType(sf::Quads);
						vertices.resize(4 * 1);
						Entity::set_quad(&vertices[0],
							0.f, 0.f,
							(float)texture_width, (float)texture_height,
							(float)texture_x, (float)texture_y,
							(float)texture_width, (float)texture_height
						);
						an.frames.push_back(vertices);
					}
				}
				resources.animations[key] = an;
			}
			screen.add_sprite(id, view, layer, x, y, width, height, resources);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create sprite: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}


	static int create_text_line(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);
			std::string text = obj.get_string("text");
			std::string font = obj.get_string("font");
			int r = obj.get_int("color.r", 0);
			int g = obj.get_int("color.g", 0);
			int b = obj.get_int("color.b", 0);
			int a = obj.get_int("color.a", 255);
			sf::Color color(r, g, b, a);
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;
			screen.add_text_line(id, view, layer, x, y, text, font, color);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create text line: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int create_text_block(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			int line_length = obj.get_int("line_length");
			bool gui = obj.get_boolean("gui", false);
			std::string text = obj.get_string("text");
			std::string font = obj.get_string("font");
			int r = obj.get_int("color.r", 0);
			int g = obj.get_int("color.g", 0);
			int b = obj.get_int("color.b", 0);
			int a = obj.get_int("color.a", 255);
			sf::Color color(r, g, b, a);
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;
			screen.add_text_block(id, view, layer, x, y, line_length, text, font, color);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create text block: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int create_panel(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);
			int width = obj.get_int("dimensions.width");
			int height = obj.get_int("dimensions.height");
			int texture_x = obj.get_int("texture.position.x");
			int texture_y = obj.get_int("texture.position.y");
			int texture_width = obj.get_int("texture.dimensions.width");
			int texture_height = obj.get_int("texture.dimensions.height");
			std::string texture = obj.get_string("texture.texture");
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;
			screen.add_panel(id, view, layer, x, y, width, height, texture_x, texture_y, texture_width, texture_height, texture);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create panel: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int create_segmented_panel(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);
			int width = obj.get_int("dimensions.width");
			int height = obj.get_int("dimensions.height");
			int texture_x = obj.get_int("texture.position.x");
			int texture_y = obj.get_int("texture.position.y");
			int border_size = obj.get_int("texture.border_size");
			int interior_width = obj.get_int("texture.interior.width");
			int interior_height = obj.get_int("texture.interior.height");
			std::string texture = obj.get_string("texture.texture");
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;
			screen.add_segmented_panel(id, view, layer, x, y, width, height, texture_x, texture_y, border_size, interior_width, interior_height, texture);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create segmented panel: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int create_tile_layer(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);

			int tile_width = obj.get_int("tile_dimensions.width");
			int tile_height = obj.get_int("tile_dimensions.height");
			int rows = obj.get_int("rows");
			int columns = obj.get_int("columns");

			std::string texture = obj.get_string("texture");
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;

			std::vector<TileLayer::Tile> tiles;
			LuaObject *tile_list = obj.get_object("tiles");
			for (int i = 0; i < tile_list->size(); i++) {
				LuaObject &tile_obj = (*tile_list)[i];
				int texture_x = tile_obj.get_int("x");
				int texture_y = tile_obj.get_int("y");
				tiles.push_back({ texture_x, texture_y });
			}

			screen.add_tile_layer(id, view, layer, x, y, tile_width, tile_height, rows, columns, tiles, texture);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create tile layer: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_tile(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			id = lua_tostring(state, -5);
			int x = (int)lua_tointeger(state, -4);
			int y = (int)lua_tointeger(state, -3);
			int tx = (int)lua_tointeger(state, -2);
			int ty = (int)lua_tointeger(state, -1);
			screen.set_tile(id, x, y, tx, ty);
		}
		catch (LuaException &e) {
			std::cout << "Could not create tile from tile layer: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}


	static int set_panel_texture(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int texture_x = obj.get_int("position.x");
			int texture_y = obj.get_int("position.y");
			int texture_width = obj.get_int("texture.dimensions.width");
			int texture_height = obj.get_int("texture.dimensions.height");
			std::string texture = obj.get_string("texture.texture");
			screen.set_panel_texture(id, texture_x, texture_y, texture_width, texture_height, texture);
		}
		catch (LuaException &e) {
			std::cout << "Could nto set segmented panel texture: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_segmented_panel_texture(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Game::get_lua().get_child_object();
			id = obj.get_string("id");
			int texture_x = obj.get_int("position.x");
			int texture_y = obj.get_int("position.y");
			int border_size = obj.get_int("border_size");
			int interior_width = obj.get_int("interior.width");
			int interior_height = obj.get_int("interior.height");
			std::string texture = obj.get_string("texture");
			screen.set_segmented_panel_texture(id, texture_x, texture_y, border_size, interior_width, interior_height, texture);
		}
		catch (LuaException &e) {
			std::cout << "Could nto set segmented panel texture: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int remove_entity(lua_State *state) {
		std::string id = lua_tostring(state, -1);
		Game::get_screen().remove_entity(id);
		return 1;
	}

	static int move_entity(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		float delta_x = (float)lua_tonumber(state, -2);
		float delta_y = (float)lua_tonumber(state, -1);
		Game::get_screen().move_entity(id, delta_x, delta_y);
		return 1;
	}

	static int resize_entity(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		float delta_x = (float)lua_tonumber(state, -2);
		float delta_y = (float)lua_tonumber(state, -1);
		Game::get_screen().resize_entity(id, delta_x, delta_y);
		return 1;
	}

	static int get_game_mouse_position(lua_State *state) {
		auto pos = Game::get_screen().get_mouse_game_position();
		lua_newtable(state);

		lua_pushstring(state, "x");
		lua_pushnumber(state, pos.x);
		lua_settable(state, -3);

		lua_pushstring(state, "y");
		lua_pushnumber(state, pos.y);
		lua_settable(state, -3);
		return 1;
	}

	static int get_gui_mouse_position(lua_State *state) {
		auto pos = Game::get_screen().get_mouse_gui_position();
		lua_newtable(state);

		lua_pushstring(state, "x");
		lua_pushnumber(state, pos.x);
		lua_settable(state, -3);

		lua_pushstring(state, "y");
		lua_pushnumber(state, pos.y);
		lua_settable(state, -3);
		return 1;
	}

	static int sprite_start_animation(lua_State *state) {
		auto pos = Game::get_screen().get_mouse_gui_position();
		std::string id = lua_tostring(state, -3);
		std::string key = lua_tostring(state, -2);
		bool loop = lua_toboolean(state, -1);
		Game::get_screen().start_animation(id, key, loop);
		return 1;
	}

	static int sprite_stop_animation(lua_State *state) {
		auto pos = Game::get_screen().get_mouse_gui_position();
		std::string id = lua_tostring(state, -1);
		Game::get_screen().stop_animation(id);
		return 1;
	}

	static int get_tile_under_cursor(lua_State *state) {
		std::string id = lua_tostring(state, -1);
		auto pos = Game::get_screen().get_tile_coords_under_cursor(id);

		lua_newtable(state);

		lua_pushstring(state, "x");
		lua_pushinteger(state, pos.x);
		lua_settable(state, -3);

		lua_pushstring(state, "y");
		lua_pushinteger(state, pos.y);
		lua_settable(state, -3);

		return 1;
	}

	static int pan_game_view(lua_State *state) {
		float delta_x = (float)lua_tonumber(state, -2);
		float delta_y = (float)lua_tonumber(state, -1);
		Game::get_screen().pan_game_view({ delta_x, delta_y });
		return 1;
	}

};

void LuaExporter::register_lua_accessible_functions(Lua &lua) {
	lua_register(lua.get_state(), "close_game", LuaExporter::close_game);

	lua_register(lua.get_state(), "resources_load_texture", LuaExporter::resources_load_texture);
	lua_register(lua.get_state(), "resources_load_sound", LuaExporter::resources_load_sound);
	lua_register(lua.get_state(), "resources_load_music", LuaExporter::resources_load_music);
	lua_register(lua.get_state(), "resources_load_font", LuaExporter::resources_load_font);

	lua_register(lua.get_state(), "create_sprite", LuaExporter::create_sprite);
	lua_register(lua.get_state(), "create_panel", LuaExporter::create_panel);
	lua_register(lua.get_state(), "create_segmented_panel", LuaExporter::create_segmented_panel);
	lua_register(lua.get_state(), "create_text_line", LuaExporter::create_text_line);
	lua_register(lua.get_state(), "create_text_block", LuaExporter::create_text_block);
	lua_register(lua.get_state(), "create_tile_layer", LuaExporter::create_tile_layer);

	lua_register(lua.get_state(), "remove_entity", LuaExporter::remove_entity);
	lua_register(lua.get_state(), "move_entity", LuaExporter::move_entity);
	lua_register(lua.get_state(), "resize_entity", LuaExporter::resize_entity);
	lua_register(lua.get_state(), "set_panel_texture", LuaExporter::set_panel_texture);
	lua_register(lua.get_state(), "set_segmented_panel_texture", LuaExporter::set_segmented_panel_texture);
	lua_register(lua.get_state(), "set_tile", LuaExporter::set_tile);

	lua_register(lua.get_state(), "sprite_start_animation", LuaExporter::sprite_start_animation);
	lua_register(lua.get_state(), "sprite_stop_animation", LuaExporter::sprite_stop_animation);
	lua_register(lua.get_state(), "get_tile_under_cursor", LuaExporter::get_tile_under_cursor);

	lua_register(lua.get_state(), "get_game_mouse_position", LuaExporter::get_game_mouse_position);
	lua_register(lua.get_state(), "get_gui_mouse_position", LuaExporter::get_gui_mouse_position);

	lua_register(lua.get_state(), "pan_game_view", LuaExporter::pan_game_view);
}


/*

- System calls:

close_game()


- Resource loading:

resources_load_texture(key, path)

resources_load_sound(key, path)

resources_load_music(key, path)

resources_load_font({
    key = "small_font",
    origin = { x = 0, y = 0 },
    texture = "gui",
    height = 8,
    spacing = 1,
    letters = {
      { letter = 'A',     x = 1,       y = 12,     w = 4 },
      { letter = 'Q',     x = 160,     y = 12,     w = 7,      f = 5 },
      -- ...
    }
  })


- Entity creation

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
          {
            { x = 0, y = 0 },
            function() print('fires with the second frame') end,
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

create_panel({
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
    on_input = function(event) 
		return false
    end,
  })

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

*/