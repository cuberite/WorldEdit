
-- table.lua

-- Contains functions to expand the table library





-- Returns true if the given table is an array, otherwise it returns false
function table.isarray(a_Table)
	local i = 0
	for _, t in pairs(a_Table) do
		i = i + 1
		if (not rawget(a_Table, i)) then
			return false
		end
	end

	return true
end





-- Merges all values (except arrays) from a_DstTable into a_SrcTable if the key doesn't exist in a_SrcTable
function table.merge(a_SrcTable, a_DstTable)
	for Key, Value in pairs(a_DstTable) do
		if (a_SrcTable[Key] == nil) then
			a_SrcTable[Key] = Value
		elseif ((type(Value) == "table") and (type(a_SrcTable[Key]) == "table")) then
			if (not table.isarray(a_SrcTable[Key])) then
				table.merge(a_SrcTable[Key], Value)
			end
		end
	end
	return a_SrcTable
end





-- Creates a table using all the values in a_Table as an index
function table.todictionary(a_Table)
	local res = {}
	for Key, Value in pairs(a_Table) do
		res[Value] = true
	end
	return res
end
