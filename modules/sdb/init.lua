local ffi = require ('ffi')
local JSON = require ('json')

local usejson = true
-- this hardcoded path should not be static --
ffi.sdb = ffi.load ("./modules/sdb/sdb.luvit")
ffi.cdef ([[
        typedef struct sdb_t {
        } Sdb;
        typedef unsigned long ut32;
        typedef unsigned long long ut64;
        Sdb* sdb_new(const char *str, int m);
        void sdb_free (Sdb*);
        void sdb_file (Sdb*, const char *dir);
        void sdb_reset (Sdb*);
        int sdb_exists (Sdb*, const char *key);
        int sdb_nexists (Sdb*, const char *key);
        int sdb_delete (Sdb*, const char *key);
        char *sdb_get (Sdb*, const char *key);
        int sdb_set (Sdb*, const char *key, const char *data);
        void sdb_list(Sdb*);
        int sdb_sync (Sdb*);
        void sdb_kv_free (struct sdb_kv *kv);
        void sdb_dump_begin (Sdb* s);
        int sdb_add (struct cdb_make *c, const char *key, const char *data);
        int sdb_dump_next (Sdb* s, char *key, char *value);
        void sdb_flush (Sdb* s);
        ut64 sdb_getn (Sdb* s, const char *key);
        void sdb_setn (Sdb* s, const char *key, ut64 v);
        ut64 sdb_inc (Sdb* s, const char *key, ut64 n);
        ut64 sdb_dec (Sdb* s, const char *key, ut64 n);

        int sdb_lock(const char *s);
        const char *sdb_lockfile(const char *f);
        void sdb_unlock(const char *s);
        int sdb_expire(Sdb* s, const char *key, ut64 expire);
        ut64 sdb_get_expire(Sdb* s, const char *key);
        ut64 sdb_now ();
        ut32 sdb_hash ();

	char *sdb_json_get (Sdb *s, const char *k, const char *p);
	int sdb_json_geti (Sdb *s, const char *k, const char *p);
	int sdb_json_seti (Sdb *s, const char *k, const char *p, int v);
	int sdb_json_set (Sdb *s, const char *k, const char *p, const char *v);
	char *sdb_json_indent(const char *s);
	char *sdb_json_unindent(const char *s);
]])

local Sdb = {}
function Sdb:new(file, mode)
        if not mode then mode = 0 end
        self.obj = ffi.sdb.sdb_new (file, mode)
        return self
end
function Sdb:free()
        return ffi.sdb.sdb_free (self.obj)
end
function Sdb:exists(k)
	return ffi.sdb.sdb_exists (self.obj, k)
end
function Sdb:nexists(k)
	return ffi.sdb.sdb_nexists(self.obj, k)
end
function Sdb:delete(k)
	return ffi.sdb.sdb_delete (self.obj, k)
end
function Sdb:exists(k)
	return ffi.sdb.sdb_exists(k)
end
function Sdb:set(k,v)
        if type(v) == "number" then
                v = tostring (v)
        elseif type(v) == "table" then
                v = JSON.stringify (v)
        end
        return ffi.sdb.sdb_set (self.obj, k, v)
end
function Sdb:inc(k,v)
        return ffi.sdb.sdb_inc (self.obj, k, v)
end
function Sdb:dec(k,v)
        return ffi.sdb.sdb_dec (self.obj, k, v)
end
function Sdb:get(k)
        local str = ffi.string (ffi.sdb.sdb_get (self.obj, k))
	if usejson and str:sub (1,1) == '{' and str:sub (#str) == '}' then
		return JSON.parse (str)
	end
	return str
end
function Sdb:getn(k)
	-- TODO check if ut64 values work after cast
        return tonumber (ffi.sdb.sdb_getn (self.obj, k))
end
function Sdb:setn(k, v)
        return ffi.sdb.sdb_setn (self.obj, k, tonumber (v))
end
function Sdb:lock(file)
	return ffi.sdb.sdb_lock (file)
end
function Sdb.unlock(file)
	return ffi.sdb.sdb_unlock (file)
end
function Sdb:set_expire(k,e)
	return ffi.sdb.sdb_set_expire(self.obj, k, e)
end
function Sdb:get_expire(k)
	return ffi.sdb.sdb_get_expire(self.obj, k)
end
function Sdb:sync()
        return ffi.sdb.sdb_sync (self.obj)
end
function Sdb:free()
        return ffi.sdb.sdb_free (self.obj)
end
-- json
function Sdb:json_get(k,p)
        local str = ffi.string (ffi.sdb.sdb_json_get (self.obj, k, p))
	if usejson and str:sub (1,1) == '{' and str:sub (#str) == '}' then
		return JSON.parse (str)
	end
	return str
end
function Sdb:json_set(k,p,v)
        return ffi.sdb.sdb_json_set (self.obj, k, p, v)
end
function Sdb:json_seti(k,p,v)
        return ffi.sdb.sdb_json_seti (self.obj, k, p, v)
end
function Sdb:json_geti(k,p)
        return ffi.sdb.sdb_json_geti (self.obj, k, p)
end
function Sdb:json_indent(s)
        return ffi.string (ffi.sdb.sdb_json_indent (s))
end
function Sdb:json_unindent(s)
        return ffi.string (ffi.sdb.sdb_json_unindent (s))
end
return Sdb
