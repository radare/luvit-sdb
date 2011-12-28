#!/usr/bin/env luvit
-- simple test program using sdb from luvit --
local SDB = require ("sdb")

--local db = SDB.open ("test.sdb", false)
local db = SDB.open ()

p (db)

db:set ("foo", 33)
db:inc ("foo", 3)
p ("hello", db:get ("foo"))

-- store database
db:sync ()

db:close ()
