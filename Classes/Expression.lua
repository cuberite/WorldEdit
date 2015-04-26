




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
math.log, math.log10, math.max, math.min, math.round, math.sin,
math.sinh, math.sqrt, math.tan, math.tanh, math.random, math.pi, math.exp(1)

-- These functions are not build into Lua:
local cbrt = function(x) return sqrt(x^(1/3)) end
local randint = function(max) return random(0, max) end
-- TODO: rint function

%s

return function(%s)
	%s
	return %s
end]]





cExpression.m_LoaderEnv =
{
	math = math,
}





cExpression.m_Assignments =
{
	"=",
	"%+=",
	"%-=",
	"%*=",
	"%%=",
	"%^=",
	"/=",
}





cExpression.m_Comparisons =
{
	"<",
	">",
	"<=",
	">=",
	"==",
	"!=",
	"~=",
}





function cExpression:new(a_Formula)
	local Obj = {}
	
	a_Formula = a_Formula
	:gsub("!=", "~=") -- Lua operator for not equal is ~=
	:gsub("&&", " and ")
	:gsub("||", " or ")
	
	setmetatable(Obj, cExpression)
	self.__index = self
	
	Obj.m_Formula = a_Formula
	Obj.m_Parameters = {}
	Obj.m_PredefinedVariables = {}
	
	return Obj
end





function cExpression:BindParam(a_Name, a_DoReturn, a_IsParameter)
	table.insert(self.m_Parameters, {name = a_Name, doreturn = a_DoReturn, isparam = a_IsParameter})
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
		if (Parameter.isparam) then
			Parameters = Parameters .. ", " .. Parameter.name
		end
		
		if (Parameter.doreturn) then
			ReturnValues = ReturnValues .. ", " .. Parameter.name
		end
	end
	Parameters   = Parameters:sub(3, -1)
	ReturnValues = ReturnValues:sub(3, -1)
	
	local PredefinedVariables = ""
	for _, Variable in ipairs(self.m_PredefinedVariables) do
		local Value = Variable.value
		if (type(Value) == "string") then
			Value = "\"" .. Value .. "\""
		end
		
		PredefinedVariables = PredefinedVariables .. "local " .. Variable.name .. " = " .. Value .. "\n"
	end
	
	local NumComparison = 1
	local Actions = StringSplitAndTrim(self.m_Formula, ";")
	for Idx, Action in ipairs(Actions) do
		Action = Action:gsub("%s+", "")
		
		local IsAssignment = true
		
		-- If one of the comparison operator's are in the action we can be sure that it's an assignment
		for _, Comparison in ipairs(cExpression.m_Comparisons) do
			IsAssignment = IsAssignment and not Action:match(Comparison)
		end
		
		if (IsAssignment) then
			-- m_Assignments[1] is an =, and that doesn't need any special handeling
			for I = 2, #cExpression.m_Assignments do
				local Assignment = cExpression.m_Assignments[I]:match(".="):sub(1, 1)
				local Pattern = "(.*)" .. cExpression.m_Assignments[I] .. "(.*)"
				Action:gsub(Pattern,
					function(a_Variable, a_Val2)
						Action = a_Variable .. " = " .. a_Variable .. Assignment .. a_Val2
					end
				)
			end
			
			Actions[Idx] = "local " .. Action
		else
			Actions[Idx]  = "local Comp" .. NumComparison .. " = " .. Action
			NumComparison = NumComparison + 1
		end
	end
	
	local FormulaLoader = loadstring(cExpression.m_ExpressionTemplate:format(PredefinedVariables, Parameters, table.concat(Actions, "\n\t"), ReturnValues))
	if (not FormulaLoader) then
		return false, "Invalid formula"
	end
	
	-- Only allow the FormulaLoader to use the math library and the Round function
	setfenv(FormulaLoader, cExpression.m_LoaderEnv)
	
	-- Try to get the formula checker
	local Succes, Formula = pcall(FormulaLoader)
	if (not Succes) then
		return false, "Invalid formula"
	end
	
	-- Don't allow Formula to interact with the rest of the server except the local variables it already has.
	setfenv(Formula, {})
	
	return Formula
end




