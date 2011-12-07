local error = error
local facepunch = require( "facepunch" )
local member = require( "facepunch.member" )
local post = require( "facepunch.post" )
local pairs = pairs
local string = string
local table = table
local tonumber = tonumber

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
"<li class=.- id=\"post.-(" ..
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
[[<a href="#".-RatePost%( '.-', '.-', '(.-)' %);"><img src=".-" alt="(.-)" /></a>]]


-------------------------------------------------------------------------------
-- thread.getMembersInPage()
-- Purpose: Returns all members that have posted on a given thread page, first
--			returns 0 if there are no errors or 1 in case of errors
-- Input: threadPageURL - URL to a single page in the thread
-- Output: integer, table of members
-------------------------------------------------------------------------------
function getMembersInPage( threadPageURL )
	local threadPage, returnCode = facepunch.request( threadPageURL )
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
					for url in string.gmatch( avatar, ".-img src=\"(/avatar/.-)\"" ) do
						avatar			= url
					end
					member.avatar		= facepunch.rootURL .. avatar
				end
				member.joinDate			= string.gsub( joinDate, "^%s*(.-)%s*$", "%1" )
				member.postCount		= postCount
				member.postCount		= string.gsub( member.postCount, "^%s*(.-)%s*$", "%1" )
				member.postCount		= tonumber( string.gsub( member.postCount, ",", "" ), 10 )

				for url, name in string.gmatch( links, memberSocialLinkPattern ) do
					member.links[ name ] = url
				end
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
-- thread.getPostsInPage()
-- Purpose: Returns all posts on a given thread page, first returns 0 if there
--			are no errors or 1 in case of errors
-- Input: threadPageURL - URL to a single page in the thread
-- Output: table of posts
-------------------------------------------------------------------------------
function getPostsInPage( threadPageURL )
	local threadPage, returnCode = facepunch.request( threadPageURL )
	if ( returnCode == 200 ) then
		local t = {}
		for fullPost,
			postDate,
			link,
			postNumber
			in string.gmatch( threadPage, threadPagePostPattern ) do
			local post		= post()
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
