#include <iostream>
#include <exception>
#include <SFML/Graphics.hpp>
#include "Lua.h"
#include "Game.h"

int main()
{
	Game &game = Game::get();
	try {
		game.setup();
		game.start();
	}
	catch (std::exception &e) {
		std::cout << e.what() << std::endl;
		std::getchar();
	}
    return 0;
}
