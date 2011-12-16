-------------------------------------------------------------------------------
-- LuaSocket connector
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local error = error
local http = require( "socket.http" )

function facepunch.http.get( URL )
	local r, c = http.request( URL )
	return r, c
end

function facepunch.http.post( URL, postData )
	error( "not yet implemented!", 2 )
end
