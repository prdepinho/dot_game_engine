#include "TileMap.h"
#include "Resources.h"
#include <tmxlite/Map.hpp>
#include <tmxlite/TileLayer.hpp>
#include <tmxlite/ObjectGroup.hpp>
#include "Game.h"

TileMap::TileMap() {}
TileMap::~TileMap() {}

TileLayer::TileLayer(
	int x,
	int y,
	int tile_width,
	int tile_height,
	int rows,
	int columns,
	std::vector<Tile> tiles,
	std::string texture,
	std::map<int, TileLayer::Animation> animations
)
	: tile_width(tile_width), tile_height(tile_height), rows(rows), columns(columns), tiles(tiles), texture(texture), animations(animations)
{
	set_position(x, y);
	set_dimensions(columns * tile_width, rows * tile_height);
	show_outline(1, 1, sf::Color::White);
}

TileLayer::~TileLayer() { }

void TileLayer::build() {
	set_texture(&Resources::get_texture(texture));
	vertices.setPrimitiveType(sf::Quads);
	vertices.resize(4 * rows * columns);

	for (int y = 0; y < rows; y++) {
		for (int x = 0; x < columns; x++) {
			Tile &tile = tiles[x + y * columns];
			set_quad(
				&vertices[(x + y * columns) * 4],
				(float)(x * tile_width), (float)(y * tile_height),
				(float)tile_width, (float)tile_height,
				(float)tile.texture_x * tile_width, (float)tile.texture_y * tile_height,
				(float)tile_width, (float)tile_height
			);
		}
	}
}

void TileLayer::update(float elapsed_time) {
	for (auto it = animations.begin(); it != animations.end(); ++it) {
		TileLayer::Animation &animation = it->second;
		if ((animation.count += elapsed_time) >= animation.seconds_per_frame) {
			animation.count = 0.f;
			++animation.frame %= animation.tiles.size();

			int tx = animation.tiles[animation.frame].texture_x;
			int ty = animation.tiles[animation.frame].texture_y;

			for (auto place : animation.places) {
				set_tile(place.x, place.y, tx, ty);
			}

		}
	}
}

void TileLayer::set_tile(
	int tile_x,
	int tile_y,
	int texture_x,
	int texture_y
) {
	set_quad(
		&vertices[(tile_x + tile_y * columns) * 4],
		(float)(tile_x * tile_width), (float)(tile_y * tile_height),
		(float)tile_width, (float)tile_height,
		(float)texture_x * tile_width, (float)texture_y * tile_height,
		(float)tile_width, (float)tile_height
	);
}




TileMap MapLoader::load(std::string filename) {
	TileMap map;
	tmx::Map tmx_map;
	if (!tmx_map.load(filename))
		throw MapLoader::Exception("Could not load map [" + filename + "].");

	std::vector<tmx::Tileset> tilesets = tmx_map.getTilesets();
	if (tilesets.size() != 1)
		throw MapLoader::Exception("Map [" + filename + "] has " + std::to_string(tilesets.size()) + " tilesets, but it is necessary to be only one.");

	tmx::Tileset tileset = tilesets[0];
	unsigned int columns = tmx_map.getTileCount().x;
	unsigned int rows = tmx_map.getTileCount().y;
	unsigned int tile_width = tileset.getTileSize().x;
	unsigned int tile_height = tileset.getTileSize().y;


	ScreenView map_view = ScreenView::GAME_VIEW;
	for (auto &prop : tmx_map.getProperties()) {
		if (prop.getName() == "view") {
			if (prop.getStringValue() == "game")
				map_view = ScreenView::GAME_VIEW;
			else if (prop.getStringValue() == "gui")
				map_view = ScreenView::GUI_VIEW;
		}
	}


	int layer_count = 0;

	for (const tmx::Layer::Ptr &layer_ptr : tmx_map.getLayers()) {

		if (layer_ptr->getType() == tmx::TileLayer::Type::Tile) {
			std::string layer_id = layer_ptr->getName();
			std::vector<TileLayer::Tile> tiles;
			std::map<int, TileLayer::Animation> animations;

			for (unsigned int y = 0; y < rows; y++) {
				for (unsigned int x = 0; x < columns; x++) {
					const tmx::Tileset::Tile *tile = tileset.getTile(layer_ptr->getLayerAs<tmx::TileLayer>().getTiles()[y * columns + x].ID);
					if (tile) {
						if (tile->animation.frames.size() > 0) {

							const tmx::Tileset::Tile *frame_tile = tileset.getTile(tile->animation.frames[0].tileID);
							int px = (int)(frame_tile->imagePosition.x / tile_width);
							int py = (int)(frame_tile->imagePosition.y / tile_height);
							tiles.push_back({ px, py });

							TileLayer::Animation &animation = animations[py * 1000 + px];
							animation.texture_x = px;
							animation.texture_y = py;

							for (const tmx::Tileset::Tile::Animation::Frame &frame : tile->animation.frames) {
								frame_tile = tileset.getTile(frame.tileID);
								if (frame_tile) {
									animation.seconds_per_frame = (float)frame.duration / 1000;
									animation.tiles.push_back({ (int)(frame_tile->imagePosition.x / tile_width), (int)(frame_tile->imagePosition.y / tile_height) });
									animation.places.push_back({ (int)x, (int)y });
								}
							}
						}
						else {
							tiles.push_back({ (int)(tile->imagePosition.x / tile_width), (int)(tile->imagePosition.y / tile_height) });
						}
					}
					else {
						tiles.push_back({ 0, 0 });
					}
				}
			}

			for (auto &prop : layer_ptr->getProperties()) {
				if (prop.getName() == "layer")
					layer_count = prop.getIntValue();
			}

			{
				int x = 0;
				int y = 0;
				Game::get_screen().add_tile_layer(layer_id, map_view, layer_count++, x, y, (int)tile_width, (int)tile_height, rows, columns, tiles, tileset.getName(), animations);
			}

		}

	}

	return map;
}
