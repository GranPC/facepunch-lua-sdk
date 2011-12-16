-- member.searchUser
-- usage: lua test\searchUser.lua

local facepunch	= require( "facepunch" )
local member	= facepunch.member
local session	= facepunch.session

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()

local thisSession = session( username, password )
print( "Logging in as " .. username .. "..." )
local error = -1
while error ~= 0 do
	error = thisSession:login()
end
session.setActiveSession( thisSession )

local error, securityToken = -1, nil
while error ~= 0 do
	error, securityToken = session.getSecurityToken()
end
print( "Security Token: " .. securityToken )

io.write( "Search for user: " )
local substring = io.read()
local error, users = -1, nil
while error ~= 0 do
	error, users = member.searchUser( substring, securityToken )
end

local i = 0
for _, user in pairs( users ) do
	print( user )
	i = i + 1
end
print( "Found " .. i .. " users!" )
