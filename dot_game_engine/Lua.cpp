#include "Lua.h"
#include "LuaExporter.h"
#include "Resources.h"

#include <iostream>

Lua::Lua() {
	state = luaL_newstate();
	luaL_openlibs(state);
	create_registry_table();
}

Lua::Lua(std::string filename) {
	state = luaL_newstate();
	luaL_openlibs(state);
	create_registry_table();
	load(filename);
}

Lua::~Lua() {
	printf("Lua out\n");
	destroy_registry_table();
	lua_close(state);
}

void Lua::load(std::string filename) {
	int rval = luaL_loadfile(state, filename.c_str());
	if (rval != LUA_OK) {
		throw LuaException(get_error(state));
	}
	rval = lua_pcall(state, 0, LUA_MULTRET, 0);
	if (rval != LUA_OK) {
		throw LuaException(get_error(state));
	}
	LuaExporter::register_lua_accessible_functions(*this);
}

void Lua::create_registry_table() {
	lua_newtable(state);
	registry_index = luaL_ref(state, LUA_REGISTRYINDEX);
}

void Lua::destroy_registry_table() {
	luaL_unref(state, LUA_REGISTRYINDEX, registry_index);
	registry_index = 0;
}

const char* Lua::get_error(lua_State *state) {
	const char *message = lua_tostring(state, -1);
	lua_pop(state, 1);
	return message;
}


void Lua::run_start_game() {
	lua_getglobal(state, "start_game");
	int result = lua_pcall(state, 0, 1, 0);
	if (result != LUA_OK) {
		throw LuaException(get_error(state));
	}
	lua_pop(state, 1);
}

void Lua::run_loop(float delta) {
	lua_getglobal(state, "loop");
	lua_pushnumber(state, delta);
	int result = lua_pcall(state, 1, 1, 0);
	if (result != LUA_OK) {
		throw LuaException(get_error(state));
	}
	lua_pop(state, 1);
}


void Lua::run_end_game() {
	lua_getglobal(state, "end_game");
	int result = lua_pcall(state, 0, 1, 0);
	if (result != LUA_OK) {
		throw LuaException(get_error(state));
	}
	lua_pop(state, 1);
}

void Lua::run_on_input(std::string type, float elapsed_time, int key, int button, int x, int y, float delta) {
	lua_getglobal(state, "on_input");

	lua_newtable(state);

	lua_pushstring(state, "type");
	lua_pushstring(state, type.c_str());
	lua_settable(state, -3);

	lua_pushstring(state, "elapsed_time");
	lua_pushnumber(state, elapsed_time);
	lua_settable(state, -3);

	lua_pushstring(state, "key");
	lua_pushinteger(state, key);
	lua_settable(state, -3);

	lua_pushstring(state, "button");
	lua_pushinteger(state, button);
	lua_settable(state, -3);

	lua_pushstring(state, "x");
	lua_pushinteger(state, x);
	lua_settable(state, -3);

	lua_pushstring(state, "y");
	lua_pushinteger(state, y);
	lua_settable(state, -3);

	lua_pushstring(state, "delta");
	lua_pushnumber(state, delta);
	lua_settable(state, -3);

	int result = lua_pcall(state, 1, 1, 0);
	if (result != LUA_OK) {
		throw LuaException(get_error(state));
	}
	lua_pop(state, 1);
}

bool LuaObject::call_sprite_callback(std::string id) {
	if (get_type() != LuaObject::Type::FUNCTION)
		return false;
	lua_State *state = lua->get_state();

	lua_rawgeti(state, LUA_REGISTRYINDEX, lua->get_registry_index());  // push the table
	lua_rawgeti(state, -1, function_index);  // push the function from the table

	lua_pushstring(state, id.c_str());

	if (lua_pcall(state, 1, 1, 0) != 0) {
		std::cout << "Failed to call the callback! " << lua_tostring(state, -1) << std::endl;
	}

	bool rval = false;
	if (lua_isboolean(state, -1)) {
		rval = lua_toboolean(state, -1);
	}
	lua_pop(state, 1);
	lua_pop(state, 1);
	return rval;
}

