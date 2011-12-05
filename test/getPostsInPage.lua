-- thread.getPostsInPage
-- usage: lua test\getPostsInPage.lua

local thread = require( "facepunch.thread" )

-- Andrew; prints all users who have posted on page 6 of WAYWO December 2011
for _, post in pairs( thread.getPostsInPage( "http://www.facepunch.com/threads/1144771/6" ) ) do
	print( post )
	print( "      post date: " .. tostring( post.postDate ) )
	print( "      link: " .. tostring( post.link ) )
	print( "      post number: " .. tostring( post.postNumber ) )
	print( "\n" )
end
