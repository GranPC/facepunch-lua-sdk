-------------------------------------------------------------------------------
-- Forums module
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local error = error
local facepunch = require( "facepunch" )
local http = require( "facepunch.http" )
local post = require( "facepunch.post" )
local pairs = pairs
local session = require( "facepunch.session" )
local string = string
local table = table
local tonumber = tonumber
local setmetatable = setmetatable

module( "facepunch.forums" )

indexPageForumPattern = "" ..
-- Forum ID
"<tr id=\"forum(%d-)\"" ..
-- Thread and Post Count
".-title=\"(.-) Threads, (.-) Posts\"" ..
-- Forum Name
".->(.-)</a></h2>" ..
-- Viewers
".-%((.-) Viewing" ..
-- Description
".-<p class=\"forumdescription\">(.-)</p>" ..
-- Last Poster ID, Name
".-<a href=\"/members/(%d-)\".-alt=\"(.-)\">" ..
-- Last Post Thread
".-Go to first unread post in thread '(.-)'"..
-- Last Post Date, URL
".-\"lastpostdate\">(.-)  <a href=\"(.-)\""

-------------------------------------------------------------------------------
-- forum
-- Purpose: Class index
-------------------------------------------------------------------------------
local forum = {}

-------------------------------------------------------------------------------
-- __metatable
-- Purpose: Class metatable
-------------------------------------------------------------------------------
__metatable = {
	__index = forum,
	__type = "forum"
}

-------------------------------------------------------------------------------
-- forum.new()
-- Purpose: Creates a new forum object
-- Output: forum
-------------------------------------------------------------------------------
function new()
	local t = {
		forumID = nil,
		threadCount = nil,
		postCount = nil,
		forumName = nil,
		viewers = nil,
		forumDescription = nil,
		lastPosterID = nil,
		lastPosterName = nil,
		lastThreadName = nil,
		lastPostDate = nil,
		lastPostURL = nil
	}
	setmetatable( t, __metatable )
	return t
end

-------------------------------------------------------------------------------
-- forum()
-- Purpose: Shortcut to forum.new()
-- Output: forum
-------------------------------------------------------------------------------
local metatable = {
	__call = function( _, ... )
		return new( ... )
	end
}
setmetatable( _M, metatable )

-------------------------------------------------------------------------------
-- forum:__tostring()
-- Purpose: Returns a string representation of a forum
-- Output: string
-------------------------------------------------------------------------------
function __metatable:__tostring()
	if not self.forumName then return "invalid forum" end
	return "forum: " .. self.forumName
end


-------------------------------------------------------------------------------
-- forums.getListing()
-- Purpose: Returns 0 if the page is retrieved successfully, then the forum
--			listing, otherwise it returns 1 and nil.
-- Output: error code, thread page
-------------------------------------------------------------------------------
function getListing()
	local r, c = http.get( facepunch.baseURL .. "/forum.php", session.getActiveSession() )
	if ( c == 200 ) then
		local ret = {}
		for forumID,
			threadCount,
			postCount,
			forumName,
			viewers,
			forumDescription,
			lastPosterID,
			lastPosterName,
			lastThreadName,
			lastPostDate,
			lastPostURL in string.gmatch( r, indexPageForumPattern ) do

			local retForum = new()
			retForum.forumID = tonumber( forumID )

			-- need to specify base, otherwise it takes the second return value for gsub
			retForum.threadCount = tonumber( string.gsub( threadCount, ",", "" ), 10 )
			retForum.postCount = tonumber( string.gsub( postCount, ",", "" ), 10 )

			retForum.forumName = forumName
			retForum.viewers = tonumber( string.gsub( viewers, ",", "" ), 10 )
			retForum.forumDescription = forumDescription
			retForum.lastPosterID = tonumber( lastPosterID )
			retForum.lastPosterName = lastPosterName
			retForum.lastThreadName = lastThreadName
			retForum.lastPostDate = lastPostDate
			retForum.lastPostURL = facepunch.baseURL .. lastPostURL

			table.insert( ret, retForum )

			end
		return 0, ret
	else
		return 1, nil
	end
end