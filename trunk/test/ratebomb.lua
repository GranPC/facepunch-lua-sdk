-- rates every post in a given thread a provided rating
-- usage: lua test\ratebomb.lua

local threadID	= 1178182
local rating	= "Informative"

local facepunch	= require( "facepunch" )
local session	= facepunch.session
local thread	= facepunch.thread

-- Setup our connector
-- Use luasocket for this test
require( "connectors.luasocket" )

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()

local mySession = session( username, password )
print( "Logging in as " .. username .. "..." )
local error = -1
while error ~= 0 do
	error = mySession:login()
end
print( "Logged in!" )

session.setActiveSession( mySession )

local error, token = -1, nil
while error ~= 0 do
	error, token = session.getSecurityToken()
end

-- Andrew; retrieve a thread, page 1
local error, threadPage = -1, ""
while error ~= 0 do
	error, threadPage = thread.getPage( threadID, 1 )
end

-- Andrew; rates all posts parsed on page 1 of FP Api Testing Bed Please Ignore
local posts = thread.getPostsInPage( threadPage )
for _, post in pairs( posts ) do
	local error = -1
	while error ~= 0 do
		error = post:rate( rating, token )
	end
	print( "Rated " .. tostring( post.postID ) .. " " .. rating .. "!" )
end