bool LuaObject::call() {
	if (get_type() != LuaObject::Type::FUNCTION)
		return false;
	lua_State *state = lua->get_state();

	lua_rawgeti(state, LUA_REGISTRYINDEX, lua->get_registry_index());  // push the table
	lua_rawgeti(state, -1, function_index);  // push the function from the table

	if (lua_pcall(state, 0, 1, 0) != 0) {
		std::cout << "Failed to call the callback! " << lua_tostring(state, -1) << std::endl;
	}

	bool rval = false;
	if (lua_isboolean(state, -1)) {
		rval = lua_toboolean(state, -1);
	}
	lua_pop(state, 1);
	lua_pop(state, 1);
	return rval;
}

bool LuaObject::entity_input_callback(std::string type, float elapsed_time, int key, int button, int x, int y, float delta) {
	if (get_type() != LuaObject::Type::FUNCTION)
		return false;
	lua_State *state = lua->get_state();

	lua_rawgeti(state, LUA_REGISTRYINDEX, lua->get_registry_index());  // push the table
	lua_rawgeti(state, -1, function_index);  // push the function from the table

	lua_newtable(state);

	lua_pushstring(state, "type");
	lua_pushstring(state, type.c_str());
	lua_settable(state, -3);

	lua_pushstring(state, "elapsed_time");
	lua_pushnumber(state, elapsed_time);
	lua_settable(state, -3);

	lua_pushstring(state, "key");
	lua_pushinteger(state, key);
	lua_settable(state, -3);

	lua_pushstring(state, "button");
	lua_pushinteger(state, button);
	lua_settable(state, -3);

	lua_pushstring(state, "x");
	lua_pushinteger(state, x);
	lua_settable(state, -3);

	lua_pushstring(state, "y");
	lua_pushinteger(state, y);
	lua_settable(state, -3);

	lua_pushstring(state, "delta");
	lua_pushnumber(state, delta);
	lua_settable(state, -3);

	if (lua_pcall(state, 1, 1, 0) != 0) {
		std::cout << "Failed to call the callback! " << lua_tostring(state, -1) << std::endl;
	}

	bool rval = false;
	if (lua_isboolean(state, -1)) {
		rval = lua_toboolean(state, -1);
	}
	lua_pop(state, 1);
	lua_pop(state, 1);
	return rval;
}



int Lua::get_int(std::string name, int default_value){
	lua_getglobal(state, name.c_str());
	int isnum;
	int i = (int) lua_tointegerx(state, -1, &isnum);
	lua_pop(state, 1);
	return isnum ? i : default_value;
}

float Lua::get_float(std::string name, float default_value){
	lua_getglobal(state, name.c_str());
	int isnum;
	float f = (float) lua_tonumberx(state, -1, &isnum);
	lua_pop(state, 1);
	return isnum ? f : default_value;
}

bool Lua::get_boolean(std::string name, bool default_value){
	int rval = default_value;
	lua_getglobal(state, name.c_str());
	if (lua_isboolean(state, -1)) {
		rval = lua_toboolean(state, -1);
	}
	lua_pop(state, 1);
	return (bool)rval;
}

std::string Lua::get_string(std::string name, std::string default_value){
	std::string rval = default_value;
	lua_getglobal(state, name.c_str());
	if (!lua_isnil(state, -1)) {
		rval = std::string(lua_tostring(state, -1));
	}
	lua_pop(state, 1);
	return rval;
}

int Lua::get_int(std::string name){
	lua_getglobal(state, name.c_str());
	int isnum;
	int i = (int) lua_tointegerx(state, -1, &isnum);
	lua_pop(state, 1);
	if (!isnum)
		throw LuaException(name + " is not an int");
	return i;
}

float Lua::get_float(std::string name){
	lua_getglobal(state, name.c_str());
	int isnum;
	float f = (float) lua_tonumberx(state, -1, &isnum);
	lua_pop(state, 1);
	if (!isnum)
		throw LuaException(name + " is not a float");
	return f;
}

bool Lua::get_boolean(std::string name){
	int rval;
	lua_getglobal(state, name.c_str());
	if (lua_isboolean(state, -1)) {
		rval = lua_toboolean(state, -1);
	}
	else {
		lua_pop(state, 1);
		throw LuaException(name + " is not a boolean");
	}
	lua_pop(state, 1);
	return (bool)rval;
}

std::string Lua::get_string(std::string name){
	std::string rval;
	lua_getglobal(state, name.c_str());
	if (!lua_isnil(state, -1)) {
		rval = std::string(lua_tostring(state, -1));
	}
	else {
		lua_pop(state, 1);
		throw LuaException(name + " is not a string");
	}
	lua_pop(state, 1);
	return rval;
}

