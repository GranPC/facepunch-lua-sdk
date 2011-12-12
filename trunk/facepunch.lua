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
showThread	= "showthread.php"
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
