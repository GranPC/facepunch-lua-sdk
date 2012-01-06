-- dumps the dumbest posts by a given user, in ~highlightable style~
-- usage: lua test\dumbestposts.lua

local targetUsername    = "amcfaggot"
local highlightsSize    = 10
local highlightsRating  = "Dumb"
local threadID          = 1151723

local facepunch = require( "facepunch" )
local session   = facepunch.session
local thread    = facepunch.thread

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
  	if ( post.userinfo.username == targetUsername ) then
      post.postRatings = post.postRatings or {}
      if ( post.postRatings[ highlightsRating ] == nil ) then
        -- Andrew; we need this rating to be filled for table.sort
        post.postRatings[ highlightsRating ] = 0
      end
      table.insert( highlights, post )
  	end
  end
  table.sort( highlights,
    function( a, b )
      return a.postRatings[ highlightsRating ] > b.postRatings[ highlightsRating ]
    end
  )
  if ( #highlights > highlightsSize ) then
    local overflowSize = #highlights - highlightsSize
    for i = 1, overflowSize do
      table.remove( highlights, highlightsSize + 1 )
    end
  end
  threadPage = ""
end

local endTime = os.time()
print( "\nTook " .. tostring( endTime - startTime ) .. " seconds!\n" )

print( targetUsername .. "'s top " .. highlightsRating .. " posts: " )
for i, post in ipairs( highlights ) do
  if ( post.postRatings[ highlightsRating ] ~= 0 ) then
    print( i .. " (x" .. post.postRatings[ highlightsRating ] .. "): " .. post.link )
  end
end
