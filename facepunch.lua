local http = require( "socket.http" )

module( "facepunch" )

baseURL = "http://www.facepunch.com/"
rootURL = "http://www.facepunch.com"

-------------------------------------------------------------------------------
-- request()
-- Purpose: The core request function for the facepunch module. All retrieval
--			functions rely on this wrapper for parsing. It must return the full
--			page if possible and a status code (200 OK).
-- Input: URL
-- Output: document, status code
-------------------------------------------------------------------------------
function request( URL )
	return http.request( URL )
end
