#include "Sprite.h"
#include "Resources.h"

Sprite::Sprite(std::string id, int x, int y, int width, int height, AnimationResources resources) 
	: id(id), animation_resources(resources)
{
	set_position(x, y);
	set_dimensions(width, height);
	set_texture(&Resources::get_texture(resources.texture));
}

Sprite::~Sprite() {
	for (auto it: animation_resources.animations)
		it.second.callback.delete_functions();
}


void Sprite::build() {
}

void Sprite::set_animation_resources(AnimationResources animation_resources) {
	this->animation_resources = animation_resources;
	set_texture(&Resources::get_texture(animation_resources.texture));
}

void Sprite::set_animation(std::string key, bool loop) {
	current_animation = key;
	if (loop) {
		looping_animation = key;
		set_cycle_callback([](AnimatedEntity*) {});
	}
	else {
		set_cycle_callback([&](AnimatedEntity*) {
			loop_animation(looping_animation);
		});
	}
	Animation &animation = animation_resources.animations[key];
	if (animation.activation_frame >= 0) {
		activation_frame = animation.activation_frame;
		callback = animation.callback;

		data = this;
		activation_frame_function = [](void* self) { 
			Sprite *sprite = ((Sprite*)self); 
			sprite->callback.call_sprite_callback(sprite->id);
		};
	}
	else {
		activation_frame = 0;
		activation_frame_function = [](void*) {};
		data = nullptr;
	}
	AnimatedEntity::set_animation(animation.frames, animation.fps);
}

void Sprite::start_animation(std::string key) { set_animation(key, false); }
void Sprite::loop_animation(std::string key) { set_animation(key, true); }
void Sprite::stop_animation() { loop_animation(looping_animation); }


void Sprite::update(float elapsed_time) {
	AnimatedEntity::update(elapsed_time);
	if (frame == activation_frame) {
		activation_frame_function(data);
		activation_frame_function = [](void*) {};
		data = nullptr;
	}
}

std::string Sprite::get_current_animation() const {
	return current_animation;
}
