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
		postID = nil,
		postNumber = nil,
		postRatings = nil,
		postRatingKeys = nil
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
-- post:rate()
-- Purpose: Rates a post
-- Input: rating - name of the rating
-------------------------------------------------------------------------------
function post:rate( rating )
	if ( facepunch.ratings[ rating ] and self.postRatingKeys[ rating ] ) then
		local securityToken = facepunch.getSecurityToken()
		
		if ( securityToken ~= "guest" ) then
			local postFields = "" ..
			-- Method
			"do=" .. "rate_post" ..
			-- PostID
			"&postid=" .. self.postID ..
			-- Rating
			"&rating=" .. facepunch.ratings[ rating ] ..
			-- Key
			"&key=" .. self.postRatingKeys[ rating ] ..
			-- Securitytoken
			"&securitytoken=" .. securityToken
			
			facepunch.http.post( facepunch.baseURL .. facepunch.ajaxPage, postFields )
		end
	end
end

-------------------------------------------------------------------------------
-- post:__tostring()
-- Purpose: __tostring metamethod for post
-------------------------------------------------------------------------------
function __metatable:__tostring()
	if not self.postNumber then return "invalid post" end
	return "post: " .. self.postNumber
end
