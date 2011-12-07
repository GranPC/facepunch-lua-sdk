-- thread.getPostsInPage
-- usage: lua test\getPostsInPage.lua

local thread = require( "facepunch.thread" )

-- Andrew; prints all users who have posted on page whatever of WAYWO December 2011
local error, posts = thread.getPostsInPage( "http://www.facepunch.com/threads/1144771/18" )
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
