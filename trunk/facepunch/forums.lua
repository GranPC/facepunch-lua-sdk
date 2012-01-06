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
local thread = require( "facepunch.thread" )
local string = string
local table = table
local tonumber = tonumber
local setmetatable = setmetatable

module( "facepunch.forums" )

-------------------------------------------------------------------------------
-- indexPageForumCategoryPattern
-- Purpose: Pattern for creating and filling the forum objects from the
--			homepage.
-------------------------------------------------------------------------------
indexPageForumCategoryPattern = "" ..
-- Category ID
"forums\" id=\"cat(%d-)\"" ..
-- Name
".-<h2><a href=\"forums/.-\">(.-)</a></h2>" ..
-- Forums
".-</thead>(.-)</table>"

-------------------------------------------------------------------------------
-- indexPageForumPattern
-- Purpose: Pattern for creating and filling the forum objects from the
--			"forums" result of indexPageForumCategoryPattern.
-------------------------------------------------------------------------------
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
-- forumPageThreadPattern
-- Purpose: Pattern for filling thread objects from a forum page.
-------------------------------------------------------------------------------
forumPageThreadPattern = "" ..
-- Properties, thread ID
"<tr class=\"threadbit (.-)\" id=\"thread_(%d-)\"" ..
-- Thread icon, name
".-<img src=\"(.-)\" alt=\"(.-)\" border=\"0\" />" ..
-- Thread title
".-thread_title_%d-\">(.-)</a>" ..
-- Has images / new posts?
"(.-)</h3>" ..
-- Author UID, username, readers?
".-<div class=\"author\">.-<a href=\"members/(.-)%-.-\">(.-)</a>(.-)\n" ..
-- Last Post Date
".-<dd>(.-)</dd>" ..
-- Last Poster UID, username, reply link
".-by <a href=\"members/(.-)%-.-\">(.-)</a> <a href=\"(.-)\"" ..
-- Reply count
".-\">(.-)</a>" ..
-- View count
".-<span>(.-)</span>"

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
		for catID,
			catName,
			forums in string.gmatch( r, indexPageForumCategoryPattern ) do
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
				lastPostURL in string.gmatch( forums, indexPageForumPattern ) do

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

				retForum.category = catName

				table.insert( ret, retForum )

				end
			end
		return 0, ret
	else
		return 1, nil
	end
end

-------------------------------------------------------------------------------
-- forums.getPage()
-- Purpose: Returns 0 if the page is retrieved successfully, then the forum
--			page by ID and page number, if provided, otherwise it returns 1 and
--			nil
-- Input: forumID - ID of the forum to get
--		  pageNumber - number of the page to get
-- Output: error code, forum page
-------------------------------------------------------------------------------
function getPage( forumID, pageNumber )
	pageNumber = pageNumber or ""
	if ( pageNumber ~= "" ) then
		pageNumber = "/" .. pageNumber
	end
	local r, c = http.get( facepunch.baseURL .. "/forums/" .. forumID .. pageNumber, session.getActiveSession() )
	if ( c == 200 ) then
		return 0, r
	else
		return 1, nil
	end
end

-------------------------------------------------------------------------------
-- forums.getThreadsInPage()
-- Purpose: Returns a list of threads in a forum
-- Input: forumPage - string of the requested page
-- Output: table
-------------------------------------------------------------------------------
function getThreadsInPage( forumPage )
	local t = {}
	for properties,
		threadID,
		threadIconURL,
		threadIcon,
		threadTitle,
		hasImages,
		authorID,
		authorName,
		threadReaders,
		lastPostDate,
		lastPosterID,
		lastPosterName,
		lastPostURL,
		replies,
		views
		in string.gmatch( forumPage, forumPageThreadPattern ) do
		local thread = thread.new()
		thread.threadID = tonumber( threadID )
		thread.threadIconURL = threadIconURL
		thread.threadIcon = threadIcon
		thread.threadTitle = threadTitle
		thread.hasImages = string.find( hasImages, "images" ) and true or false
		thread.authorID = tonumber( authorID )
		thread.authorName = authorName
		thread.threadReaders = string.match( threadReaders, "(%d-) read" )
		thread.lastPostDate = lastPostDate
		thread.lastPosterID = tonumber( lastPosterID )
		thread.lastPosterName = lastPosterName
		thread.lastPostURL = lastPostURL
		thread.replyCount = tonumber( string.gsub( replies, ",", "" ), 10 )
		thread.viewCount = tonumber( string.gsub( views, ",", "" ), 10 )
	
		thread.newPosts = tonumber( string.match( hasImages, "(%d-) new posts" ) )
		table.insert(t, thread)
	end
	return t
end