#include "Screen.h"
#include "Game.h"
#include <iostream>
#include <cstdlib>
#include "Resources.h"


Screen::Screen(sf::RenderWindow *window) : window(window), created(false) {
}

Screen::~Screen() {
	if (created)
		destroy();
}

void Screen::destroy() { }

void Screen::create() {
	created = true;
	game_view.setSize(sf::Vector2f((float) Game::get_screen_width(), (float) Game::get_screen_height()));
	game_view.setCenter(sf::Vector2f((float) Game::get_screen_width() / 2.f, (float) Game::get_screen_height() / 2.f));
	gui_view.setSize(sf::Vector2f((float) Game::get_screen_width(), (float) Game::get_screen_height()));
	gui_view.setCenter((float)Game::get_screen_width() / 2.f, (float) Game::get_screen_height() / 2.f);
}

void Screen::update(float elapsed_time) {
	window->setView(game_view);
	for (auto map : game_entities) {
		for (auto entity : map) {
			entity.second->update(elapsed_time);
		}
	}
	window->setView(gui_view);
	for (auto map : gui_entities) {
		for (auto entity : map) {
			entity.second->update(elapsed_time);
		}
	}

	for (std::string &id : delete_buffer)
		delete_entity(id);
	delete_buffer.clear();

	for (std::string &id : erase_buffer)
		erase_entity(id);
	erase_buffer.clear();
}

void Screen::draw() {
	window->setView(game_view);
	for (int layer = 0; layer < game_entities.size(); layer++) {
		auto &map = game_entities[layer];
		if (layers_to_order_by_position[layer]) {
			std::vector<Entity *> ordered_entities = order_by_position(layer);
			for (auto entity : ordered_entities) {
				window->draw(*entity);
			}
		}
		else {
			for (auto entity : map) {
				window->draw(*entity.second);
			}
		}
	}
	window->setView(gui_view);
	for (auto map : gui_entities) {
		for (auto entity : map) {
			window->draw(*entity.second);
		}
	}
}

void Screen::poll_events(float elapsed_time) {
	sf::Event event;
	while (window->pollEvent(event)) {
		if (window->hasFocus()) {
			std::string event_type = "";
			int key = event.key.code;
			int button = event.mouseButton.button;
			int x = event.mouseMove.x;
			int y = event.mouseMove.y;
			float delta = event.mouseWheelScroll.delta;

			switch (event.type) {
			case sf::Event::Closed:
				window->close();
				break;
			case sf::Event::KeyPressed:
				event_type = "key_down";
				break;
			case sf::Event::KeyReleased:
				event_type = "key_up";
				break;
			case sf::Event::MouseButtonPressed:
				event_type = "mouse_button_down";
				break;
			case sf::Event::MouseButtonReleased:
				event_type = "mouse_button_up";
				break;
			case sf::Event::MouseMoved:
				event_type = "mouse_moved";
				break;
			case sf::Event::MouseWheelScrolled:
				if (event.mouseWheelScroll.wheel == sf::Mouse::VerticalWheel) 
					event_type = "mouse_scrolled";
				break;
			}

			// callback entity input events if mouse is over it, gui first, higher layers first, only one callback
			// also check cursor enter and cursor exit
			if (event_type != "") {
				bool rval = false;
				for (auto it = gui_entities.rbegin(); it != gui_entities.rend(); ++it) {
					for (auto that : *it) {
						ScreenEntity &entity = entity_map[that.first];
						if (is_mouse_over_entity(that.second, ScreenView::GUI_VIEW)) {
							if (!rval) {
								rval = entity.callback.entity_input_callback(event_type, elapsed_time, key, button, x, y, delta);
								if (!entity.cursor_in)
									rval = entity.callback.entity_input_callback("mouse_cursor_enter", elapsed_time, key, button, x, y, delta);
								entity.cursor_in = true;
							}
						}
						else {
							if (entity.cursor_in)
								rval = entity.callback.entity_input_callback("mouse_cursor_exit", elapsed_time, key, button, x, y, delta);
							entity.cursor_in = false;
						}
					}
				}
				for (auto it = game_entities.rbegin(); it != game_entities.rend(); ++it) {
					for (auto that : *it) {
						ScreenEntity &entity = entity_map[that.first];
						if (is_mouse_over_entity(that.second, ScreenView::GAME_VIEW)) {
							if (!rval) {
								rval = entity.callback.entity_input_callback(event_type, elapsed_time, key, button, x, y, delta);
								if (!entity.cursor_in)
									rval = entity.callback.entity_input_callback("mouse_cursor_enter", elapsed_time, key, button, x, y, delta);
								entity.cursor_in = true;
							}
						}
						else {
							if (entity.cursor_in)
								rval = entity.callback.entity_input_callback("mouse_cursor_exit", elapsed_time, key, button, x, y, delta);
							entity.cursor_in = false;
						}
					}
				}

				// callback on_input
				if (!rval)
					Lua::get().run_on_input(event_type, elapsed_time, key, button, x, y, delta);
			}
		}
	}
}