static std::vector<std::string> splitstr(std::string str, char separator) {
	std::vector<std::string> parts;
	std::string part = "";
	for (char c : str) {
		if (c == separator) {
			parts.push_back(part);
			part = "";
		}
		else {
			part += c;
		}
	}
	parts.push_back(part);
	return parts;
}

LuaObject * LuaObject::get_token(std::string object_path) {
	if (object_path == "")
		return this;
	std::vector<std::string> parts = splitstr(object_path, '.');
	LuaObject *token = this;
	for (std::string part : parts) {
		token = &token->object[part];
	}
	return token;
}

int LuaObject::get_int(std::string name, int default_value) {
	LuaObject *token = get_token(name);
	return (token != nullptr && (token->type == NUMBER || token->type == INTEGER)) ? (int)token->number : default_value;
}

float LuaObject::get_float(std::string name, float default_value) {
	LuaObject *token = get_token(name);
	return (token != nullptr && token->type == NUMBER) ? (float)token->number : default_value;
}

bool LuaObject::get_boolean(std::string name, bool default_value) {
	LuaObject *token = get_token(name);
	return (token != nullptr && token->type == BOOLEAN) ? token->boolean : default_value;
}

std::string LuaObject::get_string(std::string name, std::string default_value) {
	LuaObject *token = get_token(name);
	return (token != nullptr && token->type == STRING) ? token->string : default_value;
}

int LuaObject::get_int(std::string name) {
	LuaObject *token = get_token(name);
	if (token != nullptr && (token->type == NUMBER || token->type == INTEGER))
		return (int)token->number;
	else
		throw LuaException("token \"" + name + "\" is not int");
}

float LuaObject::get_float(std::string name) {
	LuaObject *token = get_token(name);
	if (token != nullptr && token->type == NUMBER)
		return (float)token->number;
	else
		throw LuaException("token \"" + name + "\" is not float");
}

bool LuaObject::get_boolean(std::string name) {
	LuaObject *token = get_token(name);
	if (token != nullptr && token->type == BOOLEAN)
		return token->boolean;
	else
		throw LuaException("token \"" + name + "\" is not boolean");
}

std::string LuaObject::get_string(std::string name) {
	LuaObject *token = get_token(name);
	if (token != nullptr && token->type == STRING)
		return token->string;
	else
		throw LuaException("token \"" + name + "\" is not string");
}

std::map<std::string, LuaObject> LuaObject::get_map(std::string name) {
	LuaObject *token = get_token(name);
	if (token != nullptr && token->type == OBJECT)
		return token->object;
	else
		throw LuaException("token \"" + name + "\" is not object");
}

// This function is used to call a function from a table at the top of the stack. This is useful in C implemented functions called in lua that receive a table as parameter.
std::string Lua::call_table_function(LuaObject *token, std::string function_name) {
	std::vector<std::string> path = splitstr(token->get_path(), '.');
	return call_function_recursive(path, function_name, 0);
}

// These two functions are used to call a function from a public table in a lua script.
void Lua::call_function(LuaObject *token, std::string table_name, std::string function_name) {
	std::vector<std::string> path = splitstr(token->get_path(), '.');
	lua_getglobal(state, table_name.c_str());
	call_function_recursive(path, function_name, 0);
	lua_pop(state, 1);
}

void Lua::call_function(LuaObject *token, std::string table_name) {
	std::vector<std::string> path = splitstr(token->get_path(), '.');
	lua_getglobal(state, table_name.c_str());
	call_function_recursive(std::vector<std::string>(path.begin(), path.end() -1), token->get_function_name(), 0);
	lua_pop(state, 1);
}

