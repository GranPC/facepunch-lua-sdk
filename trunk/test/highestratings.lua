-- highest ratings
-- grabs the posts with the highest ratings in a given thread
-- usage: lua test\highestratings.lua

local threadID  = 1144771

local facepunch = require( "facepunch" )
local thread    = facepunch.thread

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luacurl" )

-- Andrew; retrieve the thread
print( "Grabbing page 1 of thread " .. threadID )
local error, threadPage = -1, ""
while error ~= 0 do
  -- Andrew; not returning a page number for the second argument inherently
  -- retrieves the first page
  error, threadPage = thread.getPage( threadID )
end
local highlights = {}

local startTime = os.time()

local _, pageCount = thread.getPaginationInfo( threadPage )

for i = 1, pageCount do
  -- Andrew; This condition allows us to reuse the first page we just got
  -- above when we had to find out how many pages the thread had, so we could
  -- establish how many times to execute this loop. By checking if threadPage
  -- is an empty string here, and setting it to an empty string at the end of
  -- each loop, we can bypass having to get the first page in the loop, but
  -- retrieve the rest.
  --
  -- In the FPAPI, we call this "immediate caching", since the page requests
  -- aren't intended to last more than how long you need the document for parse
  -- calls.
  if ( threadPage == "" ) then
    print( "Grabbing page " .. i .. " of thread " .. threadID )
    error = -1
    while error ~= 0 do
    	error, threadPage = thread.getPage( threadID, i )
    end
  end
  local posts = thread.getPostsInPage( threadPage )
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
  threadPage = ""
end

local endTime = os.time()
print( "\nTook " .. tostring( endTime - startTime ) .. " seconds!\n" )

for rating, t in pairs( highlights ) do
	print( "Most " .. rating .. "s goes to:\n" .. t.link .. "\nwith\n" .. t.count .. " " .. rating .. "s!" )
	print( "\n" )
end
