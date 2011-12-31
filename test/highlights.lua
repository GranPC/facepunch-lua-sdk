-- dumps a given amount of the most notable posts by rating in a thread
-- usage: lua test\highlights.lua

-- Andrew; In this test, we want the top 10 highlights from WAYWO December 2011
-- per rating. Let's dump the top 25 instead, because we may have some
-- non-content posts
local highlightsSize  = 25
local ratingsRelevant = {
  "Programming King",
  "Artistic",
  "Winner"
}
local threadID        = 1144771

local facepunch = require( "facepunch" )
local thread    = facepunch.thread

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luacurl" )

-- Andrew; retrieve the thread
print( "Grabbing page 1 of thread " .. threadID )
local error, threadPage = -1, ""
while error ~= 0 do
  error, threadPage = thread.getPage( threadID )
end
local highlights = {}

local startTime = os.time()

local _, pageCount = thread.getPaginationInfo( threadPage )

for i = 1, pageCount do
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
        highlights[ rating ] = highlights[ rating ] or {}
        table.insert( highlights[ rating ], post )
  	  end
  	end
  end
  for rating, t in pairs( highlights ) do
    table.sort( t,
      function( a, b )
        return a.postRatings[ rating ] > b.postRatings[ rating ]
      end
    )
    if ( #t > highlightsSize ) then
      local overflowSize = #t - highlightsSize
      for i = 1, overflowSize do
        table.remove( t, highlightsSize + 1 )
      end
    end
  end
  threadPage = ""
end

local endTime = os.time()
print( "\nTook " .. tostring( endTime - startTime ) .. " seconds!\n" )

local function hasValue( t, val )
  for _, v in pairs( t ) do
    if ( v == val ) then
      return true
    end
  end
  return false
end

for rating, t in pairs( highlights ) do
  if ( hasValue( ratingsRelevant, rating ) ) then
    for i, post in pairs( t ) do
      if ( i == 1 ) then
        print( rating .. ": " )
      end
      print( i .. " (x" .. post.postRatings[ rating ] .. "): " .. post.link )
    end
    print()
  end
end
