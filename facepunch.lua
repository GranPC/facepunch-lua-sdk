-------------------------------------------------------------------------------
-- Scripted interfacing for Facepunch
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local require = require

module( "facepunch" )

http	= require( "facepunch.http" )
member	= require( "facepunch.member" )
post	= require( "facepunch.post" )
thread	= require( "facepunch.thread" )

baseURL	= "http://www.facepunch.com/"
rootURL	= "http://www.facepunch.com"

-------------------------------------------------------------------------------
-- facepunch.isUp()
-- Purpose: Returns true if not downpunch
-- Output: boolean
-------------------------------------------------------------------------------
function isUp()
	local r, c = request( rootURL )
	return c == 200
end
