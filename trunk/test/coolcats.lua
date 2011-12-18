-- checks to see if you need to login to see a given thread
-- usage: lua test\coolcats.lua

-- LMAO Pics v. 99 forever and always
local threadID = 1125443

local facepunch	= require( "facepunch" )
local thread	= facepunch.thread

-- Setup our connector
-- Use luacurl for this test
require( "connectors.luasocket" )

local error, threadPage = -1, ""
while error ~= 0 do
	error, threadPage = thread.getPage( threadID )
end
print( thread.canGuestViewPage( threadPage ) and ":frogin:" or ":frogout:" )
