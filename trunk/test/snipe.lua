-- snipes a thread, crowns you the page king

-- Snipe LMAO Pics v. 99 forever and always
local threadID = 1125443

require( "facepunch" )
require( "connectors.luasocket" )

local thread = facepunch.thread
local session = facepunch.session

-- A sleep function so we're not retrieving the thread constantly, uses seconds
local function sleep( n )
	local t0 = os.clock()
	while os.clock() - t0 <= n do end
end

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()
local mySession = session( username, password )

local function login( loginSession )
	print( "Logging in as " .. username .. "..." )
	local error = -1
	while error ~= 0 do
		error = loginSession:login()
	end
	print( "Logged in!" )
	session.setActiveSession( loginSession )
end

login( mySession )

print( "Grabbing initial thread information..." )
local error, threadPage = -1, ""
local threadName = ""
local _, threadPageCount = nil, -1
while error ~= 0 do
	error, threadPage = thread.getPage( threadID )
	threadName = thread.getName( threadPage )
	_, threadPageCount = thread.getPaginationInfo( threadPage )
	error, threadPage = thread.getPage( threadID, threadPageCount )
end
print( threadName )
print( "Page count: " .. threadPageCount )

local function refresh()
	print( "Refreshing page..." )
	error, threadPage = -1, ""
	while error ~= 0 do
		error, threadPage = thread.getPage( threadID, threadPageCount )
	end
	local newPageCount, oldPageCount = -1, threadPageCount
	_, newPageCount = thread.getPaginationInfo( threadPage )
	if ( newPageCount ~= oldPageCount ) then
		threadPageCount = newPageCount
		error, threadPage = -1, ""
		while error ~= 0 do
			error, threadPage = thread.getPage( threadID, threadPageCount )
		end
	end
end

sleep( 1 )

local firstRetrieval = true
local posts = {}
while true do
	if ( firstRetrieval == false ) then
		refresh()
	end
	os.execute( "cls" )
	if ( thread.canGuestViewPage( threadPage ) ) then
		posts = thread.getPostsInPage( threadPage )
		local n = 0
		for _, _ in pairs( posts ) do
			n = n + 1
		end
		local currentPostNumber = posts[ n ].postNumber
		print( "Current post count: " .. currentPostNumber )
		local eligible = ( currentPostNumber % 40 == 0 )
		print( "Page king eligiblity: " .. ( eligible and "true" or "false" ) )
		if ( not eligible ) then
			local postsLeft = ( currentPostNumber - currentPostNumber % 40 ) + 40 - currentPostNumber
			print( "Posts until page king eligiblity: " .. postsLeft )
		else
			print( "POST NOW FAGGOT." )
			break;
		end
	else
		-- Did we get logged out somehow? Oh well, log in again
		login( mySession )
	end
	if ( firstRetrieval == true ) then
		firstRetrieval = false
	end

	sleep( 1 )
end
