#include "LuaExporter.h"
#include "Resources.h"
#include "Game.h"
#include "Sprite.h"
#include "TileMap.h"
#include "AStar.h"
#include <stdio.h>
#include <string>
#include <iostream>

namespace LuaExporter {

	static int close_game(lua_State *state) {
		Game::close();
		return 1;
	}

	static int resources_load_texture(lua_State *state) {
		std::string key = lua_tostring(state, -3);
		std::string path = lua_tostring(state, -2);
		bool smooth = lua_toboolean(state, -1);
		bool rval = Resources::load_texture(key, path, smooth);
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
		LuaObject obj = Lua::get().get_child_object();
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

			int x = elm.get_int("x");
			int y = elm.get_int("y");
			int w = elm.get_int("w");
			int f = elm.get_int("f", w);
			int b = elm.get_int("b", 0);

			int letter_code = 0;

			LuaObject *letter_obj = elm.get_object("letter");
			switch (letter_obj->get_type()) {
			case LuaObject::STRING: {
					std::string letter = letter_obj->get_string();
					memcpy(&letter_code, letter.c_str(), letter.size());
				}
				break;
			case LuaObject::NUMBER:
			case LuaObject::INTEGER:
				letter_code = letter_obj->get_int();
				break;
			}

			Resources::set_font_letter(key, letter_code, x + ox, y + oy, w, f, b);
		}

