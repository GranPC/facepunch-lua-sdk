-- tests replying to a thread
-- usage: lua test\posttest.lua

local threadID	= 1144771
local message	= "Hi! I'm posting from the FPAPI! Rate me dumb for using a test script in the SDK. xDDD"

local facepunch	= require( "facepunch" )
local session	= facepunch.session
local thread	= facepunch.thread

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

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

local error, token = -1, nil
while error ~= 0 do
	error, token = session.getSecurityToken()
end

local error = -1
while error ~= 0 do
	error = thread.reply( threadID, message, token )
end
print( "Posted to thread!" )
