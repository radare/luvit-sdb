local ffi = require ('ffi')

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
function Sdb:get(k)
        return ffi.string (ffi.sdb.sdb_get (self.obj, k))
end
function Sdb:sync()
        return ffi.sdb.sdb_sync (self.obj)
end
function Sdb:free()
        return ffi.sdb.sdb_free (self.obj)
end

return Sdb
