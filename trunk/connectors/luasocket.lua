-------------------------------------------------------------------------------
-- LuaSocket connector
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local error = error
local http = require( "socket.http" )
local ltn12 = require( "ltn12" )
local string = string
local table = table

function facepunch.http.get( URL, session )
	local t = {}
	local cookie = nil
	if ( session and session.cookie ) then
		cookie = session.cookie
	end
	local headers = {}
	headers[ "Cookie" ] = cookie
	local r, c, h = http.request({
		url = URL,
		sink = ltn12.sink.table( t ),
		headers = headers
	})
	r = table.concat( t, "" )
	t = {}
	for k, v in pairs( h ) do
		if ( k == "set-cookie" ) then
			v = string.gsub( v, "(expires=.-; )", "" )
			v = string.gsub( v, "(path=.-; )", "" )
			v = string.gsub( v, "(HttpOnly, )", "" )
			v = string.gsub( v, "(domain=.-; )", "" )
			v = string.gsub( v, "(domain=.-, )", "" )
			for cookie in string.gmatch( v, "(.-=.-);" ) do
				cookie = string.gsub( cookie, "^%s*(.-)%s*$", "%1" )
				table.insert( t, cookie )
			end
		end
	end
	cookie = table.concat( t, "; " )
	return r, c, cookie
end

function facepunch.http.post( URL, session, postData )
	local t = {}
	local cookie = nil
	if ( session and session.cookie ) then
		cookie = session.cookie
	end
	postData = postData or ""
	local headers = {}
	headers[ "Content-Type" ] = "application/x-www-form-urlencoded"
	headers[ "Content-Length" ] = string.len( postData )
	headers[ "Cookie" ] = cookie
	local r, c, h = http.request( {
		url = URL,
		source = ltn12.source.string( postData ),
		sink = ltn12.sink.table( t ),
		method = "POST",
		headers = headers,
	}, postData )
	r = table.concat( t, "" )
	t = {}
	for k, v in pairs( h ) do
		if ( k == "set-cookie" ) then
			v = string.gsub( v, "(expires=.-; )", "" )
			v = string.gsub( v, "(path=.-; )", "" )
			v = string.gsub( v, "(HttpOnly, )", "" )
			v = string.gsub( v, "(domain=.-; )", "" )
			v = string.gsub( v, "(domain=.-, )", "" )
			for cookie in string.gmatch( v, "(.-=.-);" ) do
				cookie = string.gsub( cookie, "^%s*(.-)%s*$", "%1" )
				table.insert( t, cookie )
			end
		end
	end
	cookie = table.concat( t, "; " )
	return r, c, cookie
end
