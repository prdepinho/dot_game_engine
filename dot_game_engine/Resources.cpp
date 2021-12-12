#include "Resources.h"

Resources::Resources() {
	sounds_index = 0;
	max_sounds = 32;
	sounds = std::vector<sf::Sound>(32);
}

Resources::~Resources() { }

sf::Texture &Resources::get_texture(std::string key) {
	return get().texture_map[key]; 
}

sf::SoundBuffer &Resources::get_sound(std::string key) {
	return get().sound_buffer_map[key];
}

sf::Music &Resources::get_music(std::string key) {
	return get().music_map[key];
}

bool Resources::load_texture(std::string key, std::string path) {
	return get().texture_map[key].loadFromFile(path);
}

bool Resources::load_sound(std::string key, std::string path) {
	return get().sound_buffer_map[key].loadFromFile(path);
}

bool Resources::load_music(std::string key, std::string path) {
	return get().music_map[key].openFromFile(path);
}

void Resources::play_sound(std::string key) {
	get().sounds_index = (get().sounds_index + 1) % get().max_sounds;
	get().sounds[get().sounds_index] = sf::Sound(Resources::get_sound(key));
	get().sounds[get().sounds_index].setVolume(Resources::get_sound_volume());
	get().sounds[get().sounds_index].play();
}

void Resources::play_music(std::string key) {
	Resources::stop_music();
	sf::Music &music = Resources::get_music(key);
	music.setVolume(Resources::get_music_volume());
	music.play();
	music.setLoop(false);
	get().current_music = key;
}

void Resources::loop_music(std::string key) {
	Resources::stop_music();
	sf::Music &music = Resources::get_music(key);
	music.setVolume(Resources::get_music_volume());
	music.play();
	music.setLoop(true);
	get().current_music = key;
}

void Resources::stop_music() {
	if (Resources::get_current_music() != "") {
		Resources::get_music(Resources::get_current_music()).stop();
		get().current_music = "";
	}
}

std::string Resources::get_current_music() {
	return get().current_music;
}

void Resources::set_sound_volume(float volume) {
	get().sound_volume = volume;
}

void Resources::set_music_volume(float volume) {
	get().music_volume = volume;
}

float Resources::get_sound_volume() {
	return get().sound_volume;
}

float Resources::get_music_volume() {
	return get().music_volume;
}


void Resources::set_font(std::string key, int height, int spacing, std::string texture) {
	get().font_map[key] = { {}, height, spacing, texture };
}

void Resources::set_font_letter(std::string key, int letter_code, int x, int y, int w, int f) {
	get().font_map[key].letter_map[letter_code] = { x, y, w, f };
}

Font &Resources::get_font(std::string key) {
	return get().font_map[key];
}

Font::Letter &Resources::get_font_letter(std::string key, int code) {
	return get().font_map[key].letter_map[code];
}

void Resources::set_tilemap_path(std::string path) {
	if (*(path.end()-1) != '/')
		path += '/';
	get().tilemap_path = path;
}

std::string Resources::get_tilemap_path() {
	return get().tilemap_path;
}
