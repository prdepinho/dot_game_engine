#pragma once
#include "Entity.h"

class TileMap
{
};


class TileLayer : public Entity {
public:
	struct Tile {
		int texture_x;
		int texture_y;
	};

	TileLayer(
		int x = 0,
		int y = 0,
		int tile_width = 0,
		int tile_height = 0,
		int rows = 0,
		int columns = 0,
		std::vector<Tile> tiles = {},
		std::string texture = ""
	);
	virtual ~TileLayer();
	virtual void build() override;

	void set_tile(
		int tile_x,
		int tile_y,
		int texture_x,
		int texture_y
	);

	int get_tile_width() const { return tile_width; }
	int get_tile_height() const { return tile_height; }
	int get_rows() const { return rows; }
	int get_columns() const { return columns; }

private:
	std::string texture;
	int tile_width;
	int tile_height;
	int rows;
	int columns;
	std::vector<Tile> tiles;
};
