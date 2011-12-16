-- thread.getPostsInPage
-- usage: lua test\getPostsInPage.lua

local facepunch	= require( "facepunch" )
local thread	= facepunch.thread

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

-- Andrew; retrieve a thread, page 1
local error, threadPage = -1, ""
while error ~= 0 do
	error, threadPage = thread.getPage( 1144771, 1 )
end

-- Andrew; prints all post objects parsed on page 1 of WAYWO December 2011
local posts = thread.getPostsInPage( threadPage )
for _, post in pairs( posts ) do
	print( post )
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
	print( "\n" )
end
