local error = error
local http = require( "socket.http" )

module( "facepunch" )

baseURL = "http://www.facepunch.com/"
rootURL = "http://www.facepunch.com"

-------------------------------------------------------------------------------
-- facepunch.request()
-- Purpose: The core request function for the facepunch module. All retrieval
--			functions rely on this wrapper for parsing. It must return the full
--			page if possible and a status code (200 OK).
-- Input: URL
-- Output: document, status code
-------------------------------------------------------------------------------
function request( URL )
	local r, c = http.request( URL )
	return r, c
end

-------------------------------------------------------------------------------
-- facepunch.isUp()
-- Purpose: Returns true if not downpunch
-- Output: boolean
-------------------------------------------------------------------------------
function isUp()
	local r, c = request( rootURL )
	return c == 200
end
