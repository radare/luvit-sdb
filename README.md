luvit-sdb
=========
This module wraps libsdb to be used from LUA or LUVIT.

sdb is a simple key-value database written in C with on-disk storage
designed to be fast and reliable.

This api is synchronous. There are plans to write an async api
for sdb on top of luvit.

External
--------
You may find sdb source repository here:

	hg clone http://hg.youterm.com/sdb

Example
-------
Sdb api has been changed a bit to fit better with

	local SDB = require ("sdb")
	local db = SDB.open ("test.sdb", false)
	db:set ("foo", 33)   -- foo = 33
	db:inc ("foo", 3)    -- foo += 3
	p ("hello", db:get ("foo"))
	db:sync ()           -- store database on disk
	db:close ()
