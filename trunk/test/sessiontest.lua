-- general thread testing
-- usage: lua test\sessionTest.lua

local facepunch	= require( "facepunch" )
local session	= facepunch.session

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luasocket" )

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()

local mySession = session( username, password )
mySession:login()

print( session.getSecurityToken() )
