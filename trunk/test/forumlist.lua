-- tests retrieving the forum list
-- usage: lua test\forumlist.lua

local facepunch	= require( "facepunch" )
local session	= facepunch.session
local forums	= facepunch.forums

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luacurl" )

io.write( "Login? y/N\n> ") -- there may be some other forums guests can't see
local ans = io.read()
if ( string.lower( ans ) == "y" ) then
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
end

local success, list = forums.getListing()
if ( success ~= 0 ) then
	print("Could not retrieve forum list!")
	return
end

for k, v in pairs( list ) do
	print( "forum:               "..v.forumName )
	print( "  thread count:      "..v.threadCount )
	print( "  post count:        "..v.postCount )
	print( "  viewers:           "..v.viewers )
	print( "  forum description: "..v.forumDescription )
	print( "  last poster ID:    "..v.lastPosterID )
	print( "  last poster name:  "..v.lastPosterName )
	print( "  last thread name:  "..v.lastThreadName )
	print( "  last post date:    "..v.lastPostDate )
	print( "  last post URL:     "..v.lastPostURL )
	print( "  category:          "..v.category )
end