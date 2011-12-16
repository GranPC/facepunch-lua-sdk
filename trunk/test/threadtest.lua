-- general thread testing
-- usage: lua test\threadTest.lua

local threadID = 1144771
local threadName = ""
local threadPages = -1

local startTime = os.time()

do
	local facepunch	= require( "facepunch" )
	local thread	= facepunch.thread

	-- Setup our connector
	-- Use luacurl for this test
	require( "connectors.luacurl" )

	local error, threadPage = -1, ""
	while error ~= 0 do
		error, threadPage = thread.getPage( threadID )
	end

	threadName = thread.getName( threadPage )
	threadPages = thread.getNumberOfPages( threadPage )
end

local endTime = os.time()
print( "Took " .. tostring( endTime - startTime ) .. " seconds!" )

print( "The thread '" .. threadName .. "' contains " .. threadPages .. " pages!" )
