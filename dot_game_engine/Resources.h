#pragma once

#include <string>
#include <exception>
#include <map>
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

class ResourcesException : public std::exception {
public: 
	ResourcesException(std::string msg = "") : std::exception(), msg("ResourcesException: " + msg) { }
	virtual const char *what() const noexcept { return msg.c_str(); }
protected:
	std::string msg;
};

struct Font {
	struct Letter {
		int tx;
		int ty;
		int width;
		int forward;
	};
	std::map<int, Letter> letter_map;
	int height;
	int spacing;
	std::string texture;
};

class Resources {
public:
	static Resources &get() {
		static Resources game;
		return game;
	}

	static sf::Texture &get_texture(std::string key);
	static sf::SoundBuffer &get_sound(std::string key);
	static sf::Music &get_music(std::string key);

	static bool load_texture(std::string key, std::string path);
	static bool load_sound(std::string key, std::string path);
	static bool load_music(std::string key, std::string path);

	static void play_sound(std::string key);
	static void play_music(std::string key);
	static void loop_music(std::string key);
	static void stop_music();
	static std::string get_current_music();

	static void set_sound_volume(float volume);
	static void set_music_volume(float volume);
	static float get_sound_volume();
	static float get_music_volume();

	static void set_font(std::string key, int height, int spacing, std::string texture);
	static void set_font_letter(std::string key, int letter_code, int x, int y, int w, int f);
	static Font &get_font(std::string key);
	static Font::Letter &get_font_letter(std::string key, int code);

private:
	Resources();
	~Resources();

	std::map<std::string, sf::Texture> texture_map;

	std::map<std::string, sf::Music> music_map;
	std::string current_music;
	float music_volume;

	std::map<std::string, sf::SoundBuffer> sound_buffer_map;
	std::vector<sf::Sound> sounds;
	int sounds_index;
	int max_sounds;
	float sound_volume;

	std::map<std::string, Font> font_map;
};


