#include "Screen.h"
#include "Game.h"
#include <iostream>
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
}

void Screen::draw() {
	window->setView(game_view);
	for (auto map : game_entities) {
		for (auto entity : map) {
			window->draw(*entity.second);
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
					Game::get_lua().run_on_input(event_type, elapsed_time, key, button, x, y, delta);
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
	entity_map[id].panel = Panel(x, y, width, height, texture_x, texture_y, texture_width, texture_height, texture);
	entity_map[id].type = EntityType::PANEL;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].panel.build();
	add_entity(&entity_map[id].panel, id, view, layer);
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
	entity_map[id].seg_panel = SegmentedPanel(x, y, width, height, texture_x, texture_y, border_size, interior_width, interior_height, texture);
	entity_map[id].type = EntityType::SEGMENTED_PANEL;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].seg_panel.build();
	add_entity(&entity_map[id].seg_panel, id, view, layer);
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
	entity_map[id].text = Text(font);
	entity_map[id].type = EntityType::TEXT;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].text.build();
	entity_map[id].text.write_line(x, y, text, color);
	add_entity(&entity_map[id].text, id, view, layer);
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
	entity_map[id].text = Text(font);
	entity_map[id].type = EntityType::TEXT;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].text.build();
	entity_map[id].text.write_block(x, y, line_length, text, color);
	add_entity(&entity_map[id].text, id, view, layer);
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
	entity_map[id].sprite = Sprite(id, x, y, width, height, resources);
	entity_map[id].type = EntityType::SPRITE;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].sprite.build();
	add_entity(&entity_map[id].sprite, id, view, layer);
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
	std::string texture
) {
	entity_map[id].tile_layer = TileLayer(x, y, tile_width, tile_height, rows, columns, tiles, texture);
	entity_map[id].type = EntityType::TILE_LAYER;
	entity_map[id].view = view;
	entity_map[id].layer = layer;
	entity_map[id].tile_layer.build();
	add_entity(&entity_map[id].tile_layer, id, view, layer);
}

void Screen::set_tile(
	std::string id,
	int tile_x,
	int tile_y,
	int texture_x,
	int texture_y
) {
	if (entity_map[id].type == EntityType::TILE_LAYER)
		entity_map[id].tile_layer.set_tile(tile_x, tile_y, texture_x, texture_y);
}

void Screen::set_panel_texture(
	std::string id,
	int texture_x,
	int texture_y,
	int texture_width,
	int texture_height,
	std::string texture
) {
	entity_map[id].panel.change_skin(texture_x, texture_y, texture_width, texture_height, texture);
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
	entity_map[id].seg_panel.change_skin(texture_x, texture_y, border_size, interior_width, interior_height, texture);
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

void Screen::remove_entity(std::string id) {
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

Sprite *Screen::get_sprite(std::string id) {
	if (entity_map[id].type == EntityType::SPRITE)
		return &entity_map[id].sprite;
	return nullptr;
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

void Screen::start_animation(std::string id, std::string key, bool loop) {
	if (get_entity(id)) {
		if (loop)
			entity_map[id].sprite.loop_animation(key);
		else
			entity_map[id].sprite.start_animation(key);
	}
}

void Screen::stop_animation(std::string id) {
	if (get_entity(id))
		entity_map[id].sprite.stop_animation();
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
		tile_x = (int)((cursor.x - entity.tile_layer.get_x()) / entity.tile_layer.get_tile_width());
		tile_y = (int)((cursor.y - entity.tile_layer.get_y()) / entity.tile_layer.get_tile_height());
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