void Screen::add_panel(
	std::string id,
	ScreenView view,
	int layer,
	int x,
	int y,
	int width,
	int height,
	int texture_x,
	int texture_y,
	int texture_width,
	int texture_height,
	std::string texture
) {
	Panel *panel = new Panel(x, y, width, height, texture_x, texture_y, texture_width, texture_height, texture);
	entity_map[id].entity = panel;
	entity_map[id].type = EntityType::PANEL;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	panel->build();
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::add_segmented_panel(
	std::string id,
	ScreenView view,
	int layer,
	int x,
	int y,
	int width,
	int height,
	int texture_x,
	int texture_y,
	int border_size,
	int interior_width,
	int interior_height,
	std::string texture
) {
	SegmentedPanel *seg_panel = new SegmentedPanel(x, y, width, height, texture_x, texture_y, border_size, interior_width, interior_height, texture);
	entity_map[id].entity = seg_panel;
	entity_map[id].type = EntityType::SEGMENTED_PANEL;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	seg_panel->build();
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::add_text_line(
	std::string id,
	ScreenView view,
	int layer,
	int x,
	int y,
	std::string text,
	std::string font,
	sf::Color color
) {
	Text *text_obj = new Text(font);
	entity_map[id].entity = text_obj;
	entity_map[id].type = EntityType::TEXT;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	text_obj->build();
	text_obj->write_line(x, y, text, color);
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::add_text_block(
	std::string id,
	ScreenView view,
	int layer,
	int x,
	int y,
	int line_length,
	std::string text,
	std::string font,
	sf::Color color
) {
	Text *text_obj = new Text(font);
	entity_map[id].entity = text_obj;
	entity_map[id].type = EntityType::TEXT;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	text_obj->build();
	text_obj->write_block(x, y, line_length, text, color);
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::add_sprite(
	std::string id,
	ScreenView view,
	int layer,
	int x,
	int y,
	int width,
	int height,
	AnimationResources resources) 
{
	Sprite *sprite = new Sprite(id, x, y, width, height, resources);
	entity_map[id].entity = sprite;
	entity_map[id].type = EntityType::SPRITE;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	sprite->build();
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::add_tile_layer(
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
	std::string texture,
	std::map<int, TileLayer::Animation> animations
) {
	TileLayer *tile_layer = new TileLayer(x, y, tile_width, tile_height, rows, columns, tiles, texture, animations);
	entity_map[id].entity = tile_layer;
	entity_map[id].type = EntityType::TILE_LAYER;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	tile_layer->build();
	add_entity(entity_map[id].entity, id, view, layer);
}

void Screen::load_tilemap(std::string map_name, int x, int y) {
	if (tilemap.name == map_name)
		return;
	remove_tilemap();
	MapLoader::load(tilemap, map_name, x, y);
}

void Screen::remove_tilemap() {
	for (const std::string &tile_layer_id : tilemap.tile_layer_ids) {
		remove_entity(tile_layer_id);
	}
	tilemap = TileMap();
}

void Screen::set_tile(
	std::string id,
	int tile_x,
	int tile_y,
	int texture_x,
	int texture_y
) {
	if (entity_map[id].type == EntityType::TILE_LAYER)
		dynamic_cast<TileLayer *>(entity_map[id].entity)->set_tile(tile_x, tile_y, texture_x, texture_y);
}

void Screen::set_panel_texture(
	std::string id,
	int texture_x,
	int texture_y,
	int texture_width,
	int texture_height,
	std::string texture
) {
	dynamic_cast<Panel *>(entity_map[id].entity)->change_skin(texture_x, texture_y, texture_width, texture_height, texture);
}

void Screen::set_segmented_panel_texture(
	std::string id,
	int texture_x,
	int texture_y,
	int border_size,
	int interior_width,
	int interior_height,
	std::string texture
) {
	dynamic_cast<SegmentedPanel *>(entity_map[id].entity)->change_skin(texture_x, texture_y, border_size, interior_width, interior_height, texture);
}

void Screen::add_entity(Entity *entity, std::string id, ScreenView view, int layer) {
	switch (view) {
	case ScreenView::GAME_VIEW:
		if (game_entities.size() <= layer)
			game_entities.resize(layer + 1);
		game_entities[layer][id] = entity;
		break;
	case ScreenView::GUI_VIEW:
		if (gui_entities.size() <= layer)
			gui_entities.resize(layer + 1);
		gui_entities[layer][id] = entity;
		break;
	}
}

void Screen::move_entity(std::string id, float delta_x, float delta_y) {
	get_entity(id)->move({ delta_x, delta_y });
}

void Screen::resize_entity(std::string id, float delta_x, float delta_y) {
	Entity *entity = get_entity(id);
	entity->set_dimensions((int) (entity->get_width() + delta_x), (int) (entity->get_height() + delta_y));
	entity->build();
}

std::string Screen::get_text(std::string id) {
	ScreenEntity &screen_entity = entity_map[id];
	if (screen_entity.type == EntityType::TEXT)
		return dynamic_cast<Text *>(screen_entity.entity)->get_text();
	return "";
}

void Screen::set_text(std::string id, std::string text) {
	ScreenEntity &screen_entity = entity_map[id];
	if (screen_entity.type == EntityType::TEXT)
		dynamic_cast<Text *>(screen_entity.entity)->set_text(text);
}

void Screen::remove_entity(std::string id) {
	delete_buffer.push_back(id);
}

Entity *Screen::get_entity(std::string id) {
	ScreenView view = entity_map[id].view;
	int layer = entity_map[id].layer;
	switch (view) {
	case ScreenView::GAME_VIEW:
		return game_entities[layer][id];
	case ScreenView::GUI_VIEW:
		return gui_entities[layer][id];
	}
	return nullptr;
}

ScreenEntity &Screen::get_screen_entity(std::string id) {
	return entity_map[id];
}

Sprite *Screen::get_sprite(std::string id) {
	if (entity_map[id].type == EntityType::SPRITE)
		return dynamic_cast<Sprite *>(entity_map[id].entity);
	return nullptr;
}

void Screen::set_show_outline(std::string id, bool show, sf::Color color) {
	Entity *entity = get_entity(id);
	if (entity) {
		if (show)
			entity->show_outline(1, 0, color);
		else
			entity->hide_outline();
	}
}

void Screen::set_show_origin(std::string id, bool show, sf::Color color) {
	Entity *entity = get_entity(id);
	if (entity) {
		if (show)
			entity->show_origin(1, color);
		else
			entity->hide_origin();
	}
}

bool Screen::is_mouse_over_entity(Entity *entity, ScreenView view) {
	switch (view) {
	case ScreenView::GAME_VIEW:
		{
			auto mouse = get_mouse_game_position();
			return entity->in_bounds((int)mouse.x, (int)mouse.y);
		}
		break;
	case ScreenView::GUI_VIEW:
		{
			auto mouse = get_mouse_gui_position();
			return entity->in_bounds((int)mouse.x, (int)mouse.y);
		}
		break;
	}
	return false;
}

void Screen::set_entity_callback(std::string id, LuaObject callback) {
	if (get_entity(id))
		entity_map[id].callback = callback;
}

void Screen::set_position(std::string id, int x, int y) {
	Entity *entity = get_entity(id);
	if (entity)
		entity->set_position(x, y);
}

void Screen::set_dimensions(std::string id, int w, int h) {
	Entity *entity = get_entity(id);
	if (entity) {
		entity->set_dimensions(w, h);
		entity->build();
	}
}

void Screen::start_animation(std::string id, std::string key, bool loop) {
	if (get_entity(id)) {
		if (loop)
			dynamic_cast<Sprite *>(entity_map[id].entity)->loop_animation(key);
		else
			dynamic_cast<Sprite *>(entity_map[id].entity)->start_animation(key);
	}
}

void Screen::stop_animation(std::string id) {
	if (get_entity(id))
		dynamic_cast<Sprite *>(entity_map[id].entity)->stop_animation();
}

sf::Vector2f Screen::get_mouse_gui_position() {
	window->setView(gui_view);
	return window->mapPixelToCoords(sf::Mouse::getPosition(*window));
}

sf::Vector2f Screen::get_mouse_game_position() {
	window->setView(game_view);
	return window->mapPixelToCoords(sf::Mouse::getPosition(*window));
}

void Screen::pan_game_view(sf::Vector2f v) {
	game_view.move(v);
}

sf::Vector2i Screen::get_tile_coords_under_cursor(std::string id) {
	ScreenEntity &entity = entity_map[id];
	int tile_x = 0;
	int tile_y = 0;
	if (entity.type == EntityType::TILE_LAYER) {
		sf::Vector2f cursor;
		switch (entity.view) {
		case ScreenView::GAME_VIEW:
			cursor = get_mouse_game_position();
			break;
		case ScreenView::GUI_VIEW:
			cursor = get_mouse_gui_position();
			break;
		}
		TileLayer *tile_layer = dynamic_cast<TileLayer *>(entity.entity);
		tile_x = (int)((cursor.x - tile_layer->get_x()) / tile_layer->get_tile_width());
		tile_y = (int)((cursor.y - tile_layer->get_y()) / tile_layer->get_tile_height());
	}
	return { tile_x, tile_y };
}

// Returns the gui position of coordinates in the game map. TODO: take zoom into account.
sf::Vector2f Screen::get_gui_position_over_game(float x, float y) {
	auto gui_center = gui_view.getCenter();
	auto gui_size = gui_view.getSize();
	sf::Vector2f gui_origin = {gui_center.x - gui_size.x / 2, gui_center.y - gui_size.y / 2};

	auto game_center = game_view.getCenter();
	auto game_size = game_view.getSize();
	sf::Vector2f game_origin = {game_center.x - game_size.x / 2, game_center.y - game_size.y / 2};

	sf::Vector2f diff = { gui_origin.x - game_origin.x, gui_origin.y - game_origin.y };
	return sf::Vector2f{ x + diff.x, y + diff.y };
}

void Screen::erase_entity(std::string id) {
	ScreenEntity &entity = entity_map[id];
	switch (entity.view) {
	case ScreenView::GAME_VIEW:
		game_entities[entity.layer].erase(id);
		break;
	case ScreenView::GUI_VIEW:
		gui_entities[entity.layer].erase(id);
		break;
	}
}

void Screen::delete_entity(std::string id) {
	ScreenEntity &entity = entity_map[id];
	switch (entity.view) {
	case ScreenView::GAME_VIEW:
		game_entities[entity.layer].erase(id);
		break;
	case ScreenView::GUI_VIEW:
		gui_entities[entity.layer].erase(id);
		break;
	}
	entity_map.erase(id);
}

static bool compare_entityes_by_position(Entity *a, Entity *b) {
	// print from top right to bottom left
	return (b->get_x() + a->get_y() * 1000) < (a->get_x() + b->get_y() * 1000);
}

std::vector<Entity *> Screen::order_by_position(int layer) {
	std::vector<Entity *> ordered_entities;
	for (auto &pair : game_entities[layer]) {
		Entity *entity = pair.second;
		ordered_entities.push_back(entity);
	}
	std::sort(ordered_entities.begin(), ordered_entities.end(), compare_entityes_by_position);
	return ordered_entities;
}

void Screen::set_draw_in_position_order(int layer, bool order) {
	layers_to_order_by_position[layer] = order;
}
