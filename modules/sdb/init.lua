local ffi = require ('ffi')
local JSON = require ('json')

-- this hardcoded path should not be static --
ffi.sdb = ffi.load ("./modules/sdb/sdb.luvit")
ffi.cdef ([[
typedef struct sdb_t {
	/* dummy */
} Sdb;
typedef unsigned long ut32;
typedef unsigned long long ut64;
Sdb* sdb_new (const char *dir, int lock);
void sdb_free (Sdb* s);
void sdb_file (Sdb* s, const char *dir);
void sdb_reset (Sdb *s);

int sdb_exists (Sdb*, const char *key);
int sdb_nexists (Sdb*, const char *key);
int sdb_delete (Sdb*, const char *key, ut32 cas);
char *sdb_get (Sdb*, const char *key, ut32 *cas);
int sdb_set (Sdb*, const char *key, const char *data, ut32 cas);
int sdb_add (Sdb *s, const char *key, const char *val);
void sdb_list(Sdb*);
int sdb_sync (Sdb*);
void sdb_kv_free (struct sdb_kv *kv);
void sdb_flush (Sdb* s);

/* create db */
int sdb_create (Sdb *s);
int sdb_append (Sdb *s, const char *key, const char *val);
int sdb_finish (Sdb *s);

/* iterate */
void sdb_dump_begin (Sdb* s);
int sdb_dump_next (Sdb* s, char *key, char *value); // XXX: needs refactor?

/* numeric */
ut64 sdb_getn (Sdb* s, const char *key, ut32 *cas);
int sdb_setn (Sdb* s, const char *key, ut64 v, ut32 cas);
ut64 sdb_inc (Sdb* s, const char *key, ut64 n, ut32 cas);
ut64 sdb_dec (Sdb* s, const char *key, ut64 n, ut32 cas);

/* locking */
int sdb_lock(const char *s);
const char *sdb_lockfile(const char *f);
void sdb_unlock(const char *s);

/* expiration */
int sdb_expire(Sdb* s, const char *key, ut64 expire);
ut64 sdb_get_expire(Sdb* s, const char *key);
// int sdb_get_cas(Sdb* s, const char *key) -> takes no sense at all..
ut64 sdb_now ();
ut32 sdb_hash ();

/* json api */
char *sdb_json_get (Sdb *s, const char *key, const char *p, ut32 *cas);
int sdb_json_geti (Sdb *s, const char *k, const char *p);
int sdb_json_seti (Sdb *s, const char *k, const char *p, int v, ut32 cas);
int sdb_json_set (Sdb *s, const char *k, const char *p, const char *v, ut32 cas);

int sdb_json_dec(Sdb *s, const char *k, const char *p, int n, ut32 cas);
int sdb_json_inc(Sdb *s, const char *k, const char *p, int n, ut32 cas);

char *sdb_json_indent(const char *s);
char *sdb_json_unindent(const char *s);
]])

local Sdb = {}
function Sdb:new(file, mode)
        if not mode then mode = 0 end
	self.type = "Sdb"
	self.usejson = false
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
function Sdb:delete(k, c)
	if not c then c = 0 end
	return ffi.sdb.sdb_delete (self.obj, k, c)
end
function Sdb:exists(k)
	return ffi.sdb.sdb_exists(k)
end
function Sdb:set(k,v,c)
        if type(v) == "number" then
                v = tostring (v)
        elseif type(v) == "table" then
                v = JSON.stringify (v)
        end
	if not c then c = 0 end
        return ffi.sdb.sdb_set (self.obj, k, v, c)
end
function Sdb:inc(k,v, c)
	if not c then c = 0 end
        return ffi.sdb.sdb_inc (self.obj, k, v, c)
end
function Sdb:dec(k,v)
        return ffi.sdb.sdb_dec (self.obj, k, v)
end
function Sdb:get(k)
	local cas = ffi.new ("ut32[1]", 0)
        local str = ffi.string (ffi.sdb.sdb_get (self.obj, k, cas))
	if self.usejson and str:sub (1, 1) == '{' and str:sub (#str) == '}' then
		return JSON.parse (str), cas[0]
	end
	return str, cas[0]
end
function Sdb:getn(k)
	-- TODO check if ut64 values work after cast
	local cas = ffi.new ("ut32[1]", 0)
        local num = tonumber (ffi.sdb.sdb_getn (self.obj, k, cas))
	return num, cas[0]
end
function Sdb:setn(k, v, c)
	if not c then c = 0 end
        return ffi.sdb.sdb_setn (self.obj, k, tonumber (v), c)
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
function Sdb:useJSON(v)
	if v == nil then v = true else
		if v then v = true else v = false end
	end
	self.usejson = v
	return self
end
-- json
function Sdb:jsonGet(k,p)
	local cas = ffi.new ("ut32[1]", 0)
        local str = ffi.string (ffi.sdb.sdb_json_get (self.obj, k, p, cas))
	return str, cas[0]
end
function Sdb:jsonSet(k,p,v,c)
	if not c then c = 0 end
        return ffi.sdb.sdb_json_set (self.obj, k, p, v, c)
end
function Sdb:jsonSeti(k,p,v,c)
	if not c then c = 0 end
        return ffi.sdb.sdb_json_seti (self.obj, k, p, v)
end
function Sdb:jsonGeti(k,p)
	local cas = ffi.new ("ut32[1]", 0)
        local str = ffi.sdb.sdb_json_geti (self.obj, k, p, cas)
	return str, cas[0]
end
function Sdb:jsonIndent(s)
        return ffi.string (ffi.sdb.sdb_json_indent (s))
end
function Sdb:jsonUnindent(s)
        return ffi.string (ffi.sdb.sdb_json_unindent (s))
end
return Sdb
