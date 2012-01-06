-- thread.getMembersInPage
-- usage: lua test\getMembersInPage.lua

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
	error, threadPage = thread.getPage( 1151723, 1 )
end

-- Andrew; prints all users who have posted on page 1 of WAYWO January 2012
local members = thread.getMembersInPage( threadPage )
for _, member in pairs( members ) do
	print( member )
	print( "\tuser id: " .. tostring( member.userID ) )
	print( "\tonline: " .. tostring( member.online ) )
	print( "\tusergroup: " .. tostring( member.usergroup ) )
	print( "\tusertitle: " .. tostring( member.usertitle ) )
	print( "\tavatar: " .. tostring( member.avatar ) )
	print( "\tjoin date: " .. tostring( member.joinDate ) )
	print( "\tpost count: " .. tostring( member.postCount ) )
	print( "\tsocial links: " .. ( member.links == nil and tostring( member.links ) or "" ) )
	if ( member.links ) then
		for name, link in pairs( member.links ) do
			print( "\t\t"..name..": "..link )
		end
	end
	print( "\n" )
end
