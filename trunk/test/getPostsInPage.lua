-- thread.getPostsInPage
-- usage: lua test\getPostsInPage.lua

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

-- Andrew; prints all post objects parsed on page 1 of WAYWO January 2012
local posts = thread.getPostsInPage( threadPage )
for _, post in pairs( posts ) do
	print( post )
	print( "      post id: " .. tostring( post.postID ) )
	print( "      post date: " .. tostring( post.postDate ) )
	print( "      link: " .. tostring( post.link ) )
	print( "      post number: " .. tostring( post.postNumber ) )
	print( "      user info: " .. tostring( post.userinfo ) )
	print( "      post ratings: " .. ( post.postRatings == nil and tostring( post.postRatings ) or "" ) )
	if ( post.postRatings ) then
		for name, amount in pairs( post.postRatings ) do
			print( "            " .. name .. " x " .. amount )
		end
	end
	print( "      post rating keys: " .. ( post.postRatingKeys == nil and tostring( post.postRatingKeys ) or "" ) )
	if ( post.postRatingKeys ) then
		for rating, key in pairs( post.postRatingKeys ) do
			print( "            " .. rating .. ": " .. key )
		end
	end
	print( "\n" )
end