		lua_pushboolean(state, true);
		return 1;
	}



	static int create_sprite(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
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
			LuaObject obj = Lua::get().get_child_object();
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
			LuaObject obj = Lua::get().get_child_object();
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
			LuaObject obj = Lua::get().get_child_object();
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
			LuaObject obj = Lua::get().get_child_object();
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

	static int create_layered_panel(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);
			int width = obj.get_int("dimensions.width");
			int height = obj.get_int("dimensions.height");

			std::vector<LayeredPanel::Layer> layers;
			LuaObject *layer_list = obj.get_object("layers");
			for (int i = 0; i < layer_list->size(); i++) {
				LuaObject &tile_obj = (*layer_list)[i];
				int layer_x = tile_obj.get_int("x", 0);
				int layer_y = tile_obj.get_int("y", 0);
				int layer_width = tile_obj.get_int("width", width);
				int layer_height = tile_obj.get_int("height", height);
				int texture_x = tile_obj.get_int("texture.x");
				int texture_y = tile_obj.get_int("texture.y");
				int texture_width = tile_obj.get_int("texture.width", width);
				int texture_height = tile_obj.get_int("texture.height", height);
				layers.push_back({ 
					layer_x, layer_y,
					layer_width, layer_height,
					texture_x, texture_y,
					texture_width, texture_height
					});
			}
			std::string texture = obj.get_string("texture");
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;
			screen.add_layered_panel(id, view, layer, x, y, width, height, layers, texture);

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not create layered panel. " << e.what() << std::endl;
		}
		return 1;
	}

	static int create_tile_layer(lua_State *state) {
		TileMap &tilemap = Game::get_screen().get_tilemap();
		const tmx::Tileset &tileset = tilemap.tmx_map.getTilesets()[0];
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			int layer = obj.get_int("layer");
			int x = obj.get_int("position.x");
			int y = obj.get_int("position.y");
			bool gui = obj.get_boolean("gui", false);

			int tile_width = obj.get_int("tile_dimensions.width");
			int tile_height = obj.get_int("tile_dimensions.height");
			int rows = obj.get_int("rows");
			int columns = obj.get_int("columns");

			int texture_column_count = tileset.getColumnCount();

			std::string texture = obj.get_string("texture");
			ScreenView view = gui ? ScreenView::GUI_VIEW : ScreenView::GAME_VIEW;

			std::vector<TileLayer::Tile> tiles;
			LuaObject *tile_list = obj.get_object("tiles");
			for (int i = 0; i < tile_list->size(); i++) {
				LuaObject &tile_obj = (*tile_list)[i];
				unsigned int tile_id = (unsigned int)tile_obj.get_int();
				int texture_x = tile_id % texture_column_count;
				int texture_y = tile_id / texture_column_count;
				tiles.push_back({ tile_id, texture_x, texture_y });
			}

			screen.add_tile_layer(id, view, layer, x, y, tile_width, tile_height, rows, columns, texture_column_count, tiles, texture);

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
		std::string layer_id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			layer_id = lua_tostring(state, -4);
			int x = (int)lua_tointeger(state, -3);
			int y = (int)lua_tointeger(state, -2);
			unsigned int tile_id = (unsigned int)lua_tointeger(state, -1);
			screen.set_tile(layer_id, x, y, tile_id);
		}
		catch (LuaException &e) {
			std::cout << "Could not create tile from tile layer: '" << layer_id << "'. " << e.what() << std::endl;
		}
		return 1;
	}


	static int set_panel_texture(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			int texture_x = obj.get_int("texture.position.x");
			int texture_y = obj.get_int("texture.position.y");
			int texture_width = obj.get_int("texture.dimensions.width");
			int texture_height = obj.get_int("texture.dimensions.height");
			std::string texture = obj.get_string("texture.texture");
			screen.set_panel_texture(id, texture_x, texture_y, texture_width, texture_height, texture);
		}
		catch (LuaException &e) {
			std::cout << "Could not set panel texture: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_segmented_panel_texture(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			int texture_x = obj.get_int("texture.position.x");
			int texture_y = obj.get_int("texture.position.y");
			int border_size = obj.get_int("texture.border_size");
			int interior_width = obj.get_int("texture.interior.width");
			int interior_height = obj.get_int("texture.interior.height");
			std::string texture = obj.get_string("texture.texture");
			screen.set_segmented_panel_texture(id, texture_x, texture_y, border_size, interior_width, interior_height, texture);
		}
		catch (LuaException &e) {
			std::cout << "Could not set segmented panel texture: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_layered_panel_texture(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");

			std::vector<LayeredPanel::Layer> layers;
			LuaObject *layer_list = obj.get_object("layers");
			for (int i = 0; i < layer_list->size(); i++) {
				LuaObject &tile_obj = (*layer_list)[i];
				int layer_x = tile_obj.get_int("x", 0);
				int layer_y = tile_obj.get_int("y", 0);
				int layer_width = tile_obj.get_int("width");
				int layer_height = tile_obj.get_int("height");
				int texture_x = tile_obj.get_int("texture.x");
				int texture_y = tile_obj.get_int("texture.y");
				int texture_width = tile_obj.get_int("texture.width", layer_width);
				int texture_height = tile_obj.get_int("texture.height", layer_height);
				layers.push_back({ 
					layer_x, layer_y,
					layer_width, layer_height,
					texture_x, texture_y,
					texture_width, texture_height
					});
			}
			std::string texture = obj.get_string("texture");
			screen.set_layered_panel_texture(id, layers, texture);
		}
		catch (LuaException &e) {
			std::cout << "Could not set layered panel texture. " << e.what() << std::endl;
		}
		return 1;
	}

	static int get_entity(lua_State *state) {
		std::string id = lua_tostring(state, -1);

		Entity *entity = Game::get_screen().get_entity(id);
		if (entity) {
			ScreenEntity &screen_entity = Game::get_screen().get_screen_entity(id);
			int layer = screen_entity.layer;
			bool gui = screen_entity.view == ScreenView::GUI_VIEW ? true : false;
			std::string type = "";

			switch (screen_entity.type) {
			case EntityType::PANEL: type = "panel"; break;
			case EntityType::SEGMENTED_PANEL: type = "segmented_panel"; break;
			case EntityType::TEXT: type = "text"; break;
			case EntityType::SPRITE: type = "sprite"; break;
			case EntityType::TILE_LAYER: type = "tile_layer"; break;
			}

			int width = entity->get_width();
			int height = entity->get_height();
			int x = entity->get_x();
			int y = entity->get_y();

			lua_newtable(state);

			lua_pushstring(state, "id");
			lua_pushstring(state, id.c_str());
			lua_settable(state, -3);

			lua_pushstring(state, "layer");
			lua_pushinteger(state, layer);
			lua_settable(state, -3);

			lua_pushstring(state, "gui");
			lua_pushboolean(state, gui);
			lua_settable(state, -3);

			lua_pushstring(state, "type");
			lua_pushstring(state, type.c_str());
			lua_settable(state, -3);

			lua_pushstring(state, "position");
			{
				lua_newtable(state);

				lua_pushstring(state, "x");
				lua_pushinteger(state, x);
				lua_settable(state, -3);

				lua_pushstring(state, "y");
				lua_pushinteger(state, y);
				lua_settable(state, -3);
			}
			lua_settable(state, -3);

			lua_pushstring(state, "dimensions");
			{
				lua_newtable(state);

				lua_pushstring(state, "width");
				lua_pushinteger(state, width);
				lua_settable(state, -3);

				lua_pushstring(state, "height");
				lua_pushinteger(state, height);
				lua_settable(state, -3);
			}
			lua_settable(state, -3);

		}
		else {
			lua_pushnil(state);
		}
		return 1;
	}

	static int get_focused_entity(lua_State *state) {
		ScreenEntity* screen_entity = Game::get_screen().get_focused_entity();
		Entity* entity = screen_entity != nullptr ? screen_entity->entity : nullptr;

		if (entity) {
			int layer = screen_entity->layer;
			bool gui = screen_entity->view == ScreenView::GUI_VIEW ? true : false;
			std::string type = "";

			switch (screen_entity->type) {
			case EntityType::PANEL: type = "panel"; break;
			case EntityType::SEGMENTED_PANEL: type = "segmented_panel"; break;
			case EntityType::TEXT: type = "text"; break;
			case EntityType::SPRITE: type = "sprite"; break;
			case EntityType::TILE_LAYER: type = "tile_layer"; break;
			}

			int width = entity->get_width();
			int height = entity->get_height();
			int x = entity->get_x();
			int y = entity->get_y();

			lua_newtable(state);

			lua_pushstring(state, "id");
			lua_pushstring(state, screen_entity->id.c_str());
			lua_settable(state, -3);

			lua_pushstring(state, "layer");
			lua_pushinteger(state, layer);
			lua_settable(state, -3);

			lua_pushstring(state, "gui");
			lua_pushboolean(state, gui);
			lua_settable(state, -3);

			lua_pushstring(state, "type");
			lua_pushstring(state, type.c_str());
			lua_settable(state, -3);

			lua_pushstring(state, "position");
			{
				lua_newtable(state);

				lua_pushstring(state, "x");
				lua_pushinteger(state, x);
				lua_settable(state, -3);

				lua_pushstring(state, "y");
				lua_pushinteger(state, y);
				lua_settable(state, -3);
			}
			lua_settable(state, -3);

			lua_pushstring(state, "dimensions");
			{
				lua_newtable(state);

				lua_pushstring(state, "width");
				lua_pushinteger(state, width);
				lua_settable(state, -3);

				lua_pushstring(state, "height");
				lua_pushinteger(state, height);
				lua_settable(state, -3);
			}
			lua_settable(state, -3);

		}
		else {
			lua_pushnil(state);
		}
		return 1;
	}

	static int is_focused_entity(lua_State *state) {
		std::string id = lua_tostring(state, -1);
		ScreenEntity* screen_entity = Game::get_screen().get_focused_entity();
		bool is_focused = screen_entity != nullptr && screen_entity->id == id;
		lua_pushboolean(state, is_focused);
		return 1;
	}

	static int set_focused_entity(lua_State *state) {
		const char *id = lua_tostring(state, -1);

		if (id == nullptr) {
			Game::get_screen().set_focused_entity(nullptr);
		}
		else {
			Entity *entity = Game::get_screen().get_entity(std::string(id));
			ScreenEntity &screen_entity = Game::get_screen().get_screen_entity(std::string(id));
			Game::get_screen().set_focused_entity(&screen_entity);
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

	static int set_position(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		float x = (float)lua_tonumber(state, -2);
		float y = (float)lua_tonumber(state, -1);
		// Game::get_screen().set_position(id, x, y);
		Game::get_screen().get_entity(id)->setPosition(x, y);
		return 1;
	}

	static int set_dimensions(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		int w = (int)lua_tointeger(state, -2);
		int h = (int)lua_tointeger(state, -1);
		Game::get_screen().set_dimensions(id, w, h);
		return 1;
	}

	static int get_text(lua_State *state) {
		std::string id = lua_tostring(state, -2);
		std::string text = Game::get_screen().get_text(id);
		lua_pushstring(state, text.c_str());
		return 1;
	}

	static int set_text(lua_State *state) {
		std::string id = lua_tostring(state, -2);
		std::string text = lua_tostring(state, -1);
		Game::get_screen().set_text(id, text);
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

	static int entity_contains(lua_State* state) {
		std::string id = lua_tostring(state, -3);
		float pix_x = (float)lua_tonumber(state, -2);
		float pix_y = (float)lua_tonumber(state, -1);
		bool contains = Game::get_screen().is_within_entity_gobal_bounds(id, pix_x, pix_y);
		lua_pushboolean(state, contains);
		return 1;
	}

	static int get_tile(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		float pix_x = (float)lua_tonumber(state, -2);
		float pix_y = (float)lua_tonumber(state, -1);

		Screen &screen = Game::get_screen();

		sf::Vector2i tile;

		Entity *entity = screen.get_entity(id);
		if (entity) {
			TileLayer *layer = dynamic_cast<TileLayer *>(entity);
			tile.x = (int)((pix_x - layer->get_x()) / layer->get_tile_width());
			tile.y = (int)((pix_y - layer->get_y()) / layer->get_tile_height());

			lua_newtable(state);

			lua_pushstring(state, "id");
			lua_pushinteger(state, layer->get_tile_id(tile.x, tile.y));
			lua_settable(state, -3);

			lua_pushstring(state, "x");
			lua_pushinteger(state, tile.x);
			lua_settable(state, -3);

			lua_pushstring(state, "y");
			lua_pushinteger(state, tile.y);
			lua_settable(state, -3);

		}
		return 1;
	}

	static int get_tile_under_cursor(lua_State *state) {
		std::string id = lua_tostring(state, -1);
		auto pos = Game::get_screen().get_tile_coords_under_cursor(id);

		Screen &screen = Game::get_screen();
		Entity *entity = screen.get_entity(id);
		if (entity) {
			TileLayer *layer = dynamic_cast<TileLayer *>(entity);

			lua_newtable(state);

			lua_pushstring(state, "id");
			lua_pushinteger(state, layer->get_tile_id(pos.x, pos.y));
			lua_settable(state, -3);

			lua_pushstring(state, "x");
			lua_pushinteger(state, pos.x);
			lua_settable(state, -3);

			lua_pushstring(state, "y");
			lua_pushinteger(state, pos.y);
			lua_settable(state, -3);
		}

		return 1;
	}


	static int get_tile_texture(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		int x = (int)lua_tointeger(state, -2);
		int y = (int)lua_tointeger(state, -1);

		Screen &screen = Game::get_screen();

		sf::Vector2i ptile;

		Entity *entity = screen.get_entity(id);
		if (entity) {
			TileLayer *layer = dynamic_cast<TileLayer *>(entity);
			ptile = layer->get_tile(x, y);

			lua_newtable(state);

			lua_pushstring(state, "x");
			lua_pushinteger(state, ptile.x);
			lua_settable(state, -3);

			lua_pushstring(state, "y");
			lua_pushinteger(state, ptile.y);
			lua_settable(state, -3);

		}
		return 1;
	}

	static int get_tile_properties(lua_State *state) {
		unsigned int tile_id = (unsigned int) lua_tointeger(state, -1);

		TileMap &tilemap = Game::get_screen().get_tilemap();
		const tmx::Tileset &tileset = tilemap.tmx_map.getTilesets()[0];

		int local_id = tile_id + tileset.getFirstGID();
		const tmx::Tileset::Tile *tile = tileset.getTile(local_id);

		std::vector<tmx::Property> properties = tile != nullptr ? tile->properties : std::vector<tmx::Property>();

		lua_newtable(state);
		for (const tmx::Property& prop : properties) {
			lua_pushstring(state, prop.getName().c_str());
			switch (prop.getType()) {
			case tmx::Property::Type::String:
				lua_pushstring(state, prop.getStringValue().c_str());
				break;
			case tmx::Property::Type::Int:
				lua_pushinteger(state, prop.getIntValue());
				break;
			case tmx::Property::Type::Float:
				lua_pushnumber(state, prop.getFloatValue());
				break;
			case tmx::Property::Type::Boolean:
				lua_pushboolean(state, prop.getBoolValue());
				break;
			case tmx::Property::Type::Colour:
				lua_newtable(state);

				lua_pushstring(state, "r");
				lua_pushinteger(state, prop.getColourValue().r);
				lua_settable(state, -3);

				lua_pushstring(state, "g");
				lua_pushinteger(state, prop.getColourValue().g);
				lua_settable(state, -3);

				lua_pushstring(state, "b");
				lua_pushinteger(state, prop.getColourValue().b);
				lua_settable(state, -3);

				lua_pushstring(state, "a");
				lua_pushinteger(state, prop.getColourValue().a);
				lua_settable(state, -3);

				break;
			case tmx::Property::Type::File:
				lua_pushstring(state, prop.getFileValue().c_str());
				break;
			}
			lua_settable(state, -3);
		}
		return 1;
	}

	static int pan_game_view(lua_State *state) {
		float delta_x = (float)lua_tonumber(state, -2);
		float delta_y = (float)lua_tonumber(state, -1);
		Game::get_screen().pan_game_view({ delta_x, delta_y });
		return 1;
	}

	static int set_show_outline(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			bool show = obj.get_boolean("show");
			int r = obj.get_int("color.r", 0);
			int g = obj.get_int("color.g", 0);
			int b = obj.get_int("color.b", 0);
			int a = obj.get_int("color.a", 255);
			sf::Color color(r, g, b, a);
			screen.set_show_outline(id, show, color);
		}
		catch (LuaException &e) {
			std::cout << "Could not set show outline: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_show_origin(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();
			id = obj.get_string("id");
			bool show = obj.get_boolean("show");
			int r = obj.get_int("color.r", 0);
			int g = obj.get_int("color.g", 0);
			int b = obj.get_int("color.b", 0);
			int a = obj.get_int("color.a", 255);
			sf::Color color(r, g, b, a);
			screen.set_show_origin(id, show, color);
		}
		catch (LuaException &e) {
			std::cout << "Could not set show origin: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_draw_entities_ordered_by_position(lua_State *state) {
		int layer = (int)lua_tointeger(state, -2);
		bool order = lua_toboolean(state, -1);
		Game::get_screen().set_draw_in_position_order(layer, order);
		return 1;
	}

	static int rotate_entity(lua_State *state) {
		std::string id = lua_tostring(state, -2);
		float angle = (float)lua_tonumber(state, -1);
		Entity *entity = Game::get_screen().get_entity(id);
		if (entity)
			entity->rotate(angle);
		return 1;
	}

	static int get_rotation(lua_State *state) {
		std::string id = lua_tostring(state, -1);
		Entity *entity = Game::get_screen().get_entity(id);
		float rotation = 0.f;
		if (entity)
			rotation = entity->getRotation();
		lua_pushnumber(state, rotation);
		return 1;
	}

	static int set_origin(lua_State *state) {
		std::string id = lua_tostring(state, -3);
		float origin_x = (float)lua_tonumber(state, -2);
		float origin_y = (float)lua_tonumber(state, -1);
		Entity *entity = Game::get_screen().get_entity(id);
		if (entity)
			entity->setOrigin({origin_x, origin_y});
		return 1;
	}

	static int set_tilemap_path(lua_State *state) {
		std::string path = lua_tostring(state, -1);
		Resources::set_tilemap_path(path);
		return 1;
	}

	static int load_tilemap(lua_State *state) {
		std::string map_name = lua_tostring(state, -3);
		int x = (int)lua_tointeger(state, -2);
		int y = (int)lua_tointeger(state, -1);

		Game::get_screen().load_tilemap(map_name, x, y);
		return 1;
	}

	static int get_tilemap_dimensions(lua_State *state) {
		TileMap &tilemap = Game::get_screen().get_tilemap();
		lua_newtable(state);

		lua_pushstring(state, "rows");
		lua_pushinteger(state, tilemap.rows);
		lua_settable(state, -3);

		lua_pushstring(state, "columns");
		lua_pushinteger(state, tilemap.columns);
		lua_settable(state, -3);
		return 1;
	}

	static int remove_tilemap(lua_State *state) {
		Game::get_screen().remove_tilemap();
		return 1;
	}

	static int get_map_properties(lua_State *state) {
		TileMap &tilemap = Game::get_screen().get_tilemap();
		lua_newtable(state);
		for (auto &prop : tilemap.tmx_map.getProperties()) {
			lua_pushstring(state, prop.getName().c_str());
			switch (prop.getType()) {
			case tmx::Property::Type::String:
				lua_pushstring(state, prop.getStringValue().c_str());
				break;
			case tmx::Property::Type::Int:
				lua_pushinteger(state, prop.getIntValue());
				break;
			case tmx::Property::Type::Float:
				lua_pushnumber(state, prop.getFloatValue());
				break;
			case tmx::Property::Type::Boolean:
				lua_pushboolean(state, prop.getBoolValue());
				break;
			case tmx::Property::Type::Colour:
				lua_newtable(state);

				lua_pushstring(state, "r");
				lua_pushinteger(state, prop.getColourValue().r);
				lua_settable(state, -3);

				lua_pushstring(state, "g");
				lua_pushinteger(state, prop.getColourValue().g);
				lua_settable(state, -3);

				lua_pushstring(state, "b");
				lua_pushinteger(state, prop.getColourValue().b);
				lua_settable(state, -3);

				lua_pushstring(state, "a");
				lua_pushinteger(state, prop.getColourValue().a);
				lua_settable(state, -3);

				break;
			case tmx::Property::Type::File:
				lua_pushstring(state, prop.getFileValue().c_str());
				break;
			}
			lua_settable(state, -3);
		}
		return 1;
	}

	static int get_map_object(lua_State *state) {
		std::string layer = lua_tostring(state, -2);
		std::string name = lua_tostring(state, -1);
		TileMap &tilemap = Game::get_screen().get_tilemap();
		for (const tmx::Layer::Ptr &layer_ptr : tilemap.tmx_map.getLayers()) {
			if (layer == layer_ptr->getName()) {

				for (const tmx::Object &object : layer_ptr->getLayerAs<tmx::ObjectGroup>().getObjects()) {

					if (name == object.getName()) {

						lua_newtable(state);

						lua_pushstring(state, "properties");
						{
							lua_newtable(state);
							for (auto &prop : object.getProperties()) {
								lua_pushstring(state, prop.getName().c_str());
								switch (prop.getType()) {
								case tmx::Property::Type::String:
									lua_pushstring(state, prop.getStringValue().c_str());
									break;
								case tmx::Property::Type::Int:
									lua_pushinteger(state, prop.getIntValue());
									break;
								case tmx::Property::Type::Float:
									lua_pushnumber(state, prop.getFloatValue());
									break;
								case tmx::Property::Type::Boolean:
									lua_pushboolean(state, prop.getBoolValue());
									break;
								case tmx::Property::Type::Colour:
									lua_newtable(state);

									lua_pushstring(state, "r");
									lua_pushinteger(state, prop.getColourValue().r);
									lua_settable(state, -3);

									lua_pushstring(state, "g");
									lua_pushinteger(state, prop.getColourValue().g);
									lua_settable(state, -3);

									lua_pushstring(state, "b");
									lua_pushinteger(state, prop.getColourValue().b);
									lua_settable(state, -3);

									lua_pushstring(state, "a");
									lua_pushinteger(state, prop.getColourValue().a);
									lua_settable(state, -3);

									break;
								case tmx::Property::Type::File:
									lua_pushstring(state, prop.getFileValue().c_str());
									break;
								}
								lua_settable(state, -3);
							}
						}
						lua_settable(state, -3);

						lua_pushstring(state, "name");
						lua_pushstring(state, object.getName().c_str());
						lua_settable(state, -3);

						lua_pushstring(state, "position");
						{
							lua_newtable(state);

							lua_pushstring(state, "x");
							lua_pushinteger(state, (int)object.getPosition().x);
							lua_settable(state, -3);

							lua_pushstring(state, "y");
							lua_pushinteger(state, (int)object.getPosition().y);
							lua_settable(state, -3);
						}
						lua_settable(state, -3);

						lua_pushstring(state, "type");
						switch (object.getShape()) {
						case tmx::Object::Shape::Rectangle:
							lua_pushstring(state, "rectangle");
							break;
						case tmx::Object::Shape::Point:
							lua_pushstring(state, "point");
							break;
						case tmx::Object::Shape::Ellipse:
							lua_pushstring(state, "ellipse");
							break;
						case tmx::Object::Shape::Polygon:
							lua_pushstring(state, "polygon");
							break;
						case tmx::Object::Shape::Text:
							lua_pushstring(state, "text");
							break;
						case tmx::Object::Shape::Polyline:
							lua_pushstring(state, "polyline");
							break;
						}
						lua_settable(state, -3);

						lua_pushstring(state, "text");
						lua_pushstring(state, object.getText().content.c_str());
						lua_settable(state, -3);

						lua_pushstring(state, "AABB");
						{
							auto aabb = object.getAABB();
							lua_newtable(state);

							lua_pushstring(state, "left");
							lua_pushnumber(state, aabb.left);
							lua_settable(state, -3);

							lua_pushstring(state, "top");
							lua_pushnumber(state, aabb.top);
							lua_settable(state, -3);

							lua_pushstring(state, "width");
							lua_pushnumber(state, aabb.width);
							lua_settable(state, -3);

							lua_pushstring(state, "heigh");
							lua_pushnumber(state, aabb.height);
							lua_settable(state, -3);

						}
						lua_settable(state, -3);

						lua_pushstring(state, "points");
						{
							lua_newtable(state);

							int i = 0;
							for (auto &point : object.getPoints()) {
								lua_pushinteger(state, i++);
								{
									lua_newtable(state);

									lua_pushstring(state, "x");
									lua_pushnumber(state, point.x);
									lua_settable(state, -3);

									lua_pushstring(state, "y");
									lua_pushnumber(state, point.y);
									lua_settable(state, -3);

								}
								lua_settable(state, -3);
							}
						}
						lua_settable(state, -3);

						return 1;
					}

				}
			}
		}
		return 1;
	}


	static int set_callback(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
			id = obj.get_string("id");

			LuaObject *callback = obj.get_token("on_input");
			if (callback->get_type() == LuaObject::Type::FUNCTION) {
				screen.set_entity_callback(id, *callback);
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not set callback: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int load_shader_fragment(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
			id = obj.get_string("id");
			std::string path = obj.get_string("path");

			Entity *entity = Game::get_screen().get_entity(id);
			entity->set_shader(path);
		}
		catch (LuaException &e) {
			std::cout << "Could not set shader fragment to: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_shader_uniform(lua_State *state) {
		std::string id = "undefined";
		try {
			Screen &screen = Game::get_screen();
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
			id = obj.get_string("id");

			Entity *entity = Game::get_screen().get_entity(id);
			sf::Shader &shader = entity->get_shader();

			LuaObject *uniform_list = obj.get_object("uniforms");
			for (int i = 0; i < uniform_list->size(); i++) {
				LuaObject &uniform_obj = (*uniform_list)[i];
				std::string type = uniform_obj.get_string("type");
				std::string key = uniform_obj.get_string("key");

				if (type == "vec4") {
					float x = uniform_obj.get_float("value.x", 0.f);
					float y = uniform_obj.get_float("value.y", 0.f);
					float z = uniform_obj.get_float("value.z", 0.f);
					float w = uniform_obj.get_float("value.w", 0.f);
					sf::Glsl::Vec4 value(x, y, z, w);
					shader.setUniform(key, value);
				}
				else if (type == "vec3") {
					float x = uniform_obj.get_float("value.x", 0.f);
					float y = uniform_obj.get_float("value.y", 0.f);
					float z = uniform_obj.get_float("value.z", 0.f);
					sf::Glsl::Vec3 value(x, y, z);
					shader.setUniform(key, value);
				}
				else if (type == "vec2") {
					float x = uniform_obj.get_float("value.x", 0.f);
					float y = uniform_obj.get_float("value.y", 0.f);
					sf::Glsl::Vec2 value(x, y);
					shader.setUniform(key, value);
				}
				else if (type == "float") {
					float value = uniform_obj.get_float("value", 0.f);
					shader.setUniform(key, value);
				}
				else if (type == "int") {
					int value = uniform_obj.get_int("value", 0);
					shader.setUniform(key, value);
				}
				else if (type == "bool") {
					bool value = uniform_obj.get_boolean("value", false);
					shader.setUniform(key, value);
				}
				else if (type == "texture") {
					std::string texture_name = uniform_obj.get_string("value");
					const sf::Texture& texture = Resources::get_texture(texture_name);
					shader.setUniform(key, texture);
				}
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not set shader uniform to: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_entity_view(lua_State* state) {
		std::string id = "undefined";
		try {
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
			id = obj.get_string("id");
			int x = obj.get_int("position.x", 0);
			int y = obj.get_int("position.y", 0);
			int w = obj.get_int("dimensions.width", 0);
			int h = obj.get_int("dimensions.height", 0);

			Screen &screen = Game::get_screen();
			screen.set_entity_view(id, x, y, w, h);
		}
		catch (LuaException &e) {
			std::cout << "Could not set entity " << id << " view: '" << e.what() << std::endl;
		}
		return 1;
	}

	static int remove_entity_view(lua_State* state) {
		std::string id = "undefined";
		try {
			id = lua_tostring(state, -1);
			Screen &screen = Game::get_screen();
			screen.remove_entity_view(id);
		}
		catch (LuaException &e) {
			std::cout << "Could not remove entity " << id << " view: '" << e.what() << std::endl;
		}
		return 1;
	}

	static int pan_entity_view(lua_State* state) {
		std::string id = "undefined";
		try {
			id = lua_tostring(state, -3);
			float delta_x = (float)lua_tonumber(state, -2);
			float delta_y = (float)lua_tonumber(state, -1);
			Game::get_screen().pan_entity_view(id, { delta_x, delta_y });
		}
		catch (LuaException &e) {
			std::cout << "Could not pan entity " << id << " view: '" << e.what() << std::endl;
		}
		return 1;
	}

	static int find_path(lua_State *state) {
		try {
			LuaObject obj = Lua::get().get_child_object();  // TODO: may leak lua functions if throws an exception or there are more than one function among animations. And all creation functions with callbacks too
			int rows = obj.get_int("rows");
			int columns = obj.get_int("columns");
			int start_x = obj.get_int("start.x");
			int start_y = obj.get_int("start.y");
			int end_x = obj.get_int("destination.x");
			int end_y = obj.get_int("destination.y");

			std::vector<bool> graph(rows * columns);

			LuaObject *node_list = obj.get_object("graph");
			for (size_t i = 0; i < node_list->size(); i++) {
				LuaObject &node_obj = (*node_list)[i];
				bool is_free_node = node_obj.get_boolean();
				graph[i] = is_free_node;
			}

			std::stack<sf::Vector2i> path = AStar::search(graph, columns, { start_x, start_y }, { end_x, end_y });

			int index = 1;
			lua_newtable(state);
			while (!path.empty()) {
				sf::Vector2i node = path.top();

				lua_pushinteger(state, index);

				{
					lua_newtable(state);

					lua_pushstring(state, "x");
					lua_pushinteger(state, node.x);
					lua_settable(state, -3);

					lua_pushstring(state, "y");
					lua_pushinteger(state, node.y);
					lua_settable(state, -3);
				}

				lua_settable(state, -3);

				path.pop();
				index++;
			}
		}
		catch (LuaException &e) {
			std::cout << "Could not find path: " << e.what() << std::endl;
		}
		return 1;
	}


	static int set_map_tile(lua_State *state) {
		std::string layer_id = "undefined";
		try {
			layer_id = lua_tostring(state, -4);
			int x = (int)lua_tointeger(state, -3);
			int y = (int)lua_tointeger(state, -2);
			unsigned int tile_id = (unsigned int)lua_tointeger(state, -1);

			MapLoader::set_tile(Game::get_screen().get_tilemap(), layer_id, x, y, tile_id);
		}
		catch (LuaException &e) {
			std::cout << "Could not create tile from tile layer: '" << layer_id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int set_entity_visibility(lua_State *state) {
		std::string id = "undefined";
		try {
			id = lua_tostring(state, -2);
			bool visible = lua_toboolean(state, -1);
			Game::get_screen().set_entity_visibility(id, visible);
		}
		catch (LuaException &e) {
			std::cout << "Could not set entity visibility: '" << id << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int zoom_game_view(lua_State *state) {
		float delta;
		try {
			delta = (float)lua_tonumber(state, -1);
			Game::get_screen().get_game_view().zoom(delta);
		}
		catch (LuaException &e) {
			std::cout << "Could not zoom: '" << delta << "'. " << e.what() << std::endl;
		}
		return 1;
	}

	static int toggle_fullscreen(lua_State *state) {
		try {
			if (Game::get().is_fullscreen()) {
				Game::get().set_window();
			}
			else {
				Game::get().set_window();
			}
		}
		catch (LuaException &e) {
			std::cout << "Could toggle fullscreen: '" << e.what() << std::endl;
		}
		return 1;
	}

	static int get_screen_dimensions(lua_State* state) {
		int height = Game::get().get_screen_height();
		int width = Game::get().get_screen_width();
		lua_newtable(state);

		lua_pushstring(state, "height");
		lua_pushinteger(state, height);
		lua_settable(state, -3);

		lua_pushstring(state, "width");
		lua_pushinteger(state, width);
		lua_settable(state, -3);

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
	lua_register(lua.get_state(), "create_layered_panel", LuaExporter::create_layered_panel);
	lua_register(lua.get_state(), "create_text_line", LuaExporter::create_text_line);
	lua_register(lua.get_state(), "create_text_block", LuaExporter::create_text_block);
	lua_register(lua.get_state(), "create_tile_layer", LuaExporter::create_tile_layer);

	lua_register(lua.get_state(), "set_tilemap_path", LuaExporter::set_tilemap_path);
	lua_register(lua.get_state(), "load_tilemap", LuaExporter::load_tilemap);
	lua_register(lua.get_state(), "get_tilemap_dimensions", LuaExporter::get_tilemap_dimensions);
	lua_register(lua.get_state(), "remove_tilemap", LuaExporter::remove_tilemap);
	lua_register(lua.get_state(), "get_map_properties", LuaExporter::get_map_properties);
	lua_register(lua.get_state(), "get_map_object", LuaExporter::get_map_object);
	lua_register(lua.get_state(), "set_map_tile", LuaExporter::set_map_tile);

	lua_register(lua.get_state(), "find_path", LuaExporter::find_path);

	lua_register(lua.get_state(), "set_entity_visibility", LuaExporter::set_entity_visibility);
	lua_register(lua.get_state(), "get_entity", LuaExporter::get_entity);
	lua_register(lua.get_state(), "get_focused_entity", LuaExporter::get_focused_entity);
	lua_register(lua.get_state(), "is_focused_entity", LuaExporter::is_focused_entity);
	lua_register(lua.get_state(), "set_focused_entity", LuaExporter::set_focused_entity);
	lua_register(lua.get_state(), "remove_entity", LuaExporter::remove_entity);
	lua_register(lua.get_state(), "move_entity", LuaExporter::move_entity);
	lua_register(lua.get_state(), "resize_entity", LuaExporter::resize_entity);
	lua_register(lua.get_state(), "rotate_entity", LuaExporter::rotate_entity);
	lua_register(lua.get_state(), "get_rotation", LuaExporter::get_rotation);
	lua_register(lua.get_state(), "set_panel_texture", LuaExporter::set_panel_texture);
	lua_register(lua.get_state(), "set_segmented_panel_texture", LuaExporter::set_segmented_panel_texture);
	lua_register(lua.get_state(), "set_layered_panel_texture", LuaExporter::set_layered_panel_texture);
	lua_register(lua.get_state(), "set_tile", LuaExporter::set_tile);
	lua_register(lua.get_state(), "set_position", LuaExporter::set_position);
	lua_register(lua.get_state(), "set_dimensions", LuaExporter::set_dimensions);
	lua_register(lua.get_state(), "set_show_origin", LuaExporter::set_show_origin);
	lua_register(lua.get_state(), "set_show_outline", LuaExporter::set_show_outline);
	lua_register(lua.get_state(), "get_text", LuaExporter::get_text);
	lua_register(lua.get_state(), "set_text", LuaExporter::set_text);
	lua_register(lua.get_state(), "sprite_start_animation", LuaExporter::sprite_start_animation);
	lua_register(lua.get_state(), "sprite_stop_animation", LuaExporter::sprite_stop_animation);
	lua_register(lua.get_state(), "get_tile", LuaExporter::get_tile);
	lua_register(lua.get_state(), "get_tile_under_cursor", LuaExporter::get_tile_under_cursor);
	lua_register(lua.get_state(), "entity_contains", LuaExporter::entity_contains);
	lua_register(lua.get_state(), "get_tile_texture", LuaExporter::get_tile_texture);
	lua_register(lua.get_state(), "get_tile_properties", LuaExporter::get_tile_properties);
	lua_register(lua.get_state(), "set_origin", LuaExporter::set_origin);
	lua_register(lua.get_state(), "set_callback", LuaExporter::set_callback);
	lua_register(lua.get_state(), "load_shader_fragment", LuaExporter::load_shader_fragment);
	lua_register(lua.get_state(), "set_shader_uniform", LuaExporter::set_shader_uniform);
	lua_register(lua.get_state(), "set_entity_view", LuaExporter::set_entity_view);
	lua_register(lua.get_state(), "remove_entity_view", LuaExporter::remove_entity_view);
	lua_register(lua.get_state(), "pan_entity_view", LuaExporter::pan_entity_view);

	lua_register(lua.get_state(), "get_game_mouse_position", LuaExporter::get_game_mouse_position);
	lua_register(lua.get_state(), "get_gui_mouse_position", LuaExporter::get_gui_mouse_position);
	lua_register(lua.get_state(), "pan_game_view", LuaExporter::pan_game_view);
	lua_register(lua.get_state(), "set_draw_entities_ordered_by_position", LuaExporter::set_draw_entities_ordered_by_position);
	lua_register(lua.get_state(), "zoom_game_view", LuaExporter::zoom_game_view);

	lua_register(lua.get_state(), "toggle_fullscreen", LuaExporter::toggle_fullscreen);
	lua_register(lua.get_state(), "get_screen_dimensions", LuaExporter::get_screen_dimensions);
}

