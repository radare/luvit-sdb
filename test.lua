#!/usr/bin/env luvit
-- simple test program using sdb from luvit --
local SDB = require ("sdb")

--local db = SDB.open ("test.sdb", false)
local db = SDB:new ()

p (db)

db:set ("foo", 33)
db:inc ("foo", 3)
p ("hello", db:get ("foo"))

local obj = {
	pop=321,
	bar=123
}
db:set ("foo", obj)
p (db:get ("foo"))

db:setn ("num", 1024)
p(db:getn ("num"))

-- store database
db:sync ()

db:free ()
