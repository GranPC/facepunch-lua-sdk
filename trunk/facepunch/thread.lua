local error = error
local facepunch = require( "facepunch" )
local member = require( "facepunch.member" )
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
-- thread.getMembersInPage()
-- Purpose: Returns all members that have posted on a given thread page
-- Output: table of members
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
		return t
	else
		error( "could not retrieve thread page!", 2 )
	end
end
