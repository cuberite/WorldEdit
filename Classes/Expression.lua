




cExpression = {}





cExpression.m_ExpressionTemplate = 
[[
local abs, acos, asin, atan, atan2,
ceil, cos, cosh, exp, floor, ln, 
log, log10, max, min, round, sin,
sinh, sqrt, tan, tanh, random, pi, e
=
math.abs, math.acos, math.asin, math.atan, math.atan2,
math.ceil, math.cos, math.cosh, math.exp, math.floor, math.log,
math.log, math.log10, math.max, math.min, Round, math.sin,
math.sinh, math.sqrt, math.tan, math.tanh, math.random, math.pi, math.exp(1)

-- These functions are not build into Lua:
local cbrt = function(x) return sqrt(x^(1/3)) end
local randint = function(max) return random(0, max) end
-- TODO: rint function

%s

return function(%s)
	local res = {%s}
	return res[1]%s
end]]





function cExpression:new(a_Formula)
	local Obj = {}
	
	setmetatable(Obj, cExpression)
	self.__index = self
	
	Obj.m_Formula = a_Formula
	Obj.m_Parameters = {}
	Obj.m_PredefinedVariables = {}
	
	return Obj
end





function cExpression:BindParam(a_Name, a_DoReturn)
	table.insert(self.m_Parameters, {name = a_Name, doreturn = a_DoReturn})
	return self
end





function cExpression:PredefineVariable(a_VarName, a_Value)
	table.insert(self.m_PredefinedVariables, {name = a_VarName, value = a_Value})
	return self
end





function cExpression:Compile()
	local Parameters   = ""
	local ReturnValues = ""
	for _, Parameter in ipairs(self.m_Parameters) do
		Parameters = Parameters .. ", " .. Parameter.name
		if (Parameter.doreturn) then
			ReturnValues = ReturnValues .. ", res." .. Parameter.name .. " or " .. Parameter.name
		end
	end
	Parameters = Parameters:sub(3, -1)
	
	local PredefinedVariables = ""
	for _, Variable in ipairs(self.m_PredefinedVariables) do
		local Value = Variable.value
		if (type(Value) == "string") then
			Value = "\"" .. Value .. "\""
		end
		
		PredefinedVariables = PredefinedVariables .. "local " .. Variable.name .. " = " .. Value .. "\n"
	end
	
	local FormulaLoader = loadstring(cExpression.m_ExpressionTemplate:format(PredefinedVariables, Parameters, self.m_Formula, ReturnValues))
	if (not FormulaLoader) then
		return false, "Invalid formula"
	end
	
	local LoaderEnv =
	{
		math = math,
		Round = Round,
	}
	
	-- Only allow the FormulaLoader to use the math library and the Round function
	setfenv(FormulaLoader, LoaderEnv)
	
	-- Try to get the formula checker
	local Succes, Formula = pcall(FormulaLoader)
	if (not Succes) then
		return false, "Invalid formula"
	end
	
	-- Don't allow Formula to interact with the rest of the server except the local variables it already has.
	setfenv(Formula, {})
	
	return Formula
end



