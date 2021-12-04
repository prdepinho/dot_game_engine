#include "Panel.h"
#include "Resources.h"

Panel::Panel(
	int x,
	int y,
	int width,
	int height,
	int texture_x,
	int texture_y,
	int texture_width,
	int texture_height,
	std::string texture
) 
	: texture(texture),
	texture_x(texture_x),
	texture_y(texture_y),
	texture_width(texture_width),
	texture_height(texture_height)
{
	set_position(x, y);
	set_dimensions(width, height);
}

Panel::~Panel() { }

void Panel::build() {
	set_texture(&Resources::get_texture(texture));
	vertices.setPrimitiveType(sf::Quads);
	vertices.resize(4 * 1);
	int width = get_width();
	int height = get_height();
	set_quad(&vertices[0], 0.f, 0.f, (float)width, (float)height, (float)texture_x, (float)texture_y, (float)texture_width, (float)texture_height);
}

void Panel::change_skin(
	int texture_x,
	int texture_y,
	int texture_width,
	int texture_heigth,
	std::string texture
) {
	this->texture_width = texture_width;
	this->texture_height = texture_height;
	this->texture_x = texture_x;
	this->texture_y = texture_y;
	this->texture = texture;
	build();
}




SegmentedPanel::SegmentedPanel(
		int x,
		int y,
		int width,
		int height,
		int texture_x,
		int texture_y,
		int border_size,
		int interior_width,
		int interior_height,
		std::string texture
) 
	: horizontal_margin(10),
	vertical_margin(10),
	texture(texture),
	border_size(border_size),
	interior_width(interior_width),
	interior_height(interior_height),
	texture_x(texture_x),
	texture_y(texture_y)
{
		set_position(x, y);
		set_dimensions(width, height);
}

SegmentedPanel::~SegmentedPanel() {}

void SegmentedPanel::build() {
	set_texture(&Resources::get_texture(texture));
	vertices.setPrimitiveType(sf::Quads);
	vertices.resize(4 * 9);

	float bw = (float)border_size;
	float ih = (float)interior_height;
	float iw = (float)interior_width;
	float h = (float)get_height();
	float w = (float)get_width();
	float tx = (float)texture_x;
	float ty = (float)texture_y;

	set_quad(&vertices[0*4],   0.f,   0.f,   bw,      bw,      tx,        ty,        bw,   bw);
	set_quad(&vertices[1*4],   bw,    0.f,   w-2*bw,  bw,      tx+bw,     ty,        iw,   bw);
	set_quad(&vertices[2*4],   w-bw,  0.f,   bw,      bw,      tx+iw+bw,  ty,        bw,   bw);
	set_quad(&vertices[3*4],   0.f,   bw,    bw,      h-2*bw,  tx,        ty+bw,     bw,   ih);
	set_quad(&vertices[4*4],   bw,    bw,    w-2*bw,  h-2*bw,  tx+bw,     ty+bw,     iw,   ih);
	set_quad(&vertices[5*4],   w-bw,  bw,    bw,      h-2*bw,  tx+iw+bw,  ty+bw,     bw,   ih);
	set_quad(&vertices[6*4],   0.f,   h-bw,  bw,      bw,      tx,        ty+ih+bw,  bw,   bw);
	set_quad(&vertices[7*4],   bw,    h-bw,  w-2*bw,  bw,      tx+bw,     ty+ih+bw,  iw,   bw);
	set_quad(&vertices[8*4],   w-bw,  h-bw,  bw,      bw,      tx+iw+bw,  ty+ih+bw,  bw,   bw);
 }

void SegmentedPanel::change_skin(
	int texture_x,
	int texture_y,
	int border_size,
	int interior_width,
	int interior_height,
	std::string texture
) {
	this->texture_x = texture_x;
	this->texture_y = texture_y;
	this->border_size = border_size;
	this->interior_height = interior_height;
	this->interior_width = interior_width;
	this->texture = texture;
	build();
}
