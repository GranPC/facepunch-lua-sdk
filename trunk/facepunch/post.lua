local facepunch = require( "facepunch" )
local member = require( "facepunch.member" )
local setmetatable = setmetatable

module( "facepunch.post" )

-------------------------------------------------------------------------------
-- post
-- Purpose: Class index
-------------------------------------------------------------------------------
local post = {}

-------------------------------------------------------------------------------
-- __metatable
-- Purpose: Class metatable
-------------------------------------------------------------------------------
__metatable = {
	__index = post,
	__type = "post"
}

-------------------------------------------------------------------------------
-- post.new()
-- Purpose: Creates a new post object
-- Output: post
-------------------------------------------------------------------------------
function new()
	local t = {
		postDate = nil,
		link = nil,
		postNumber = nil,
		postRatings = {}
	}
	setmetatable( t, __metatable )
	return t
end

-------------------------------------------------------------------------------
-- post()
-- Purpose: Shortcut to post.new()
-- Output: post
-------------------------------------------------------------------------------
local metatable = {
	__call = function( _, ... )
		return new( ... )
	end
}
setmetatable( _M, metatable )

-------------------------------------------------------------------------------
-- tile:__tostring()
-- Purpose: __tostring metamethod for post
-------------------------------------------------------------------------------
function __metatable:__tostring()
	if not self.postNumber then return "invalid post" end
	return "post: " .. self.postNumber
end
