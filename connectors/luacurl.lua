-------------------------------------------------------------------------------
-- LuaCURL connector
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
require( "luacurl" )

local curl = curl
local string = string
local table = table
local tonumber = tonumber

local function curlWrite( bufferTable )
	return function( stream, buffer )
		table.insert( bufferTable, buffer )
		return string.len( buffer )
	end
end

function facepunch.http.get( URL )
	local t = {}
	local curlObj = curl.new()
	
	curlObj:setopt( curl.OPT_HEADER, true )
	curlObj:setopt( curl.OPT_WRITEFUNCTION, curlWrite( t ) )
	curlObj:setopt( curl.OPT_URL, URL )
	
	curlObj:perform()
	curlObj:close()
	
	local r = table.concat( t, "" )
	local h, c, m = string.match( r, "(.-) (.-) (.-)\n" )
	return r, tonumber( c )
end

function facepunch.http.post( URL, postData )
	error( "not yet implemented!", 2 )
end
