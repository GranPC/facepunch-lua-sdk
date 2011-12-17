-- thread.getMembersReading
-- usage: lua test\getMembersReading.lua

local facepunch	= require( "facepunch" )
local session	= facepunch.session
local thread	= facepunch.thread

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
print( "Logged in!" )

session.setActiveSession( mySession )

-- Andrew; retrieve a thread, page 1
local error, threadPage = -1, ""
while error ~= 0 do
	error, threadPage = thread.getPage( 1144771, 1 )
end

-- Andrew; prints all users who're reading WAYWO December 2011
local members = thread.getMembersReading( threadPage )
for k, v in pairs( members ) do
	if ( k ~= "guests" ) then
		print( v )
		print( "\tuser id: " .. tostring( v.userID ) )
		print( "\tonline: " .. tostring( v.online ) )
		print( "\tusergroup: " .. tostring( v.usergroup ) )
		print( "\n" )
	else
		print( "guests: " .. v )
	end
end
