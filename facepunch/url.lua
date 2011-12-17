-------------------------------------------------------------------------------
-- URL module
-- Facepunch Lua API
-- Authors: Andrew McWatters
--			Gran PC
--			Gregor Steiner
-------------------------------------------------------------------------------
local string = string

module( "facepunch.url" )

-------------------------------------------------------------------------------
-- url.escape()
-- Purpose: Encodes a string into its escaped hexadecimal representation
-- Input: s - binary string to be encoded
-- Output: escaped representation of string binary
-------------------------------------------------------------------------------
function escape( s )
	return string.gsub( s, "([^A-Za-z0-9_])", function( c )
		return string.format( "%%%02x", string.byte( c ) )
	end)
end
