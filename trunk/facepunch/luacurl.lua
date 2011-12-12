require( "luacurl" )
local curl = curl
local facepunch = require( "facepunch" )
local string = string
local table = table
local tonumber = tonumber
local setmetatable = setmetatable

module( "facepunch.luacurl" )

local function curlWrite( bufferTable )
	return function( stream, buffer )
		table.insert( bufferTable, buffer )
		return string.len( buffer )
	end
end

function get( URL )
	local dataTbl = {}
	local curlObj = curl.new()
	
	curlObj:setopt( curl.OPT_HEADER, true )
	curlObj:setopt( curl.OPT_VERBOSE, verbose or false )
	
	curlObj:setopt( curl.OPT_WRITEFUNCTION, curlWrite( dataTbl ) )
	
	curlObj:setopt( curl.OPT_URL, URL or rootURL )
	curlObj:setopt( curl.OPT_PORT, 80 )
	
	if ( facepunch.session ) then
		curlObj:setopt( curl.OPT_COOKIESESSION, true )
		curlObj:setopt( curl.OPT_COOKIEFILE, "cookies/" .. facepunch.session.cookieName .. ".txt" )
	end
	
	-- remove this
	--curlObj:setopt( curl.OPT_PROXY, "127.0.0.1" )
	--curlObj:setopt( curl.OPT_PROXYPORT, 1337 )
	--curlObj:setopt( curl.OPT_PROXYTYPE, curl.PROXY_SOCKS5 )
	
	local ok = curlObj:perform()
	curlObj:close()
	
	local data = table.concat( dataTbl, "" )
	local http, status, msg = string.match( data, "(.-) (.-) (.-)\n" )

	return data, tonumber( status )
end

function post( URL, postData )
	local dataTbl = {}
	local curlObj = curl.new()

	curlObj:setopt( curl.OPT_POST, true )
	curlObj:setopt( curl.OPT_HEADER, true )
	curlObj:setopt( curl.OPT_VERBOSE, verbose or false )

	curlObj:setopt( curl.OPT_WRITEFUNCTION, curlWrite( dataTbl ) )

	curlObj:setopt( curl.OPT_URL, URL or rootURL )
	curlObj:setopt( curl.OPT_PORT, 80 )

	curlObj:setopt( curl.OPT_POSTFIELDS, postData )

	if ( facepunch.session ) then
		curlObj:setopt( curl.OPT_COOKIESESSION, true )
		curlObj:setopt( curl.OPT_COOKIEJAR, "cookies/" .. facepunch.session.cookieName .. ".txt" )
		curlObj:setopt( curl.OPT_COOKIEFILE, "cookies/" .. facepunch.session.cookieName .. ".txt" )
	end

	-- remove this
	--curlObj:setopt( curl.OPT_PROXY, "127.0.0.1" )
	--curlObj:setopt( curl.OPT_PROXYPORT, 1337 )
	--curlObj:setopt( curl.OPT_PROXYTYPE, curl.PROXY_SOCKS5 )

	local ok = curlObj:perform()
	curlObj:close()

	local data = table.concat( dataTbl, "" )
	local http, status, msg = string.match( data, "(.-) (.-) (.-)\n" )

	return data, tonumber( status )
end
