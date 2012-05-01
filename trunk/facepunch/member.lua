-------------------------------------------------------------------------------
-- Member module and class definition
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local facepunch = require( "facepunch" )
local http = require( "facepunch.http" )
local session = require( "facepunch.session" )
local setmetatable = setmetatable
local string = string
local tonumber = tonumber
local os = os

module( "facepunch.member" )

-------------------------------------------------------------------------------
-- member.searchUser()
-- Purpose: Searches for users with the given string in their name, returns 0
--			then a table of the usernames if successful, otherwise 1 and nil
-- Input: name - partial or full string of user, must be at least 3 characters
--				 long to receive results
--		  session - option session object
--		  securityToken - security token for making the request
-- Output: error code, table of usernames
-------------------------------------------------------------------------------
function searchUser( name, securityToken )
	local postFields = "" ..
	-- Method
	"do=" .. "usersearch" ..
	-- PostID
	"&fragment=" .. name ..
	-- Securitytoken
	"&securitytoken=" .. ( securityToken or "guest" )

	local r, c = http.post( facepunch.rootURL .. "/" .. facepunch.ajaxPage, session.getActiveSession(), postFields )
	if ( c == 200 ) then
		local users = {}
		for id, user in string.gmatch( r, "<user userid=\"(.-)\">(.-)</user>" ) do
			users[ id ] = user
		end
		return 0, users
	else
		return 1, nil
	end
end




-------------------------------------------------------------------------------
-- member
-- Purpose: Class index
-------------------------------------------------------------------------------
local member = {}

-------------------------------------------------------------------------------
-- __metatable
-- Purpose: Class metatable
-------------------------------------------------------------------------------
__metatable = {
	__index = member,
	__type = "member"
}

-------------------------------------------------------------------------------
-- member.new()
-- Purpose: Creates a new member object
-- Output: member
-------------------------------------------------------------------------------
function new()
	local t = {
		userID = nil,
		username = nil,
		online = nil,
		usergroup = nil,
		usertitle = nil,
		avatar = nil,
		joinDate = nil,
		postCount = nil,
		links = nil
	}
	setmetatable( t, __metatable )
	return t
end

-------------------------------------------------------------------------------
-- member()
-- Purpose: Shortcut to member.new()
-- Output: member
-------------------------------------------------------------------------------
local metatable = {
	__call = function( _, ... )
		return new( ... )
	end
}
setmetatable( _M, metatable )

-------------------------------------------------------------------------------
-- member:__tostring()
-- Purpose: Returns a string representation of a member
-- Output: string
-------------------------------------------------------------------------------
function __metatable:__tostring()
	if not self.username then return "invalid member" end
	return "member: " .. self.username
end

-------------------------------------------------------------------------------
-- memberNotFoundPattern
-- Purpose: Pattern for detecting if you specified a wrong userID in
--			getDataByUserID
-------------------------------------------------------------------------------
local memberNotFoundPattern = "" ..
"<div class=\"blockrow restore\">Invalid User specified."

-------------------------------------------------------------------------------
-- memberNotRegisteredPattern
-- Purpose: Pattern for detecting if you specified an unregistered username in
--			getDataByUsername
-------------------------------------------------------------------------------
local memberNotRegisteredPattern = "" ..
"<div class=\"blockrow restore\">This user has not registered and therefore does not have a profile to view."

-------------------------------------------------------------------------------
-- memberProfilePattern
-- Purpose: Pattern for filling a member object from their profile page.
-------------------------------------------------------------------------------
local memberProfilePattern = "" ..
-- Clean username
"<title>View Profile: (.-) %- Facepunch" ..
-- Online, formatted username
".-<span id=\"userinfo\">.-<span class=\"(.-)line\">(.-)</span>" ..
-- Title?
"(.-</span>).-</h1>" ..
-- Join Date
".-<dt>Join Date</dt>.-<dd> (.-)</dd>" ..
-- Post Count
".-<dt>Total Posts</dt>.-<dd> (.-)</dd>"
-- TODO: fill links table

-------------------------------------------------------------------------------
-- member.getDataByUserID()
-- Purpose: Fills a member structure from a member userID.
-- Input: userID - user's ID
--		  session - optional session object
-- Output: error code, member object
-- Error Codes: 2 - user not found
-------------------------------------------------------------------------------
function getDataByUserID( userID )
	local r, c = http.get( facepunch.rootURL .. "/members/" .. userID )
	if ( c == 200 ) then
		if string.find( r, memberNotFoundPattern ) then
			return 2, nil
		end
		local member = new()
		for username,
			status,
			displayedUsername,
			optTitle,
			joinDate,
			postCount in string.gmatch( r, memberProfilePattern ) do
				member.userID			= userID -- Gran PC; uh
				member.username			= username
				member.online			= status == "on"
				member.usertitle		= string.match( optTitle, "<span class=\"usertitle\">(.-)</span>" )
				if ( member.usertitle ) then
					member.usertitle	= string.gsub( member.usertitle, "^%s*(.-)%s*$", "%1" )
				end
				member.joinDate			= joinDate
				member.postCount		= postCount
				member.postCount		= string.gsub( member.postCount, "^%s*(.-)%s*$", "%1" )
				member.postCount		= tonumber( string.gsub( member.postCount, ",", "" ), 10 )

				member.avatar			= facepunch.rootURL .. "/image.php?u=" .. userID .. "&dateline=" .. os.time() -- fabricated!

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
		end
		return 0, member
	else
		return 1, nil
	end
end

-------------------------------------------------------------------------------
-- member.getDataByUsername()
-- Purpose: Fills a member structure from a member username.
-- Input: username - user's username
--		  session - optional session object
-- Output: error code, member object
-- Error Codes: 2 - user not found
-------------------------------------------------------------------------------
function getDataByUsername( username )
	local r, c = http.get( facepunch.rootURL .. "/member.php?username=" .. username )
	if ( c == 200 ) then
		if string.find( r, memberNotRegisteredPattern ) then
			return 2, nil
		end
		local member = new()
		for username,
			status,
			displayedUsername,
			optTitle,
			joinDate,
			postCount in string.gmatch( r, memberProfilePattern ) do
				member.userID			= userID -- Gran PC; uh
				member.username			= username
				member.online			= status == "on"
				member.usertitle		= string.match( optTitle, "<span class=\"usertitle\">(.-)</span>" )
				if ( member.usertitle ) then
					member.usertitle	= string.gsub( member.usertitle, "^%s*(.-)%s*$", "%1" )
				end
				member.joinDate			= joinDate
				member.postCount		= postCount
				member.postCount		= string.gsub( member.postCount, "^%s*(.-)%s*$", "%1" )
				member.postCount		= tonumber( string.gsub( member.postCount, ",", "" ), 10 )

				member.avatar			= facepunch.rootURL .. "/image.php?u=" .. userID .. "&dateline=" .. os.time() -- fabricated!

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
		end
		return 0, member
	else
		return 1, nil
	end
end
