
-- string.lua

-- Contains functions to expand the string library





-- Makes the first character of a string uppercase, and lowercases the rest.
function string.ucfirst(a_String)
	local firstChar = a_String:sub(1, 1):upper()
	local Rest = a_String:sub(2):lower()
	
	return firstChar .. Rest
end




