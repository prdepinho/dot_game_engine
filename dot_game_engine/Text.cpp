#include "Text.h"
#include "Resources.h"
#include "Game.h"

Text::Text(std::string font) : font(font) { }

static void set_letter(sf::Vertex *quad, float x, float y, float ox, float oy, float w, float h, sf::Color color) {
	quad[0].position = sf::Vector2f(0+x, 0+y);
	quad[1].position = sf::Vector2f(w+x, 0+y);
	quad[2].position = sf::Vector2f(w+x, h+y);
	quad[3].position = sf::Vector2f(0+x, h+y);

	quad[0].texCoords = sf::Vector2f(0+ox, 0+oy);
	quad[1].texCoords = sf::Vector2f(w+ox, 0+oy);
	quad[2].texCoords = sf::Vector2f(w+ox, h+oy);
	quad[3].texCoords = sf::Vector2f(0+ox, h+oy);

	if (color != sf::Color::Magenta) {
		quad[0].color = color;
		quad[1].color = color;
		quad[2].color = color;
		quad[3].color = color;
	}
}


void Text::write_line(int x, int y, std::string text, sf::Color color) {
	Font &font = Resources::get_font(this->font);
	this->text = text;
	this->line_length = -1;
	this->color = color;

	set_texture(&Resources::get_texture(font.texture));
	set_position(x, y);
	vertices.setPrimitiveType(sf::Quads);
	vertices.resize(4 * text.size());

	const char *str = text.c_str();
	size_t len = text.size();
	int forward = 0;
	for (int i = 0; i < len; i++) {
		int code = 0;
		if (str[i] < 0)
			memcpy(&code, str + i++, sizeof(char) * 2);
		else
			memcpy(&code, str + i, sizeof(char));

		Font::Letter &letter = font.letter_map[code];
		set_letter(&vertices[i*4], (float)forward, 0.f, (float)letter.tx, (float)letter.ty, (float)letter.width, (float)font.height, color);
		forward += letter.forward + font.spacing;
	}

	set_dimensions(forward, font.height);
}


void Text::write_block(int x, int y, int line_length, std::string text, sf::Color color) {
	Font &font = Resources::get_font(this->font);
	this->text = text;
	this->line_length = line_length;
	this->color = color;

	set_texture(&Resources::get_texture(font.texture));
	set_position(x, y);
	vertices.setPrimitiveType(sf::Quads);
	vertices.resize(4 * text.size());

	std::vector<std::string> lines = split_lines(text, line_length);

	int vindex = 0;
	int max_forward = 0;
	int downward = 0;

	for (int j = 0; j < lines.size(); j++) {
		std::string line = lines[j];
		const char *str = line.c_str();
		int forward = 0;
		for (int i = 0; i < line.size(); i++) {
			int code = 0;
			if (str[i] < 0)
				memcpy(&code, str + i++, sizeof(char) * 2);
			else
				memcpy(&code, str + i, sizeof(char));

			Font::Letter &letter = font.letter_map[code];
			set_letter(&vertices[vindex], (float)forward, (float)downward, (float)letter.tx, (float)letter.ty, (float)letter.width, (float)font.height, color);
			vindex += 4;
			if (str[i] != '\n')
				forward += letter.forward + font.spacing;
			max_forward = max_forward < forward ? forward : max_forward;
		}
		downward += font.height + 1;
	}

	set_dimensions(max_forward, downward);
}

void Text::set_text(std::string text) {
	if (line_length >= 0)
		write_block(get_x(), get_y(), line_length, text, color);
	else
		write_line(get_x(), get_y(), text, color);
}

int Text::word_size(std::string word) {
	Font &font = Resources::get_font(this->font);
	const char *str = word.c_str();
	size_t len = word.size();
	int forward = 0;
	for (int i = 0; i < len; i++) {
		int code = 0;
		if (str[i] < 0)
			memcpy(&code, str + i++, sizeof(char) * 2);
		else
			memcpy(&code, str + i, sizeof(char));

		Font::Letter &letter = font.letter_map[code];
		forward += letter.forward + font.spacing;
	}
	return forward;
}

std::vector<std::string> Text::split_words(std::string line) {
	std::vector<std::string> words;
	std::string word = "";
	for (int i = 0; i < line.size(); i++) {
		char c = line[i];
		if (c == ' ' || i == line.size() -1) {
			word += c;
			words.push_back(word);
			word = "";
		}
		else if (c == '\n') {
			words.push_back(word);
			words.push_back("\n");
			word = "";
		}
		else {
			word += c;
		}
	}
	return words;
}

std::vector<std::string> Text::split_lines(std::string text, int max_length) {
	int line_width = 0;
	std::string line = "";
	std::vector<std::string> lines;
	std::vector<std::string> words = split_words(text);

	for (unsigned int i = 0; i < words.size(); i++) {
		std::string word = words[i];
		int word_width = word_size(word);
		if (line_width + word_width > max_length || word == "\n") {
			lines.push_back(line);
			line = "";
			line_width = 0;
		}
		line_width += word_width;
		line += word;
	}
	if (line != "") {
		lines.push_back(line);
	}

	return lines;
}
