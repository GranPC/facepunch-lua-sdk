-------------------------------------------------------------------------------
-- LuaSocket connector
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local error = error
local http = require( "socket.http" )

function facepunch.http.get( URL, session )
	local r, c = http.request( URL )
	return r, c, cookie
end

function facepunch.http.post( URL, session, postData )
	error( "not yet implemented!" )
end
