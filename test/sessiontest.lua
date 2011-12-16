-- general thread testing
-- usage: lua test\sessionTest.lua

local facepunch	= require( "facepunch" )
local session	= facepunch.session

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luacurl" )

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()

local mySession = session( username, password )
print( "Logging in as " .. username .. "..." )
local error = -1
while error ~= 0 do
	error = mySession:login()
end

session.setActiveSession( mySession )

print( "Cookies: " )
-- Grab the session cookie and append an additional separator for gmatch
-- convenience
local cookie = mySession.cookie
cookie = cookie .. "; "
for k, v in string.gmatch( cookie, "(.-)=(.-); " ) do
	print( "\t" .. k .. ": " .. v )
end

local error, token = -1, nil
while error ~= 0 do
	error, token = session.getSecurityToken()
end
print( "Security Token: " .. tostring( token ) )
