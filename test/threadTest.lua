-- general thread testing
-- usage: lua test\threadTest.lua

local threadID = 1144771
local threadName = ""
local threadPages = -1

local startTime = os.time()

local thread = require( "facepunch.thread" )
threadName = thread.getName( threadID )
threadPages = thread.getNumberOfPages( threadID )

local endTime = os.time()
print( "Took " .. tostring( endTime - startTime ) .. " seconds!" )

print( "The thread '" .. threadName .. "' contains " .. threadPages .. " pages!" )