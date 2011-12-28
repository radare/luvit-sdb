/* Copyleft -- pancake <pancake@nopcode.org> */
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>
#include <sdb.h>

typedef ut64 (*SdbDeltaFcn)(Sdb *sdb, const char *key, ut64 n);

static Sdb *getdb(lua_State *l) {
	lua_getfield (l, 1, "__db");
	return lua_touserdata (l, -1);
}

static int luasdb_delta(lua_State *l, SdbDeltaFcn fcn) {
	Sdb *db = getdb (l);
	if (db) {
		int delta = 1;
		if (lua_gettop (l) == 4)
			delta = lua_tonumber (l, 3);
		ut64 n = fcn (db, lua_tostring (l, 2), delta);
		if (n) lua_pushnumber (l, n);
		else lua_pushnil (l);
	} else printf ("NULL DB\n");
	lua_pushnil (l);
	return 1;
}

static int luasdb_inc(lua_State *l) {
	return luasdb_delta (l, sdb_inc);
}

static int luasdb_dec(lua_State *l) {
	return luasdb_delta (l, sdb_dec);
}

static int luasdb_expire(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db)
		ret = sdb_expire (db, lua_tostring (l, 2), lua_tonumber (l, 3));
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_now(lua_State *l) {
	ut64 now = sdb_now ();
	lua_pushnumber (l, now);
	return 1;
}

static int luasdb_nexists(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db) ret = sdb_nexists (db, lua_tostring (l, 2));
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_exists(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db) ret = sdb_exists (db, lua_tostring (l, 2));
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_get(lua_State *l) {
	char *s = NULL;
	Sdb *db = getdb (l);
	if (db) {
		s = sdb_get (db, lua_tostring (l, 2));
		if (s) {
			if (*s) {
				lua_pushstring (l, s);
				free (s);
			} else {
				free (s); 
				s = NULL;
			}
		}
	}
	if (!s) lua_pushnil (l);
	return 1;
}

static int luasdb_set(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db) {
		switch (lua_gettop (l)) {
		case 4:
			ret = sdb_set (db, lua_tostring (l, 2), lua_tostring (l, 3));
			break;
		case 3:
			ret = sdb_delete (db, lua_tostring (l, 2));
			break;
		default:
			printf ("wrong arguments for set\n");
			break;
		}
	} else printf ("null db\n");
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_delete(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db && lua_gettop (l) == 3) {
		ret = sdb_delete (db, lua_tostring (l, 2));
	} else printf ("delete.err\n");
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_sync(lua_State *l) {
	int ret = 0;
	Sdb *db = getdb (l);
	if (db) ret = sdb_sync (db);
	else printf ("db is null\n");
	lua_pushboolean (l, ret);
	return 1;
}

static int luasdb_close(lua_State *l) {
	Sdb *db = getdb (l);
	if (db) sdb_free (db);
	else printf ("free.error\n");
	return 0;
}

static int luasdb_open(lua_State *l) {
	int i;
	Sdb *db;
	size_t len;
	int lock = 0;
	const char *file;
	const luaL_Reg methods[] = {
		{ "nexists", luasdb_nexists },
		{ "exists", luasdb_exists },
		{ "set", luasdb_set },
		{ "get", luasdb_get },
		{ "expire", luasdb_expire },
		{ "delete", luasdb_delete },
		{ "inc", luasdb_inc },
		{ "dec", luasdb_dec },
		{ "sync", luasdb_sync },
		{ "close", luasdb_close },
		{ NULL, NULL }
	};

	if (lua_gettop (l)==2) {
		if (lua_isboolean (l, 2))
			lock = lua_toboolean (l, 2);
		else
		if (lua_isnumber (l, 2))
			lock = lua_tonumber (l, 2)? 1: 0;
	}
	file = luaL_checklstring(l, 1, &len);
	db = sdb_new (file, lock);
	lua_newtable (l);
	lua_pushlightuserdata (l, db);
	lua_setfield (l, -2, "__db");

	for (i=0; methods[i].name; i++) {
		lua_pushcfunction (l, methods[i].func);
		lua_setfield (l, -2, methods[i].name);
	}
	return 1;
}

LUALIB_API int luaopen_sdb(lua_State *l) {
	const luaL_Reg sdblib[] = {
		{ "open", luasdb_open },
		{ "now", luasdb_now },
		{ NULL, NULL }
	};
	luaL_openlib(l, "sdb", sdblib, 0);
	return 1;
}
