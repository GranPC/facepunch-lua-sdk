local MODULE = "luacurl"

-- can we find a better solution for this?
if ( MODULE == "socket" ) then
	local http = require( "socket.http" )
elseif ( MODULE == "luacurl" ) then
	require( "luacurl" )
	local curl = curl
else
	error( "no module specified" )
end

module( "facepunch" )

rootURL		= "http://www.facepunch.com"

baseURL		= rootURL .. "/"
indexPage	= "index.php" -- forum.php
showThread	= "showthread.php"
showPost	= "showpost.php"
userCP		= "usercp.php"
profileCP	= "profile.php"
newThread	= "newthread.php"
newReply	= "newreply.php"
loginPage	= "login.php"
logoutPage	= "login.php"

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
