#pragma once
#include "Entity.h"


class Panel : public Entity
{
public:
	Panel(
		int x = 0,
		int y = 0,
		int width = 0,
		int height = 0,
		int texture_x = 0,
		int texture_y = 0,
		int texture_width = 0,
		int texture_height = 0,
		std::string texture = "gui"
	);

	virtual ~Panel();
	virtual void build() override;

	void change_skin(
		int texture_x = 0,
		int texture_y = 0,
		int texture_width = 0,
		int texture_heigth = 0,
		std::string texture = "gui"
	);

private:
	std::string texture;
	int texture_x;
	int texture_y;
	int texture_width;
	int texture_height;
};

class SegmentedPanel : public Entity
{
public:
	SegmentedPanel(
		int x = 0,
		int y = 0,
		int width = 0,
		int height = 0,
		int texture_x = 0,
		int texture_y = 0,
		int border_size = 0,
		int interior_width = 0,
		int interior_height = 0,
		std::string texture = "gui"
	);
	virtual ~SegmentedPanel();
	virtual void build() override;

	void change_skin(
		int texture_x = 0,
		int texture_y = 0,
		int border_size = 0,
		int interior_width = 0,
		int interior_height = 0,
		std::string texture = "gui"
	);
protected:
	std::string texture;
	int border_size;
	int interior_width;
	int interior_height;
	int horizontal_margin;
	int vertical_margin;
	int texture_x;
	int texture_y;
};


