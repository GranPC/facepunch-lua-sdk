local core = require( "md5.core" )
local string = string

module ("md5")

function sumhexa( k )
	k = core.sum( k )
	return string.gsub( k, ".", function( c )
		return string.format( "%02x", string.byte( c ) )
	end)
end
