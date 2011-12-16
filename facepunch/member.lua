-------------------------------------------------------------------------------
-- Member module and class definition
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local setmetatable = setmetatable

module( "facepunch.member" )

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
