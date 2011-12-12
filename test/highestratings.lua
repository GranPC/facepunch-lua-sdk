-- highest ratings
-- grabs the posts with the highest ratings in a given thread
-- usage: lua test\highestRatings.lua

local threadURL = "http://www.facepunch.com/threads/1144771"
-- lazy page indexing
-- TODO: implement thread.getNumberOfPages() - oh and thread.getName() while
-- we're at it
local numberOfPages = 19

local thread = require( "facepunch.thread" )
local highlights = {}

local startTime = os.time()

for i = 1, numberOfPages do
  local thisPage = threadURL .. "/" .. i
  print( "Grabbing " .. thisPage )
  local error, posts = 1, {}
  while error ~= 0 do
  	error, posts = thread.getPostsInPage( thisPage )
  end
  for _, post in pairs( posts ) do
  	if ( post.postRatings ) then
  	  for rating, count in pairs( post.postRatings ) do
  	  	if ( highlights[ rating ] == nil ) then
  	  	  highlights[ rating ] = {
  	  	    link = post.link,
  	  	    count = count
  	  	  }
  	  	elseif ( count > highlights[ rating ].count ) then
  	  	  highlights[ rating ] = {
  	  	    link = post.link,
  	  	    count = count
  	  	  }
  	  	end
  	  end
  	end
  end
end

local endTime = os.time()
print( "Took " .. tostring( endTime - startTime ) .. " seconds!" )

for rating, t in pairs( highlights ) do
	print( "Most " .. rating .. "s goes to:\n" .. t.link .. "\nwith\n" .. t.count .. " " .. rating .. "s!" )
	print( "\n" )
end
