-- thread.getMembersInPage
-- usage: lua test\getMembersInPage.lua

local facepunch	= require( "facepunch" )
local thread	= facepunch.thread

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

-- Andrew; retrieve a thread, page 1
local error, threadPage = -1, ""
while error ~= 0 do
	error, threadPage = thread.getPage( 1144771, 1 )
end

-- Andrew; prints all users who have posted on page 1 of WAYWO December 2011
local members = thread.getMembersInPage( threadPage )
for _, member in pairs( members ) do
	print( member )
	print( "\tonline: " .. tostring( member.online ) )
	print( "\tusergroup: " .. tostring( member.usergroup ) )
	print( "\tusertitle: " .. tostring( member.usertitle ) )
	print( "\tavatar: " .. tostring( member.avatar ) )
	print( "\tjoin date: " .. tostring( member.joinDate ) )
	print( "\tpost count: " .. tostring( member.postCount ) )
	print( "\tsocial links: " .. ( member.links == nil and tostring( member.links ) or "" ) )
	if ( member.links ) then
		for name, link in pairs( member.links ) do
			print( "\t\t"..name..": "..link )
		end
	end
	print( "\n" )
end
