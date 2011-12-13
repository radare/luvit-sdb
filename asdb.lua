#!/usr/bin/env luvit
-- WORK IN PROGRESS API FOR ASYNC SDB API FOR LUVIT --
local SDB = require ("./sdb.luvit")

local ASDB = {}
function ASDB.open(x,y,f)
	SDB.open
end

function ASDB.sync(x)
	-- async disk sync?
end

ASDB.open ("test.sdb", false, function (x)
	x:set ("name", "pancake")
	x:set ("location", "barcelona")
	x:sync ();
end)
