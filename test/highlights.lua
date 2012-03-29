-- dumps a given amount of the most notable posts by rating in a thread
-- usage: lua test\highlights.lua

-- Andrew; In this test, we want the top 10 highlights from WAYWO March 2012
-- per rating. Let's dump the top 25 instead, because we may have some
-- non-content posts
local highlightsSize  = 25
local ratingsRelevant = {
  "Programming King",
  "Artistic",
  "Winner"
}
local threadID        = 1167397

local facepunch = require( "facepunch" )
local thread    = facepunch.thread
local session   = facepunch.session

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

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

local file = assert( io.open( "highlights.txt", "w" ) )
for rating, t in pairs( highlights ) do
  if ( hasValue( ratingsRelevant, rating ) ) then
    for i, post in pairs( t ) do
      if ( i == 1 ) then
        file:write( rating .. ": " .. "\n" )
      end
      file:write( post.userinfo.username .. " posted:" .. "\n" )
      file:write( i .. " (x" .. post.postRatings[ rating ] .. "): " .. post.link .. "\n" )
    end
    file:write( "\n" )
  end
end
file:close()