std::string Lua::call_function_recursive(std::vector<std::string> path, std::string function_name, int level) {
	std::string rval = "";
	lua_pushnil(state);
	while (lua_next(state, -2)) {
		std::string key = "";

		if (lua_type(state, -2) == LUA_TNUMBER) {
			int index = (int) lua_tointeger(state, -2);
			key = std::to_string(index);
		}
		else {
			key = std::string(lua_tostring(state, -2));
		}
		// for (int i = 0; i < level; i++)
		// 	std::cout << "  ";
		// std::cout << key << ": ";

		int type = lua_type(state, -1);
		switch (type) {
		case LUA_TTABLE:
			if (path.size() > 0 && key == path[0]) {
				// std::cout << key << "..." << std::endl;
				rval = call_function_recursive(std::vector<std::string>(path.begin() + 1, path.end()), function_name, level + 1);
			}
			lua_pop(state, 1);
			break;
		case LUA_TFUNCTION:
			if (path.size() == 0 && key == function_name) {
				// std::cout << "-- execute " + key + " -- " << std::endl;
				{
					int callback_reference = luaL_ref(state, LUA_REGISTRYINDEX);
					lua_rawgeti(state, LUA_REGISTRYINDEX, callback_reference);

					lua_pushstring(state, "arg");
					if (lua_pcall(state, 1, 1, 0) != 0) {
						std::cout << ("Failed to call the callback!\n %s\n", lua_tostring(state, -1)) << std::endl;
					}

					if (lua_isstring(state, -1)) {
						rval = lua_tostring(state, -1);
					}
					lua_pop(state, 1);

					luaL_unref(state, LUA_REGISTRYINDEX, callback_reference);
				}
			}
			else {
				lua_pop(state, 1);
			}
			break;
		default:
			lua_pop(state, 1);
			break;
		}
	}
	return rval;
}


size_t LuaObject::size() const {
	if (type == OBJECT) {
		return object.size();
	}
	return 0;
}

LuaObject Lua::get_object(std::string name) {
	lua_getglobal(state, name.c_str());
	LuaObject object = get_child_object(name);
	object.path = name;
	lua_pop(state, 1);
	return object;
}

LuaObject Lua::get_child_object(std::string parent_path) {
	LuaObject obj(this);
	obj.type = LuaObject::Type::OBJECT;
	obj.object = std::map<std::string, LuaObject>();

	lua_pushnil(state);
	while (lua_next(state, -2)) {
		std::string key = "";
		LuaObject value(this);

		if (lua_type(state, -2) == LUA_TNUMBER) {
			int index = (int) lua_tointeger(state, -2);
			key = std::to_string(index);
		}
		else {
			key = std::string(lua_tostring(state, -2));
		}
		value.path += parent_path == "" ? key : (parent_path + "." + key);

		int type = lua_type(state, -1);
		switch (type) {
		case LUA_TSTRING:
			value.type = LuaObject::Type::STRING;
			value.string = lua_tostring(state, -1);
			break;
		case LUA_TBOOLEAN:
			value.type = LuaObject::Type::BOOLEAN;
			value.boolean = lua_toboolean(state, -1) ? true : false;
			break;
		case LUA_TNUMBER:
			value.type = LuaObject::Type::NUMBER;
			value.number = (float)lua_tonumber(state, -1);
			break;
		case LUA_TTABLE:
			value.type = LuaObject::Type::OBJECT;
			value.object = get_child_object(value.path).object;
			break;
		case LUA_TFUNCTION:
			value.type = LuaObject::Type::FUNCTION;
			value.function_name = key;
#if true
			{
				// std::cout << "---------------------" << std::endl;
				// std::cout << stack_dump() << std::endl;

				lua_rawgeti(state, LUA_REGISTRYINDEX, registry_index);  // push registry table
				// std::cout << "registry index: " << registry_index << std::endl;

				lua_pushvalue(state, -2);  // copy the function to the top of the stack

				value.function_index = luaL_ref(state, -2);  // copy the function to the registry and pop it from the stack
				// std::cout << "NEW function index: " << value.function_index << ", function name: " << value.function_name << std::endl;

				lua_pop(state, 1);  // pop the table
				// std::cout << stack_dump() << std::endl;

				// std::cout << "---------------------" << std::endl;
			}
#else
			{
				lua_pushvalue(state, -1);  // copy the function because it will be popped now
				value.function_index = luaL_ref(state, LUA_REGISTRYINDEX);
			}
#endif
			break;
		case LUA_TNIL:
			value.type = LuaObject::Type::NULL_OBJECT;
			break;
		}
		obj.object[key] = value;
		lua_pop(state, 1);
	}

	return obj;
}

