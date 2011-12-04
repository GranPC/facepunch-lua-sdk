local facepunch = require( "facepunch" )
local member = require( "facepunch.member" )

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
	__index = post
	__type = "post"
}

-------------------------------------------------------------------------------
-- post.new()
-- Purpose: Creates a new post object
-- Output: post
-------------------------------------------------------------------------------
function new()
	local t = {
		memberURL = nil,
		username = nil,
		plaintext = nil,
		postnumber = nil,
		ratings = nil
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
-- post:getMember()
-- Purpose: Returns the member who posted this post
-- Output: member
-------------------------------------------------------------------------------
function post:getMember()
	return member( facepunch.baseURL .. memberURL )
end

-------------------------------------------------------------------------------
-- tile:__tostring()
-- Purpose: __tostring metamethod for post
-------------------------------------------------------------------------------
function __metatable:__tostring()
	return "post: " .. self.postnumber
end
