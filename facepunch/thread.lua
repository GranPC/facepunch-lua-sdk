local error = error
local facepunch = require( "facepunch" )
local member = require( "facepunch.member" )
local post = require( "facepunch.post" )
local pairs = pairs
local string = string
local table = table
local math = math
local tonumber = tonumber
local print = print
module( "facepunch.thread" )

-------------------------------------------------------------------------------
-- threadPageMemberPattern
-- Purpose: Pattern for filling member objects on a thread page. Below is what
--			each part of the pattern represents
-------------------------------------------------------------------------------
threadPageMemberPattern = "" ..
-- Username
"username_container.-href=\"members/.- title=\"(.-) is " ..
-- Online Status
"(.-)line" ..
-- Displayed Username
".-\">(.-)</a>" ..
-- Usertitle
".-\"usertitle\">(.-)</span>" ..
-- Avatar
".-\"userdata\">.-<a .->(.-)</a>" ..
-- Join Date
".-\"userstats\">(.-)<br />" ..
-- Post Count
".-(.-) Posts.-</div>" ..
-- Social Links
".-\"imlinks\">(.-)</div>"

-------------------------------------------------------------------------------
-- memberSocialLinkPattern
-- Purpose: Pattern for filling the links table on a member from a thread page
-------------------------------------------------------------------------------
memberSocialLinkPattern = "" ..
"href=\"(.-)\"><img src=\"/fp/social/(.-)%."

-------------------------------------------------------------------------------
-- threadPagePostPattern
-- Purpose: Pattern for filling post objects on a thread page
-- It also gets the entire post body, which is necessary for the
-- postRatingResultSpanPattern, since posts without any ratings won't have a
-- rating_results span, and then this pattern wouldn't return those posts
-------------------------------------------------------------------------------
threadPagePostPattern = "" ..
-- Post Beginning
"<li class=.- id=\"post_" ..
-- Post ID
"(.-)\">.-(" ..
-- Post Date
".-\"date\">(.-)</span>" ..
-- Link to Post
".-post%d-\" href=\"(.-)\"" ..
-- Post Number
".-postcount%d-\" name=\"(.-)\"" ..
-- End
".-</li>)"


-------------------------------------------------------------------------------
-- postRatingResultSpanPattern
-- Purpose: Pattern for getting the rating_results div, which may not be there
-- if the post has no ratings.
-------------------------------------------------------------------------------
postRatingResultSpanPattern = "" ..
"class=\"rating_results\" id=\"rating_.-\">.-<span>(.-)%(list%)</a>.-</span>"

-------------------------------------------------------------------------------
-- postRatingResultPattern
-- Purpose: Pattern for filling the ratings table on a post
-------------------------------------------------------------------------------
postRatingResultPattern = "" ..
"<img src=\".-\" alt=\"(.-)\" />.-<strong>(%d-)</strong>"


-------------------------------------------------------------------------------
-- postRatingKeyDivPattern
-- Purpose: Pattern for getting the postrating div, which is not there if you
-- are not logged in.
-------------------------------------------------------------------------------
postRatingKeyDivPattern = "" ..
"class=\"postrating\" id=\"ratingcontrols_post_.-\">(.-)</div>"

-------------------------------------------------------------------------------
-- postRatingKeyPattern
-- Purpose: Pattern for filling the rating key table on a post
-------------------------------------------------------------------------------
postRatingKeyPattern = "" ..
"<a href=\"#\".-RatePost%( '.-', '.-', '(.-)' %);\"><img src=\".-\" alt=\"(.-)\" /></a>"

-------------------------------------------------------------------------------
-- threadNumberOfPagesPattern
-- Purpose: Pattern for getting a threads maximum page number
-------------------------------------------------------------------------------
threadNumberOfPagesPattern = "" ..
[[class="first_last"><a href="threads/.-/(.-)"]]

-------------------------------------------------------------------------------
-- threadNamePattern
-- Purpose: Pattern for getting the threads name
-------------------------------------------------------------------------------
threadNamePattern = "" ..
[[<title> (.-)</title>]]

-------------------------------------------------------------------------------
-- thread.getName()
-- Purpose: Returns the name of the thread
-- Input: threadID
-- Output: string, name of thread
-------------------------------------------------------------------------------
function getName( threadID )
	local threadPage, returnCode = facepunch.request( facepunch.baseURL .. facepunch.showThread .. threadID )
	if ( returnCode == 200 ) then
		local threadName = threadPage:match( threadNamePattern )
		return threadName
	else
		return nil
	end
end

-------------------------------------------------------------------------------
-- thread.getNumberOfPages()
-- Purpose: Returns the total ammount of pages in a thread
-- Input: threadID
-- Output: integer, table of members
-------------------------------------------------------------------------------
function getNumberOfPages( threadID )
	local threadPage, returnCode = facepunch.request( facepunch.baseURL .. facepunch.showThread .. threadID )
	if ( returnCode == 200 ) then
		local numberOfPages = threadPage:match( threadNumberOfPagesPattern )
		if ( numberOfPages == nil ) then
			return 1
		end
		numberOfPages = string.gsub( numberOfPages, "%?s=%w+", "" )
		return numberOfPages
	else
		return nil
	end
end

