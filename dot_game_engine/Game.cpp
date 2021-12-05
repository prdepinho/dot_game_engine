#include "Game.h"
#include "Lua.h"
#include "Resources.h"
#include <iostream>
#include <string>

Game::Game() { }
Game::~Game() { }

void Game::setup() {
	std::srand((unsigned int)std::time(NULL));
	configure_game();
	screen.set_window(&window);
	screen.create();
}

void Game::start() {
	run = true;
	Lua::get().run_start_game();
	loop();
	Lua::get().run_end_game();
}

void Game::stop() {
	run = false;
}

void Game::loop() {
	while (window.isOpen()) {
		float elapsed_time = clock.restart().asSeconds();

		screen.poll_events(elapsed_time);
		screen.update(elapsed_time);
		window.clear(sf::Color::Black);
		screen.draw();
		window.display();

		float fps = 1.f / elapsed_time;
		window.setTitle("wargame " + std::to_string(fps));

		Lua::get().run_loop(elapsed_time);

		if (!run)
			break;
	}
}

void Game::configure_game() {
	Lua lua("config.lua");
	LuaObject resolution = lua.get_object("screen_resolution");

	screen_width = resolution.get_int("width", 800);
	screen_height = resolution.get_int("height", 600);

	float modifier = lua.get_float("size_modifier", 0.1f);
	modified_width = (int)(screen_width * modifier);
	modified_height = (int)(screen_height * modifier);

	fullscreen = lua.get_boolean("fullscreen", false);
	use_vsync = lua.get_boolean("use_vsync", true);
	limit_framerate = lua.get_boolean("limit_framerate", false);
	framerate = lua.get_int("set_framerate", 30);

	float music_volume = lua.get_float("music_volume", 15.0);
	Resources::set_music_volume(music_volume);

	float sound_volume = lua.get_float("sound_volume", 15.0);
	Resources::set_sound_volume(sound_volume);

	int screen_style = sf::Style::Default;
	if (fullscreen) {
		screen_style |= sf::Style::Fullscreen;
	}

	sf::ContextSettings settings;
	settings.depthBits = 24;
	settings.stencilBits = 8;
	settings.antialiasingLevel = 0;

	if (!fullscreen) {
		auto video_mode = sf::VideoMode(screen_width, screen_height);
		window.create(video_mode, "", screen_style, settings);
		window.setSize(sf::Vector2u(modified_width, modified_height));
		int pos_x = sf::VideoMode::getDesktopMode().width / 2 - modified_width / 2;
		int pos_y = sf::VideoMode::getDesktopMode().height / 2 - modified_height / 2;
		window.setPosition(sf::Vector2i(pos_x, pos_y));
	}
	else {
		window.create(sf::VideoMode::getDesktopMode(), "", screen_style, settings);
	}

	window.setKeyRepeatEnabled(false);

	if (use_vsync)
		window.setVerticalSyncEnabled(true);
	else
		if (limit_framerate)
			window.setFramerateLimit(framerate);

	window.setTitle("Game");
	{
		auto image = sf::Image();
		if (!image.loadFromFile("icon.png")) {
			throw std::exception();
		}
		else {
			window.setIcon(16, 16, image.getPixelsPtr());
		}
	}

}
