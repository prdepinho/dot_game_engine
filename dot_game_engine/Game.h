#pragma once
#include <SFML/Graphics.hpp>
#include "Screen.h"
#include "Lua.h"

class Game {
public:
	static Game &get() {
		static Game game;
		return game;
	}

	void setup();
	void start();
	void stop();

	static void close() { get().stop(); }
	static Screen &get_screen() { return get().screen; }
	static int get_screen_width() { return get().screen_width; }
	static int get_screen_height() { return get().screen_height; }
	static int get_modified_width() { return get().modified_width; }
	static int get_modified_height() { return get().modified_height; }
	static bool is_fullscreen() { return get().fullscreen; }
	static bool is_use_vsync() { return get().use_vsync; }
	static bool is_limit_framerate() { return get().limit_framerate; }
	static int get_framerate() { return get().framerate; }

private:
	Game();
	~Game();
	void loop();
	void configure_game();

private:
	sf::Clock clock;
	sf::RenderWindow window;
	bool run;
	Screen screen;

private:
	int screen_width;
	int screen_height;
	int modified_width;
	int modified_height;
	bool fullscreen;
	bool use_vsync;
	bool limit_framerate;
	int framerate;

};

