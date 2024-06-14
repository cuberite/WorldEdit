
-- math.lua

-- Contains functions to expand the math library





-- Rounds the number.
function math.round(a_GivenNumber)
	local Number, Decimal = math.modf(a_GivenNumber)
	if (Decimal >= 0.5) then
		return Number + 1
	else
		return Number
	end
end
