
-- Expression.lua

-- Contains the cExpression class. This allows formulas to be executed safely in an empty environment.





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





-- The envoronment of the loader. 
-- It can currently only use the functions from the math library.
cExpression.m_LoaderEnv =
{
	math = math,
}





-- All the assignment operator
-- Since Lua only supports the simple = assignments we need to give the others special handling
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





-- A list of all the comparison operators. This is used to see if an action is an assignment or a comparison.
-- For example if "x=5;y<z" was given as input then the first action is an assignment, while the second action is a comparison.
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
	
	-- The string of the formula
	Obj.m_Formula = a_Formula
	
	-- All the parameters that are going to be used. A new one can be bind using the BindParam function.
	Obj.m_Parameters = {}
	
	-- A table containing predefined variables. A new one can be added using the PredefineVariable function
	Obj.m_PredefinedVariables = {}
	
	return Obj
end





-- Binds a new parameter to the formula.
-- a_Name is a string that will be the name of the parameter
-- a_DoReturn is a boolean value. If true the value will be returned when executing the variable.
-- a_IsParameter is a boolean value. If true the parameter will be an argument for the formula. This is only used to bind new comparison values since they don't have a name by default.
-- The comparison values will be "Comp<ComparisonNr>"
function cExpression:BindParam(a_Name, a_DoReturn, a_IsParameter)
	table.insert(self.m_Parameters, {name = a_Name, doreturn = a_DoReturn, isparam = a_IsParameter})
	return self
end





-- Adds a new variable. The formula will be able to use this variable in it's calculation.
-- a_VarName is a string that will be the name of the variable.
-- a_Value can only be a string or a number, since the environment blocks all other functions and tables.
function cExpression:PredefineVariable(a_VarName, a_Value)
	table.insert(self.m_PredefinedVariables, {name = a_VarName, value = a_Value})
	return self
end





-- Creates a safe function from the formula string, the bound parameters and the predefined variables.
function cExpression:Compile()
	local Arguments    = ""
	local ReturnValues = ""
	
	-- Concat the parameters.
	for _, Parameter in ipairs(self.m_Parameters) do
		if (Parameter.isparam) then
			-- Only add the parameter as argument to the function formula if it was set.
			Arguments = Arguments  .. ", " .. Parameter.name
		end
		
		if (Parameter.doreturn) then
			-- Only return the value if it was said to.
			ReturnValues = ReturnValues .. ", " .. Parameter.name
		end
	end
	
	-- Remove the first comma in both the Arguments, and the ReturnValues.
	Arguments    = Arguments:sub(3, -1)
	ReturnValues = ReturnValues:sub(3, -1)
	
	local PredefinedVariables = ""
	for _, Variable in ipairs(self.m_PredefinedVariables) do
		local Value = Variable.value
		if (type(Value) == "string") then
			Value = "\"" .. Value .. "\""
		end
		
		PredefinedVariables = PredefinedVariables .. "local " .. Variable.name .. " = " .. Value .. "\n"
	end
	
	-- The number of comparisons. This will be used to give each comparison a name (Comp<nr>)
	local NumComparison = 1
	
	-- Split the formula into actions (For example in "data=5; x<y" data=5 is an action, and x<y is an action.)
	local Actions = StringSplitAndTrim(self.m_Formula, ";")
	
	-- Loop through each action to check if the action is an comparison or an assignment. Handle the actions accordingly.
	for Idx, Action in ipairs(Actions) do
		Action = Action:gsub("%s+", "")
		
		local IsAssignment = true
		
		-- If one of the comparison operator's are in the action we can be sure that it's an assignment
		for _, Comparison in ipairs(cExpression.m_Comparisons) do
			IsAssignment = IsAssignment and not Action:match(Comparison)
		end
		
		if (IsAssignment) then
			-- The action is an assignment. Since Lua only supports the simple = assignments we got to do some special handling for the <action>assign assignments like += and *=.
			-- m_Assignments[1] is an =, and that doesn't need any special handeling
			for I = 2, #cExpression.m_Assignments do
				-- Get what type of assignment it is (multiply, divide etc)
				local Assignment = cExpression.m_Assignments[I]:match(".="):sub(1, 1)
				
				-- This pattern will get the name of the variable to assign, and everything to add/devide/multiply etc
				local Pattern = "(.*)" .. cExpression.m_Assignments[I] .. "(.*)"
				Action:gsub(Pattern,
					function(a_Variable, a_Val2)
						Action = a_Variable .. " = " .. a_Variable .. Assignment .. a_Val2
					end
				)
			end
			
			-- Add the assignment in the formula function
			Actions[Idx] = "local " .. Action
		else
			-- Add the comparison. The name will be Comp<nr> where nr is how many comparison's there currently are.
			Actions[Idx]  = "local Comp" .. NumComparison .. " = " .. Action
			NumComparison = NumComparison + 1
		end
	end
	
	local FormulaLoader = loadstring(cExpression.m_ExpressionTemplate:format(PredefinedVariables, Arguments, table.concat(Actions, "\n\t"), ReturnValues))
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




