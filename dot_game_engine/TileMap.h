#pragma once
#include "Entity.h"
#include <exception>
#include <tmxlite/Map.hpp>
#include <tmxlite/TileLayer.hpp>
#include <tmxlite/ObjectGroup.hpp>

struct TileMap {
	std::string name;
	std::vector<std::string> tile_layer_ids;
	tmx::Map tmx_map;
};


class TileLayer : public Entity {
public:
	struct Tile {
		int texture_x;
		int texture_y;
	};

	struct VectorCmp {
		constexpr bool operator()(const sf::Vector2i &lhs, const sf::Vector2i &rhs) const {
			return (lhs.y * 1000 + lhs.x) < (rhs.y * 1000 + rhs.x);
		}
	};

	struct Animation {
		int texture_x = 0;
		int texture_y = 0;
		std::map<sf::Vector2i, bool, TileLayer::VectorCmp> places;
		std::vector<Tile> tiles;
		int frame = 0;
		float count = 0.f;
		float seconds_per_frame = 0.f;
	};

	TileLayer(
		int x = 0,
		int y = 0,
		int tile_width = 0,
		int tile_height = 0,
		int rows = 0,
		int columns = 0,
		std::vector<Tile> tiles = {},
		std::string texture = "",
		std::map<int, TileLayer::Animation> animations = {}
	);
	virtual ~TileLayer();
	virtual void build() override;
	virtual void update(float elapsed_time) override;

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

	std::map<int, Animation> &get_animations() { return animations; }

private:
	std::string texture;
	int tile_width;
	int tile_height;
	int rows;
	int columns;
	std::vector<Tile> tiles;
	std::map<int, Animation> animations;
};





namespace MapLoader {
	class Exception : public std::exception {
	public:
		Exception(std::string msg) : std::exception(), msg("MapLoaderException: " + msg) {}
		virtual const char *what() const noexcept { return msg.c_str(); }
	protected:
		std::string msg;
	};

	void load(TileMap &tilemap, std::string name, int x, int y);
	void set_tile(TileMap &tilemap, std::string layer_id, int x, int y, int tx, int ty);
}
