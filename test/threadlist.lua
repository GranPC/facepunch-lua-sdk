local facepunch	= require( "facepunch" )
local forums	= facepunch.forums

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luacurl" )

local err, forumPage = forums.getPage( 6 )

if err == 1 then
	error("could not retrieve forum!")
end

-- Andrew; prints all post objects parsed on page 1 of WAYWO December 2011
local threads = forums.getThreadsInPage( forumPage )
--for k,v in pairs(threads[2]) do print(k,v) end
for _, thread in pairs( threads ) do
	print( "thread:            " .. tostring( thread.threadTitle ) )
	print( "   icon:           " .. tostring( thread.threadIcon ) )
	print( "   author:         " .. tostring( thread.authorName ) )
	if thread.hasImages then
		print("    This thread has images.")
	end
	if thread.threadReaers then
		print( "   readers:        " .. tostring( thread.threadReaders ) )
	end
	print( "   last poster:    " .. tostring( thread.lastPosterName ) )
	print( "   last post date: " .. tostring( thread.lastPostDate ) )
	print( "   reply count:    " .. tostring( thread.replyCount ) )
	print( "   view count:     " .. tostring( thread.viewCount ) )
end