std::string LuaObject::call_function(std::string name, LuaObject arg) {
	LuaObject *token = get_token(name);
	if (token != nullptr && token->type == FUNCTION) {
		std::string rval = "";
		lua_State *state = lua->get_state();

#if true
		{
			// std::cout << "---------------------" << std::endl;
			// std::cout << lua->stack_dump() << std::endl;

			lua_rawgeti(state, LUA_REGISTRYINDEX, lua->get_registry_index());  // push the table
			// std::cout << "registry index: " << lua->get_registry_index() << std::endl;

			lua_rawgeti(state, -1, token->function_index);  // push the function from the table
			// std::cout << "function index: " << token->function_index << std::endl;
			// std::cout << "function name: " << token->function_name << std::endl;

			// std::cout << "---------------------" << std::endl;

			switch (arg.get_type()) {
			case Type::INTEGER:
				lua_pushinteger(state, arg.get_int());
				break;
			case Type::NUMBER:
				lua_pushnumber(state, arg.get_float());
				break;
			case Type::STRING:
				lua_pushstring(state, arg.get_string().c_str());
				break;
			default:
				lua_pushstring(state, "");
				break;
			}
			// std::cout << lua->stack_dump() << std::endl;
			if (lua_pcall(state, 1, 1, 0) != 0) {
				// std::cout << lua->stack_dump() << std::endl;
				std::cout << "Failed to call the callback! " << lua_tostring(state, -1) << std::endl;
			}

			if (lua_isstring(state, -1)) {
				rval = lua_tostring(state, -1);
			}
			lua_pop(state, 1);
			lua_pop(state, 1);
		}
#else
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX, token->function_index);  // push the function from the table

			lua_pushstring(state, "arg");
			if (lua_pcall(state, 1, 1, 0) != 0) {
				std::cout << "Failed to call the callback! " << lua_tostring(state, -1) << std::endl;
			}

			if (lua_isstring(state, -1)) {
				rval = lua_tostring(state, -1);
			}
			lua_pop(state, 1);
		}
#endif
		return rval;
	}
	else
		throw LuaException("token \"" + name + "\" is not function");
}


void LuaObject::delete_functions() {
	// std::cout << "+++++++++++ deleting functions ++++++++++++" << std::endl;
	delete_functions_recursive(*this);
}

void LuaObject::delete_functions_recursive(LuaObject &object) {
	switch (object.type) {
	case OBJECT:
		for (auto it = object.begin(); it != object.end(); ++it) {
			LuaObject &child = it->second;
			delete_functions_recursive(child);
		}
		break;
	case FUNCTION:
#if true
		// std::cout << "deleting function: " << object.function_index << ", " << object.function_name << std::endl;
		{
			auto state = lua->get_state();
			lua_rawgeti(state, LUA_REGISTRYINDEX, lua->get_registry_index());  // push the table
			luaL_unref(state, -1, object.function_index);
			lua_pop(state, 1);
		}
#else
		{
			luaL_unref(lua->get_state(), LUA_REGISTRYINDEX, object.function_index);
			break;
		}
#endif
	}
}

void LuaObject::dump_map() {
	std::cout << "{" << std::endl;
	dump_map_recursive(*this, 1);
	std::cout << "}" << std::endl;
}

void LuaObject::dump_map_recursive(LuaObject &obj, int indent) {
	std::string spaces = "";
	for (int i = 0; i < indent; i++)
		spaces += "  ";

	switch (obj.type) {
	case STRING:
		std::cout << "\"" << obj.get_string() << "\"";
		break;
	case NUMBER:
		std::cout << obj.get_float();
		break;
	case BOOLEAN:
		std::cout << (obj.get_boolean() ? "true" : "false");
		break;
	case OBJECT:
		std::cout << "(table) " << std::endl;
		{
			LuaObject *child = obj.get_object();
			for (auto it = child->begin(); it != child->end(); ++it) {
				std::cout << spaces << it->first << " = ";
				dump_map_recursive(it->second, indent + 1);
				std::cout << std::endl;
			}
		}
		break;
	case FUNCTION:
		std::cout << "(function)";
		break;
	case NULL_OBJECT:
		std::cout << "(nil)";
		break;
	}
}

LuaObject LuaObject::wrap_int(int i) {
	LuaObject obj;
	obj.type = LuaObject::Type::INTEGER;
	obj.number = (float)i;
	return obj;
}

LuaObject LuaObject::wrap_number(float i) {
	LuaObject obj;
	obj.type = LuaObject::Type::NUMBER;
	obj.number = i;
	return obj;
}

LuaObject LuaObject::wrap_string(std::string s) {
	LuaObject obj;
	obj.type = LuaObject::Type::STRING;
	obj.string = s;
	return obj;
}
