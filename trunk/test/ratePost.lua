-- thread.getPostsInPage
-- usage: lua test\ratePost.lua

require( "facepunch" )
local thread = require( "facepunch.thread" )
local session = require( "facepunch.session" )

local mySession = session( "LuaStoned" )
facepunch.setSession( mySession )

local err, post = thread.getPostByID( 1144771, 1325 )

print( post )
print( "      post id: " .. tostring( post.postID ) )
print( "      post date: " .. tostring( post.postDate ) )
print( "      link: " .. tostring( post.link ) )
print( "      post number: " .. tostring( post.postNumber ) )
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

post:rate( "Zing" )