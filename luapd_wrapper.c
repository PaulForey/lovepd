#include "libpd/libpd_wrapper/z_libpd.h"
#include "lua.h"
#include <stdio.h>

/*
 * Required functions (in order of z_libpd.h):
 * 	libpd_init
 * 	libpd_openfile
 * 	libpd_init_audio
 * 	libpd_process_float
 * 	libpd_start_message
 * 	libpd_add_float
 * 	libpd_add_symbol
 * 	libpd_finish_message
 * 	libpd_printhook --Tricky, gonna require passing a lua function
 * 										as an argument.
 */


static int luapd_init(lua_State *L) {
	libpd_init();
	return 0;
}

static int luapd_openfile(lua_State *L) {
	const char *basename = lua_tostring(L, 1);
	const char *dirname = lua_tostring(L, 2);
	lua_pushinteger(L, libpd_openfile(basename, dirname) ? 1 : 0);
	return 1;
}

static int luapd_init_audio(lua_State *L) {
	double inChannels = lua_tonumber(L, 1);
	double outChannels = lua_tonumber(L, 2);
	double sample_rate = lua_tonumber(L, 3);
	libpd_init_audio((int)inChannels, (int)outChannels, (int)sample_rate);
	return 0;
}


static int luapd_process_float(lua_State *L) {
	int ticks = lua_tointeger(L, 1);
	int inbuf_size = lua_objlen(L, 2);
	int outbuf_size = lua_objlen(L, 3);
	float inbuf[inbuf_size];
	float outbuf[outbuf_size];

	lua_pushnil(L); // Preps the stack for lua_next

	// Retrieving the table from lua:
	int i = 0;
	while (lua_next(L, 2) != 0) {
		inbuf[i] = (float)lua_tonumber(L, -1);
		lua_pop(L, 1);
		i++;
	}

	// Operating on the table:
	libpd_process_float(ticks, inbuf, outbuf);

	// Pushing the table back to lua:
	for(i = 0; i < outbuf_size; i++) {
		lua_pushnumber(L, i+1);
		lua_pushnumber(L, outbuf[i]);
		lua_settable(L, 3);	// Push values into the table.
	}

	return 1; //Let lua know we have one result (one table).
}

static int luapd_start_message(lua_State *L) {
	int max_length = lua_tointeger(L, 1);
	lua_pushinteger(L, libpd_start_message(max_length));
	return 1;
}

static int luapd_add_float(lua_State *L) {
	libpd_add_float((float)lua_tonumber(L, 1));
	return 0;
}

static int luapd_add_symbol(lua_State *L) {
	libpd_add_symbol(lua_tostring(L, 1));
	return 0;
}

static int luapd_finish_message(lua_State *L) {
	const char *receiver = lua_tostring(L, 1);
	const char *message = lua_tostring(L, 2);
	lua_pushinteger(L, libpd_finish_message(receiver, message));
	return 1;
}

/*
static int luapd_printhook(lua_State *L) {
	libpd_printhook
*/

int luaopen_luapd_wrapper(lua_State *L) {
	lua_register(L, "luapd_init", luapd_init);
	lua_register(L, "luapd_openfile", luapd_openfile);
	lua_register(L, "luapd_init_audio", luapd_init_audio);
	lua_register(L, "luapd_process_float", luapd_process_float);
	lua_register(L, "luapd_start_message", luapd_start_message);
	lua_register(L, "luapd_add_float", luapd_add_float);
	lua_register(L, "luapd_add_symbol", luapd_add_symbol);
	lua_register(L, "luapd_finish_message", luapd_finish_message);
}
	
	



