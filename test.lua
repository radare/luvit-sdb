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

db:set ("g", [[
{"glossary":{"title":"example glossary","page":1,"GlossDiv":{"title":"First gloss title","GlossList":{"GlossEntry":{"ID":"SGML","SortAs":"SGML","GlossTerm":"Standard Generalized Markup Language","Acronym":"SGML","Abbrev":"ISO 8879:1986","GlossDef":{"para":"A meta-markup language, used to create markup languages such as DocBook.","GlossSeeAlso":["OK","GML","XML"]},"GlossSee":"markup"}}}}} 
]])
p (db:json_get ("g", "glossary.title"))
p (db:json_get ("g", "glossary.GlossDiv.GlossList.GlossEntry.GlossDef.GlossSeeAlso[0]"))

print (db:json_indent (db:get ("g")))
-- store database
db:sync ()

db:free ()
