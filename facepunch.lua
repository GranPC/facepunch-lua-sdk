-------------------------------------------------------------------------------
-- LuaJIT FFI
-------------------------------------------------------------------------------
local ffi
if ( jit ) then
	ffi = require("ffi")
	ffi.cdef([[void Sleep(int ms);]])
end

local require = require
local string = string
local error = error

module( "facepunch" )

rootURL		= "http://www.facepunch.com"

baseURL		= rootURL .. "/"
indexPage	= "index.php" -- forum.php
ajaxPage	= "ajax.php"
showThread	= "threads/" -- showthread.php?t=
showPost	= "showpost.php"
userCP		= "usercp.php"
profileCP	= "profile.php"
newThread	= "newthread.php"
newReply	= "newreply.php"
loginPage	= "login.php"
logoutPage	= "login.php"

http = require( "facepunch.luacurl" )
--http = require( "facepunch.luasocket" )

session = nil

-------------------------------------------------------------------------------
-- facepunch.getSecurityToken()
-- Purpose: Get the current security token
-- Output: string token
-------------------------------------------------------------------------------
function getSecurityToken()
	local securityTokenPattern = [[<input type="hidden" name="securitytoken" value="(.-)" />]]
	local fpHome = http.get( rootURL )

	return string.match( fpHome, securityTokenPattern )
end

-------------------------------------------------------------------------------
-- facepunch.searchUser()
-- Purpose: Get all users with the given string in their name
-- Output: table user names
-------------------------------------------------------------------------------
function searchUser( name )
	local securityToken = getSecurityToken()
	
	local users = {}
	if (securityToken ~= "guest") then
		local postFields = "" ..
		-- Method
		"do=" .. "usersearch" ..
		-- PostID
		"&fragment=" .. name ..
		-- Securitytoken
		"&securitytoken=" .. securityToken
		
		local xml = http.post( baseURL .. ajaxPage, postFields )
		for id, user in string.gmatch( xml, [[<user userid="(.-)">(.-)</user>]] ) do
			users[ id ] = user
		end
	end
	
	return users
end

-------------------------------------------------------------------------------
-- facepunch.setSession()
-- Purpose: Set a session object that other functions can use
-- Input: sessionObj
-------------------------------------------------------------------------------
function setSession( obj )
	session = obj
end

-------------------------------------------------------------------------------
-- facepunch.sleep()
-- Purpose: Sleep for x seconds
-------------------------------------------------------------------------------
function sleep( seconds )
	if ( ffi ) then
		if ( ffi.os == "Windows" ) then
			ffi.C.Sleep( seconds * 1000 )
		end
	else
		error( "facepunch.sleep requires luajit!" )
	end
end

-------------------------------------------------------------------------------
-- facepunch.isUp()
-- Purpose: Returns true if not downpunch
-- Output: boolean
-------------------------------------------------------------------------------
function isUp()
	local data, status = http.get( rootURL )
	return status == 200
end

-------------------------------------------------------------------------------
-- facepunch.ratings
-- Purpose: Rating string -> rating number
-------------------------------------------------------------------------------
ratings = {
	["Agree"]				= 1,
	["Disagree"]			= 2,
	["Funny"]				= 3,
	["Informative"]			= 4,
	["Friendly"]			= 5,
	["Useful"]				= 6,
	["Optimistic"]			= 7,
	["Artistic"]			= 8,
	["Late"]				= 9,
	-- spell check
	-- bad reading
	["Dumb"]				= 12,
	["Zing"]				= 13,
	["Programming King"]	= 14,
	["Smarked"]				= 15,
	["Lua King"]			= 16,
	["Mapping King"]		= 17,
	["Winner"]				= 18,
	["Lua Helper"]			= 19,
	-- missing?
	["Moustache"]			= 21
}
