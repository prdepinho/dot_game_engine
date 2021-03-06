
#include "Entity.h"

Entity::Entity() {
	static long global_id = 0;
	id = global_id++;
}

Entity::~Entity() {}

void Entity::draw(sf::RenderTarget &target, sf::RenderStates states) const {
	states.transform *= getTransform();
	states.texture = texture;
	target.draw(vertices, states);
	target.draw(outline.rectangle, states);
	target.draw(origin.circle, states);
}

void Entity::set_quad(
	sf::Vertex *quad, 
	float posX, float posY, 
	float width, float height, 
	float tex_posX, float tex_posY, 
	float tex_width, float tex_height)
{
	quad[0].position = sf::Vector2f( posX,          posY         );
	quad[1].position = sf::Vector2f( posX + width,  posY         );
	quad[2].position = sf::Vector2f( posX + width,  posY + height);
	quad[3].position = sf::Vector2f( posX,          posY + height);

	quad[0].texCoords = sf::Vector2f( tex_posX,              tex_posY             );
	quad[1].texCoords = sf::Vector2f( tex_posX + tex_width,  tex_posY             );
	quad[2].texCoords = sf::Vector2f( tex_posX + tex_width,  tex_posY + tex_height);
	quad[3].texCoords = sf::Vector2f( tex_posX,              tex_posY + tex_height);
}

void Entity::offset_tex_pos(sf::Vertex *quad, float delta_x, float delta_y) {
	quad[0].texCoords.x += delta_x;
	quad[0].texCoords.y += delta_y;
	quad[1].texCoords.x += delta_x;
	quad[1].texCoords.y += delta_y;
	quad[2].texCoords.x += delta_x;
	quad[2].texCoords.y += delta_y;
	quad[3].texCoords.x += delta_x;
	quad[3].texCoords.y += delta_y;
}

void Entity::set_quad_tex_coords(
	sf::Vertex *quad,
	float tex_posX, float tex_posY,
	float tex_width, float tex_height)
{
	quad[0].texCoords = sf::Vector2f( tex_posX,              tex_posY             );
	quad[1].texCoords = sf::Vector2f( tex_posX + tex_width,  tex_posY             );
	quad[2].texCoords = sf::Vector2f( tex_posX + tex_width,  tex_posY + tex_height);
	quad[3].texCoords = sf::Vector2f( tex_posX,              tex_posY + tex_height);
}

void Entity::set_show_outline(bool show) { 
	outline.show = show; 
	updateOutline();
}

void Entity::set_show_origin(bool show) { 
	origin.show = show; 
	updateOrigin();
}

void Entity::show_origin(int radius, sf::Color color) {
	origin.radius = radius;
	origin.color = color;
	set_show_origin(true);
}

void Entity::show_outline(int thickness, int size_adjustment, sf::Color color) {
	outline.thickness = thickness;
	outline.color = color;
	outline.size_adjustment = size_adjustment;
	set_show_outline(true);
}

void Entity::hide_origin() {
	set_show_origin(false);
	origin.color = sf::Color::White;
}

void Entity::hide_outline() {
	set_show_outline(false);
	outline.color = sf::Color::White;
}

void Entity::updateOrigin() {
	sf::Vector2f entity_origin = getOrigin();
	float x = entity_origin.x - origin.radius;
	float y = entity_origin.y - origin.radius;
	origin.circle = sf::CircleShape();
	origin.circle.setPosition(x, y);
	origin.circle.setRadius((float)origin.radius);
	origin.circle.setFillColor(origin.color);
	origin.circle.setOutlineColor(origin.color);
}

void Entity::updateOutline() {
	int x = -outline.size_adjustment;
	int y = -outline.size_adjustment;
	int w = get_width() + outline.size_adjustment * 2;
	int h = get_height() + outline.size_adjustment * 2;
	outline.rectangle = sf::RectangleShape();
	outline.rectangle.setPosition((float)x, (float)y);
	outline.rectangle.setSize(sf::Vector2f((float) w, (float) h));
	outline.rectangle.setOutlineThickness(outline.show ? ((float)outline.thickness) : 0.f);
	outline.rectangle.setFillColor(sf::Color::Transparent);
	outline.rectangle.setOutlineColor(outline.color);
}








AnimatedEntity::AnimatedEntity() : Entity(), count(0), frame(0), callback([](AnimatedEntity*) {}) {}

void AnimatedEntity::update(float elapsedTime) {
	if ((count += elapsedTime) >= seconds_per_frame) {
		count = 0.f;
		++frame %= frames.size();
		if (frame == 0)
			callback(this);
		vertices = frames[frame];
	}
}

void AnimatedEntity::set_animation(std::vector<sf::VertexArray> animation, float fps) {
	frames = animation;
	vertices = animation[0];
	frame = 0;
	count = 0.f;
	seconds_per_frame = (fps > 0.f) ? (1.f / fps) : (0.1f);
}

