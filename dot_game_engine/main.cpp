#include <iostream>
#include <exception>
#include <SFML/Graphics.hpp>
#include "Resources.h"
#include "Lua.h"
#include "Game.h"



int main()
{
	Resources::get();				// create it first, delete it last
	Lua::get();						// delete second to last
	Game &game = Game::get();		// delete first
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
