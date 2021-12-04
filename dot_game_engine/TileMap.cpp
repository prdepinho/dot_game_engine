#include "TileMap.h"
#include "Resources.h"

TileLayer::TileLayer(
	int x,
	int y,
	int tile_width,
	int tile_height,
	int rows,
	int columns,
	std::vector<Tile> tiles,
	std::string texture
)
	: tile_width(tile_width), tile_height(tile_height), rows(rows), columns(columns), tiles(tiles), texture(texture)
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

