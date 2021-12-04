#pragma once
#include "Entity.h"
#include "Lua.h"


class Animation {
public:
	std::string key;
	std::vector<sf::VertexArray> frames;
	float fps;
	int activation_frame;
	LuaObject callback;
};

struct AnimationResources {
	std::map<std::string, Animation> animations;
	int texture_height;
	int texture_width;
	std::string texture;
};



class Sprite :
	public AnimatedEntity
{
public:
	Sprite(std::string id = "", int x = 0, int y = 0, int width = 0, int height = 0, AnimationResources resources = {});
	virtual ~Sprite();
	virtual void build() override;
	virtual void update(float elapsed_time) override;

	void set_animation_resources(AnimationResources animation_resources);

	void set_animation(std::string key, bool loop);
	void start_animation(std::string key);
	void loop_animation(std::string key);
	void stop_animation();
	std::string get_current_animation() const;

private:
	std::string id;
	AnimationResources animation_resources;
	std::string current_animation;
	std::string looping_animation;
	void *data = nullptr;
	int activation_frame = 0;
	LuaObject callback;
	std::function<void(void*)> activation_frame_function = [](void*) {};
};

