#pragma once

#include <string>
#include <sstream>
#include <exception>
#include <map>
#include <vector>
#include "lua5.3.5/lua.hpp"

class LuaObject;

class LuaException : public std::exception {
public: 
	LuaException(std::string msg = "") : std::exception(), msg("LuaException: " + msg) { }
	virtual const char *what() const noexcept { return msg.c_str(); }
protected:
	std::string msg;
};

class Lua {
public:
	Lua();
	Lua(std::string filename);
	~Lua();

	static Lua &get() {
		static Lua lua("game/main.lua");
		return lua;
	}

	void load(std::string filename = "");
	lua_State *get_state() { return state; }

	const char* get_error(lua_State *state);
	int get_registry_index() const { return registry_index; }

	void run_start_game();
	void run_loop(float delta);
	void run_end_game();
	void run_on_input(std::string type, float elapsed_time, int key, int button, int x, int y, float delta);

	int get_int(std::string name, int default_value);
	float get_float(std::string name, float default_value);
	bool get_boolean(std::string name, bool default_value);
	std::string get_string(std::string name, std::string default_value);

	int get_int(std::string name);
	float get_float(std::string name);
	bool get_boolean(std::string name);
	std::string get_string(std::string name);

	LuaObject get_object(std::string name);
	LuaObject get_child_object(std::string parent_path="");

	std::string call_table_function(LuaObject *token, std::string function_name);
	void call_function(LuaObject *token, std::string table_name, std::string function_name);
	void call_function(LuaObject *token, std::string table_name);

private:
	std::string call_function_recursive(std::vector<std::string> path, std::string function_name, int level);
	void create_registry_table();
	void destroy_registry_table();

private:
	lua_State *state; 
	int registry_index;
};

/**

Lua object represents a lua variable or constant. You can obtain an object from
the root of a Lua file by calling get_object from the Lua class. This will
parse the lua file and create the object. Then, you may obtain its value by
calling get_* function, like get_int(), get_float(), get_boolean(),
get_string() or get_map(). The function get_map returns an std::map and
represents a Lua map or array. The mapping is between a string key and a Lua
object. You can navigate in the map tree in a number of ways illustrated in the
following example.

Suppose you have a peter.lua file which constains the map below and you want to
obtain the value human_male.basic.file:

```
 human_male = {
   basic = {
     file = "sprites",
     size = {
       height = 16,
       width = 16
     }
   },
  index = {
    x = 0,
    y = 0
  },
}
```

First open the Lua file and get the Lua object for human_male.

```
Lua lua(Path::CHARACTERS + "peter.lua");
LuaObject object = lua.get_object("human_male");
```

Then you may obtain the desired value by using any of the following methods:

```
std::string file = object.get_token("basic")->get_string("file");
std::string file = object.get_token("basic")->get_token("file")->get_string();
```

If the Lua object is a map or an array, as a shortcut you can use the index
operator ([]) to access its elements, so the folowing line can be used as
well. 

```
std::string file = object["basic"]["file"].get_string();
```

I find using the index operator with lists confusing and not reliable. Use the
next method instead, which is easier and avoids confusion: Pass a dot separated
path through the nodes in the map, as illustrated by the following lines.

```
std::string file = object.get_string("basic.file");
std::string file = object.get_token("basic.file")->get_string();
```

To get an element from a list, pass the index in string form. Remember that Lua
lists begin with 1, not 0:

```
LuaObject *rval = object.get_token("1");
LuaObject &rval = object["1"];
```

These functions show how to retreave a string from a Lua object. Mutatis
mutandis they work the same for other data types.

If you must iterate through the elements of a map or list, LuaObject delegates
some standard map functions like begin(), rbegin(), end(), rend() and size().
An example of how to itarate a list follows.

```
	LuaObject *indices = object.get_object("animations.walk.frames");
	Log("size: %u", indices->size());
	for (auto it = indices->begin(); it != indices->end(); ++it) {
		Log("%d", it->second.get_int());
	}
```

LuaObject is not in iterable container though. If you need more control, use
get_map() to retrieve the underlying map.


To execute a function:

If a member of the object is a function, you can execute it using the Lua
object that handles the script and calling call_function with the LuaObject of
the function. These function don't take any argument and don't return any
value.

For example, suppose the script is the following:

```
obj = {
  test = {
    counter = 10,
    increment = function () obj.test.counter = obj.test.counter + 1 end,
    show_counter = function () print(obj.test.counter) end
  }
}
```

The following code shall increment obj.counter to 11 and print the
new value afterwards.

```
LuaObject obj = lua.get_object("obj");
lua.call_function(obj.get_object("test.increment"), "obj");
lua.call_function(obj.get_object("test.show_counter"), "obj");
```

Use call_table_function if you have a table at the top of the stack and need to
call a function in it. It works similarly to call_function, but the LuaObject
needs to be taken from the top of the stack with get_child_object, as follows.

```
LuaObject dialogue = Lua::get().get_child_object();
LuaObject *block = dialogue.get_object(go_to);
Lua::get().call_table_function(block, "callback");
```

*/

class LuaObject {
	friend class Lua;
public:
	enum Type { STRING, NUMBER, BOOLEAN, OBJECT, FUNCTION, NULL_OBJECT, INTEGER };
	LuaObject(Lua *lua = nullptr) : lua(lua) { path = ""; }
	~LuaObject() {}

	LuaObject *get_token(std::string object_path);

	int get_int(std::string name, int default_value);
	float get_float(std::string name, float default_value);
	bool get_boolean(std::string name, bool default_value);
	std::string get_string(std::string name, std::string default_value);

	int get_int(std::string name);
	float get_float(std::string name);
	bool get_boolean(std::string name);
	std::string get_string(std::string name);
	std::map<std::string, LuaObject> get_map(std::string name);
	LuaObject *get_object(std::string name) { return get_token(name); }

	int get_int() { return get_int(""); }
	float get_float() { return get_float(""); }
	bool get_boolean() { return get_boolean(""); }
	std::string get_string() { return get_string(""); }
	std::map<std::string, LuaObject> get_map() { return get_map(""); }
	LuaObject *get_object() { return get_object(""); }

	/// Get the token at index.
	LuaObject &operator[](unsigned int index) { std::stringstream ss; ss << (index + 1); return object[ss.str()]; }
	/// Get the token at key.
	LuaObject &operator[](const std::string key) { return object[key]; }

	auto begin() { return object.begin(); }
	auto rbegin() { return object.rbegin(); }
	auto end() { return object.end(); }
	auto rend() { return object.rend(); }


	size_t size() const;
	Type get_type() const { return type; }
	std::string get_path() const { return path; }
	std::string get_function_name() const { return function_name; }

	std::string call_function(std::string name, LuaObject arg = {});
	void delete_functions();
	void dump_map();

	static LuaObject wrap_number(float i);
	static LuaObject wrap_int(int i);
	static LuaObject wrap_string(std::string s);

	bool entity_input_callback(std::string type, float elapsed_time, int key, int button, int x, int y, float delta);
	bool call_sprite_callback(std::string id);
	bool call();
private:
	void delete_functions_recursive(LuaObject &object);
	void dump_map_recursive(LuaObject &object, int indent);

private:
	Lua *lua;
	Type type = Type::NULL_OBJECT;
	std::string string;
	float number;
	bool boolean;
	std::string path;
	std::string function_name;
	int function_index;
	std::map<std::string, LuaObject> object;
};


