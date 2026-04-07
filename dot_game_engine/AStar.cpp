#include "AStar.h"
#include "Game.h"

using namespace AStar;

// input: a 2d array with free and blocked tiles, starting and destiny coordinates
// output: a stack of coordinates to follow to get from the start to the destiny
std::stack<sf::Vector2i> AStar::search(std::vector<bool> graph, unsigned int column_count, sf::Vector2i start, sf::Vector2i end, unsigned int limit, bool ignore_obstacles)
{
	const static bool FREE_NODE = true;
	const static bool OBSTACLE_NODE = false;

	static std::vector<std::tuple<int, int>> direction_mods = {
		std::make_tuple(0, -1),  // up
		std::make_tuple(0, +1),  // down
		std::make_tuple(+1, 0),  // right
		std::make_tuple(-1, 0),  // left
		// std::make_tuple(-1, -1), // up-left
		// std::make_tuple(-1, +1), // up-right
		// std::make_tuple(+1, -1), // down-left
		// std::make_tuple(+1, +1), // down-right
	};

	int map_height = (int) (graph.size() / column_count);
	int map_width = column_count;

	if (!in_bounds(end.x, end.y, map_width, map_height)) {
		return std::stack<sf::Vector2i>();
	}

	// treat the dst tile as not obstacle for the algorithm.
	if (!ignore_obstacles) {
		graph[end.x + end.y * column_count] == FREE_NODE;
	}

	std::vector<Node > search_grid(map_width * map_height);
	for (int x = 0; x < map_width; ++x) {
		for (int y = 0; y < map_height; ++y) {
			search_grid[y * map_width + x] = Node(sf::Vector2i(x, y), nullptr);
		}
	}
	search_grid[start.y * map_width + start.x] = Node(start, nullptr, 0.0f, AStar::distance(start, end));

	std::priority_queue < Node*, std::vector<Node*>, NodeComparison > search_queue;
	search_queue.push(&search_grid[start.y * map_width + start.x]);

	Node* dst_node = nullptr;
	while (FAST_A_STAR_LOOP search_queue.size() >= 1) {
		Node* current = search_queue.top();
		if (current->local >= limit) {
			dst_node = current;
			break;
		}

		for (std::tuple<int, int> &mods : direction_mods) {
			int x = current->coords.x + std::get<0>(mods);
			int y = current->coords.y + std::get<1>(mods);
			if (
				in_bounds(x, y, map_width, map_height)
				&&
				(ignore_obstacles || graph[x + y * map_width] != OBSTACLE_NODE)
			) {
				sf::Vector2i neighbor(x, y);
				Node* neighbor_node = &search_grid[neighbor.y * map_width + neighbor.x];

				if (!neighbor_node->visited && neighbor_node->local > current->local + 1) {
					neighbor_node->local = current->local + 1;
					neighbor_node->global = neighbor_node->local + AStar::distance(neighbor, end);
					neighbor_node->parent = current;

					search_queue.push(neighbor_node);

					if (neighbor == end) {
						dst_node = neighbor_node;
					}
				}
			}
		}
		current->visited = true;
		search_queue.pop();
	}

	// return a stack of directions to follow.
	std::stack<sf::Vector2i> path;
	for (Node* node = dst_node; node != nullptr; node = node->parent) {
		if (node->parent != nullptr) {
			path.push(node->coords);
		}
	}

	return path;
}

inline float AStar::distance(sf::Vector2i na, sf::Vector2i nb) {
	// Manhattan distance, diagonal movement is not allowed - 
	return (float)(std::abs(na.x - nb.x) + std::abs(na.y - nb.y));

	// Euclidean distance, diagonal movement is allowed - moves in straight lines, avoids diagonals.
	// float xl = (float)(na.x - nb.x);
	// float yl = (float)(na.y - nb.y);
	// return std::sqrt((xl * xl) + (yl * yl));

	// Chebyshev distance, diagonal movement is allowed - zig-zags, avoids straight lines.
	// return std::max(std::abs(na.x - nb.x), std::abs(na.y - nb.y));
}

inline bool AStar::in_bounds(int x, int y, int width, int height) {
	return x >= 0 && x < width && y >= 0 && y < height;
}
