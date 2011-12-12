local MODULE = "luacurl"

-- can we find a better solution for this?
local http, luacurl = {}, {}
if ( MODULE == "socket" ) then
	http = require( "socket.http" )
elseif ( MODULE == "luacurl" ) then
	require( "luacurl" )
	luacurl = curl
else
	error( "no module specified" )
end

local string = string
local table = table
local tonumber = tonumber

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
-- curlWrite()
-- Purpose: Helper function for luacurl
-- Input: table
-- Output: function, filling table
-------------------------------------------------------------------------------
local function curlWrite( bufferTable )
	return function( stream, buffer )
		table.insert( bufferTable, buffer )
		return string.len( buffer )
	end
end

-------------------------------------------------------------------------------
-- facepunch.request()
-- Purpose: The core request function for the facepunch module. All retrieval
--			functions rely on this wrapper for parsing. It must return the full
--			page if possible and a status code (200 OK).
-- Input: URL
-- Output: document, status code
-------------------------------------------------------------------------------
function request( URL )
	if ( MODULE == "socket" ) then
		local data, status = http.request( URL )
		return data, status
	elseif ( MODULE == "luacurl" ) then
		local dataTbl = {}
		local curlObj = luacurl.new()
		
		curlObj:setopt( luacurl.OPT_HEADER, true )
		curlObj:setopt( luacurl.OPT_VERBOSE, verbose or false )
		
		curlObj:setopt( luacurl.OPT_WRITEFUNCTION, curlWrite( dataTbl ) )
		
		curlObj:setopt( luacurl.OPT_URL, URL or rootURL )
		curlObj:setopt( luacurl.OPT_PORT, 80 )
		
		-- remove this
		curlObj:setopt( luacurl.OPT_PROXY, "127.0.0.1" )
		curlObj:setopt( luacurl.OPT_PROXYPORT, 1337 )
		curlObj:setopt( luacurl.OPT_PROXYTYPE, luacurl.PROXY_SOCKS5 )
		
		local ok = curlObj:perform()
		curlObj:close()
		
		local data = table.concat( dataTbl, "" )
		local http, status, msg = string.match( data, "(.-) (.-) (.-)\n" )

		return data, tonumber( status )
	else
		return nil, 404
	end
end

-------------------------------------------------------------------------------
-- facepunch.post()
-- Purpose: The core post function for the facepunch module.
-- Input: URL
-- Output: document, status code
-------------------------------------------------------------------------------
function post( URL, postData )
	if ( MODULE == "luacurl" ) then
		local dataTbl = {}
		local curlObj = luacurl.new()
		
		curlObj:setopt( luacurl.OPT_POST, true )
		curlObj:setopt( luacurl.OPT_HEADER, true )
		curlObj:setopt( luacurl.OPT_VERBOSE, verbose or false )
		
		curlObj:setopt( luacurl.OPT_WRITEFUNCTION, curlWrite( dataTbl ) )
		
		curlObj:setopt( luacurl.OPT_URL, URL or rootURL )
		curlObj:setopt( luacurl.OPT_PORT, 80 )
		
		curlObj:setopt( luacurl.OPT_POSTFIELDS, postData )
		
		-- remove this
		curlObj:setopt( luacurl.OPT_PROXY, "127.0.0.1" )
		curlObj:setopt( luacurl.OPT_PROXYPORT, 1337 )
		curlObj:setopt( luacurl.OPT_PROXYTYPE, luacurl.PROXY_SOCKS5 )
		
		local ok = curlObj:perform()
		curlObj:close()
		
		local data = table.concat( dataTbl, "" )
		local http, status, msg = string.match( data, "(.-) (.-) (.-)\n" )

		return data, tonumber( status )
	else
		return nil, 404
	end
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
