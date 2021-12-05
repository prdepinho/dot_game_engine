#pragma once
#include "Entity.h"
#include <string>

class Text : public Entity {
public:
	Text(std::string font="font");
	void write_line(int x, int y, std::string text, sf::Color color=sf::Color::Black);
	void write_block(int x, int y, int line_length, std::string text, sf::Color color=sf::Color::Black);

	int word_size(std::string word);
	std::vector<std::string> split_words(std::string line);
	std::vector<std::string> split_lines(std::string text, int max_length);

	std::string get_text() const { return text; }
	void set_text(std::string text);
private:
	std::string font;
	std::string text;
	sf::Color color;
	int line_length;
};

