#pragma once
#include <vector>
#include <string>
#include "Panel.h"
#include "TileMap.h"
#include "Text.h"
#include "Lua.h"
#include "Sprite.h"

enum EntityType {
	PANEL,
	SEGMENTED_PANEL,
	TEXT,
	SPRITE,
	TILE_LAYER
};

enum ScreenView {
	GAME_VIEW,
	GUI_VIEW
};

struct ScreenEntity {
	virtual ~ScreenEntity() {
		if (entity)
			delete entity; 
		callback.delete_functions();
	}
	Entity *entity = nullptr;
	EntityType type;
	ScreenView view;
	int layer;
	LuaObject callback;
	bool cursor_in = false;
};

class Screen
{
public:
	Screen(sf::RenderWindow *window = nullptr);
	virtual ~Screen();

	void create();
	void destroy();
	void poll_events(float elased_time);
	void update(float fElapsedTime);
	void draw();

	void set_window(sf::RenderWindow *window) { this->window = window; }

	sf::View &get_game_view() { return game_view; }
	sf::View &get_gui_view() { return gui_view; }

	sf::Vector2f get_mouse_gui_position(); 
	sf::Vector2f get_mouse_game_position();
	sf::Vector2f get_gui_position_over_game(float x, float y);
	void pan_game_view(sf::Vector2f v);

	void add_panel(
		std::string id,
		ScreenView view,
		int layer,
		int x = 0,
		int y = 0,
		int width = 0,
		int height = 0,
		int texture_x = 0,
		int texture_y = 0,
		int texture_width = 0,
		int texture_height = 0,
		std::string texture = "gui"
	);

	void add_segmented_panel(
		std::string id,
		ScreenView view,
		int layer,
		int x = 0,
		int y = 0,
		int width = 0,
		int height = 0,
		int texture_x = 0,
		int texture_y = 0,
		int border_size = 0,
		int interior_width = 0,
		int interior_height = 0,
		std::string texture = "gui"
	);

	void add_text_line(
		std::string id,
		ScreenView view,
		int layer,
		int x,
		int y,
		std::string text,
		std::string font,
		sf::Color color
	);

	void add_text_block(
		std::string id,
		ScreenView view,
		int layer,
		int x,
		int y,
		int line_length,
		std::string text,
		std::string font,
		sf::Color color
	);

	void add_sprite(
		std::string id,
		ScreenView view,
		int layer,
		int x,
		int y,
		int width,
		int height,
		AnimationResources resources
	);

	void add_tile_layer(
		std::string id,
		ScreenView view,
		int layer,
		int x,
		int y,
		int tile_width,
		int tile_height,
		int rows,
		int columns,
		std::vector<TileLayer::Tile> tiles,
		std::string texture
	);


	void set_tile(
		std::string id,
		int tile_x,
		int tile_y,
		int texture_x,
		int texture_y
	);

	void set_panel_texture(
		std::string id, 
		int texture_x = 0,
		int texture_y = 0,
		int texture_width = 0,
		int texture_height = 0,
		std::string texture = "gui"
	);

	void set_segmented_panel_texture(
		std::string id, 
		int texture_x = 0,
		int texture_y = 0,
		int border_size = 0,
		int interior_width = 0,
		int interior_height = 0,
		std::string texture = "gui"
	);
	void add_entity(Entity *entity, std::string id, ScreenView view, int layer);

	void move_entity(std::string id, float x, float y);
	void resize_entity(std::string id, float x, float y);
	void remove_entity(std::string id);
	void set_entity_callback(std::string id, LuaObject callback);
	void set_position(std::string id, int x, int y);
	void set_dimensions(std::string id, int w, int h);
	std::string get_text(std::string id);
	void set_text(std::string, std::string text);

	void start_animation(std::string id, std::string key, bool loop);
	void stop_animation(std::string id);

	Entity *get_entity(std::string id);
	Sprite *get_sprite(std::string id);
	void set_show_outline(std::string id, bool show, sf::Color color);
	void set_show_origin(std::string id, bool show, sf::Color color);

	ScreenEntity &get_screen_entity(std::string id);

	bool is_mouse_over_entity(Entity *entity, ScreenView view);
	sf::Vector2i get_tile_coords_under_cursor(std::string id);

	std::vector<Entity *> order_by_position(int layer);
	void set_draw_in_position_order(int layer, bool order);

private:
	void erase_entity(std::string id);		// remove an entity from views, but maintain it in the entity_map
	void delete_entity(std::string id);		// delete an entity entirely

private:
	sf::View game_view;
	sf::View gui_view;
	sf::RenderWindow *window;
	bool created;

	std::vector< std::map<std::string, Entity*> > game_entities;
	std::vector< std::map<std::string, Entity*> > gui_entities;

	std::map<std::string, ScreenEntity> entity_map;


	std::vector<std::string> erase_buffer;
	std::vector<std::string> delete_buffer;

	std::map<int, bool> layers_to_order_by_position;
};