-------------------------------------------------------------------------------
-- thread.getMembersInPage()
-- Purpose: Returns all members that have posted on a given thread page, first
--			returns 0 if there are no errors or 1 in case of errors
-- Input: threadPageURL - URL to a single page in the thread
-- Output: integer, table of members
-------------------------------------------------------------------------------
function getMembersInPage( threadID )
	local threadPage, returnCode = facepunch.http.get( facepunch.baseURL .. facepunch.showThread .. threadID )
	if ( returnCode == 200 ) then
		local t = {}
		local matched = false
		for username,
			status,
			displayedUsername,
			usertitle,
			avatar,
			joinDate,
			postCount,
			links in string.gmatch( threadPage, threadPageMemberPattern ) do
			for _, v in pairs( t ) do
				if ( v.username == username ) then
					matched = true
				end
			end
			if ( not matched ) then
				local member			= member()
				member.username			= username
				member.online			= status == "on"
				if ( username == displayedUsername ) then
					member.usergroup	= "Registered User"
				elseif ( string.find( displayedUsername, "<font color=\"red\">" ) ) then
					member.usergroup	= "Banned"
				elseif ( string.find( displayedUsername, "#A06000" ) ) then
					member.usergroup	= "Gold Member"
				elseif ( string.find( displayedUsername, "#00aa00" ) ) then
					member.usergroup	= "Moderator"
				elseif ( string.find( displayedUsername, "<span class=\"boing\">") ) then
					member.usergroup	= "Administrator"
				end
				member.usertitle		= string.gsub( usertitle, "^%s*(.-)%s*$", "%1" )
				if ( string.find( member.usertitle, "<span" ) ) then
					member.usertitle	= member.usertitle .. "</span>"
				end
				if ( member.usertitle == "" ) then
					member.usertitle	= nil
				end
				avatar					= string.gsub( avatar, "^%s*(.-)%s*$", "%1" )
				if ( avatar == "" ) then
					member.avatar		= nil
				else
					for url in string.gmatch( avatar, ".-img src=\"(.-)\"" ) do
						avatar			= url
					end
					member.avatar		= facepunch.rootURL .. avatar
				end
				member.joinDate			= string.gsub( joinDate, "^%s*(.-)%s*$", "%1" )
				member.postCount		= postCount
				member.postCount		= string.gsub( member.postCount, "^%s*(.-)%s*$", "%1" )
				member.postCount		= tonumber( string.gsub( member.postCount, ",", "" ), 10 )

				member.links = {}
				local hasLinks = false
				for url, name in string.gmatch( links, memberSocialLinkPattern ) do
					if ( hasLinks == false ) then hasLinks = true end
					member.links[ name ] = url
				end
				if ( not hasLinks ) then member.links = nil end
				table.insert( t, member )
			else
				matched = false
			end
		end
		return 0, t
	else
		return 1, nil
	end
end

-------------------------------------------------------------------------------
-- thread.getMembersReading()
-- Purpose: Returns all members reading a given thread
-- Input: threadPageURL - URL to a single page in the thread
-- Output: table of members
-------------------------------------------------------------------------------
function getMembersReading( threadID )
	error( "not yet implemented!", 2 )
end

-------------------------------------------------------------------------------
-- thread.getPostByID()
-- Purpose: Returns 0 if the post is found, then the post object, otherwise it
--			returns 1 and nil
-- Input: threadPageURL - URL to a single page in the thread
--		  postID - number of post
-- Output: integer, post
-------------------------------------------------------------------------------
function getPostByID( threadID, postID )
	-- facepunch has 40 posts per page
	local pageID = math.ceil( postID / 40 )
	local returnCode, postTable = getPostsInPage( threadID, pageID )
	for _, post in pairs( postTable ) do
		if ( tonumber( post.postNumber ) == tonumber( postID ) ) then
			return 0, post
		end
	end
	return 1, nil
end

-------------------------------------------------------------------------------
-- thread.getPostsInPage()
-- Purpose: Returns all posts on a given thread page, first returns 0 if there
--			are no errors or 1 in case of errors
-- Input: threadPageURL - URL to a single page in the thread
-- Output: table of posts
-------------------------------------------------------------------------------
function getPostsInPage( threadID, pageNumber )
	local threadPage, returnCode = facepunch.http.get( facepunch.baseURL .. facepunch.showThread .. threadID .. "/" .. pageNumber )
	if ( returnCode == 200 ) then
		local t = {}
		for postID,
			fullPost,
			postDate,
			link,
			postNumber
			in string.gmatch( threadPage, threadPagePostPattern ) do
			local post		= post()
			post.postID		= postID
			post.postDate	= postDate
			post.link		= facepunch.baseURL .. string.gsub( link, "&amp;", "&" )
			post.postNumber	= postNumber

			local postRatings = string.match( fullPost, postRatingResultSpanPattern )
			if ( postRatings ) then
				post.postRatings = {}
				for name, amount in string.gmatch( postRatings, postRatingResultPattern ) do
					post.postRatings[ name ] = tonumber( amount )
				end
			end
			
			local postRatingKeys = string.match( fullPost, postRatingKeyDivPattern )
			if ( postRatingKeys ) then
				post.postRatingKeys = {}
				for key, rating in string.gmatch( postRatingKeys, postRatingKeyPattern ) do
					post.postRatingKeys[ rating ] = key
				end
			end

			table.insert( t, post )
		end
		return 0, t
	else
		return 1, nil
	end
end
