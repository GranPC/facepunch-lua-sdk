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
		links = {}
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
-- member:__eq( member )
-- Purpose: Compares against another member object
-- Output: boolean
-------------------------------------------------------------------------------
function member:__eq( member )
	if not self.username then return false end
	return self.username == member.username
end

-------------------------------------------------------------------------------
-- member:__tostring()
-- Purpose: Returns a string representation of a member
-- Output: string
-------------------------------------------------------------------------------
function __metatable:__tostring()
	if not self.username then return "invalid member" end
	return "member: " .. self.username
end
