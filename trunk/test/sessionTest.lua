-- general thread testing
-- usage: lua test\sessionTest.lua

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()

local session = require( "facepunch.session" )
local mySession = session( username, password )
mySession:login()

require( "facepunch" )
print( facepunch.getSecurityToken() )