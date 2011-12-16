-------------------------------------------------------------------------------
-- HTTP wrapper module
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local error = error

module( "facepunch.http" )

-------------------------------------------------------------------------------
-- facepunch.get()
-- Purpose: The get wrapper function for the facepunch module. All retrieval
--			functions rely on this wrapper for parsing. It must return the full
--			page if possible and a status code (200 OK).
-- Input: URL - URL to get
-- Output: document, status code
-------------------------------------------------------------------------------
function get( URL )
	error( "facepunch.http.get was not implemented!" )
end

-------------------------------------------------------------------------------
-- facepunch.post()
-- Purpose: The post wrapper function for the facepunch module. All submission
--			functions rely on this wrapper for interaction. It must return the
--			full page if possible and a status code (200 OK).
-- Input: URL - URL to post to
--		  postData - table of POST information
-- Output: document, status code
-------------------------------------------------------------------------------
function post( URL, postData )
	error( "facepunch.http.post was not implemented!" )
end
