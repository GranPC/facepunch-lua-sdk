-- thread.getMembersInPage
-- usage: lua test\getMembersInPage.lua

local thread = require( "facepunch.thread" )

-- Andrew; prints all users who have posted on page 1 of WAYWO December 2011
local error, members = thread.getMembersInPage( "http://www.facepunch.com/threads/1144771/1" )
for _, member in pairs( members ) do
	print( member )
	print( "\tonline: " .. tostring( member.online ) )
	print( "\tusergroup: " .. tostring( member.usergroup ) )
	print( "\tusertitle: " .. tostring( member.usertitle ) )
	print( "\tavatar: " .. tostring( member.avatar ) )
	print( "\tjoin date: " .. tostring( member.joinDate ) )
	print( "\tpost count: " .. tostring( member.postCount ) )
	print( "\tsocial links: " )
	for name, link in pairs( member.links ) do
		print( "\t\t"..name..": "..link )
	end
	print( "\n" )
end
