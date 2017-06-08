
-- Expression.lua

-- Contains the cExpression class. This allows formulas to be executed safely in an empty environment.
--[[ Usage example:
local FormulaString = "data=4; x > y"
local Expression = cExpression:new(FormulaString)

Expression:AddReturnValue("Comp1")           -- Return the first known comparisons
:AddParameter("x")                           -- Add x and y as a parameter
:AddParameter("y")
:AddParameter("type"):AddReturnValue("type") -- Add type and data as a parameter and return it
:AddParameter("data"):AddReturnValue("data")

local Formula = Expression:Compile()

for X = 1, 5 do
	for Y = 1, 5 do
		local PlaceBlock, BlockType, BlockMeta = Formula(X, Y, E_BLOCK_AIR, 0)
		if (PlaceBlock) then
			-- Place the block
		end
	end
end
]]





cExpression = {}





cExpression.m_ExpressionTemplate =
[[
local assert, pairs = assert, pairs
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
local rint = function(num) local Number, Decimal = math.modf(num); return (Decimal <= 0.5) and Number or (Number + 1) end

%s

local validators = {...}

return function(%s)
	%s
	for _, validator in pairs(validators) do
		assert(validator(%s))
	end
	return %s
end]]





-- The envoronment of the loader.
-- It can currently only use the functions from the math library.
cExpression.m_LoaderEnv =
{
	math = math,
	assert = assert,
	pairs = pairs,
}





-- All the assignment operator
-- Since Lua only supports the simple = assignments we need to give the others special handling.
-- The = assignment is special because it can also be used in comparisons >=, == etc
cExpression.m_Assignments =
{
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
	{Usage = "if%s%((.*)%)%s(.*)%selse%s(.*)", Result = "%s and %s or %s"},
	{Usage = "if%s%((.*)%)%s(.*)", Result = "%s and %s"},
	{Usage = "(.*)<(.*)", Result = "%s<%s"},
	{Usage = "(.*)>(.*)", Result = "%s>%s"},
	{Usage = "(.*)<=(.*)", Result = "%s<=%s"},
	{Usage = "(.*)>=(.*)", Result = "%s>=%s"},
	{Usage = "(.*)==(.*)", Result = "%s==%s"},
	{Usage = "(.*)!=(.*)", Result = "%s~=%s"},
	{Usage = "(.*)~=(.*)", Result = "%s~=%s"}, -- TODO: Make this use a near function when implemented
}





function cExpression:new(a_Formula)
	local Obj = {}

	a_Formula = a_Formula
	:gsub("&&", " and ")
	:gsub("||", " or ")

	setmetatable(Obj, cExpression)
	self.__index = self

	-- The string of the formula
	Obj.m_Formula = a_Formula

	-- All the variables that that the formula can use. For example x, y and z
	Obj.m_Parameters = {}

	-- All the variables the formula will return after executing
	Obj.m_ReturnValues = {}

	-- A table containing predefined variables. A new one can be added using the PredefineVariable function
	Obj.m_PredefinedConstants = {}

	-- A table containing functions used to validate the return values
	Obj.m_ReturnValidators = {}

	return Obj
end





-- Adds a new parameter to the formula. The formula can use this in the calculation.
-- a_Name is a string that will be the name of the parameter
function cExpression:AddParameter(a_Name)
	table.insert(self.m_Parameters, a_Name)
	return self
end





-- Makes the formula return a variable when executing
-- a_Name is the name of the variable that will be returned.
-- If a comparison has to be returned you can add a return value called Comp<id> where <id> is how many comparisons there were starting from 1.
-- For example in the formula "x<z; y>z" x<z is Comp1, and y>z is Comp2
function cExpression:AddReturnValue(a_Name)
	table.insert(self.m_ReturnValues, a_Name)
	return self
end





-- Adds a validator to check if the return value is allowed.
-- a_Validator is a function. If it returns false the expression will assert
function cExpression:AddReturnValidator(a_Validator)
	table.insert(self.m_ReturnValidators, a_Validator)
	return self
end





-- Adds a new constant. The formula will be able to use this in it's calculation.
-- a_VarName is a string that will be the name of the constant.
-- a_Value can only be a string or a number, since the environment blocks all other functions and tables.
function cExpression:PredefineConstant(a_VarName, a_Value)
	table.insert(self.m_PredefinedConstants, {name = a_VarName, value = a_Value})
	return self
end





-- Creates a safe function from the formula string.
-- The returned function takes the previously-bound parameters (AddParameter()), does the calculations using any predefined constants (PredefineConstant()) and returns the named values (AddReturnValue())
-- Comparisons can be returned by adding a return value called "Comp<id>" where <nr> is the ID of the comparison starting from 1. For example in the formula "x<z; y>z" x<z is Comp1, and y>z is Comp2
function cExpression:Compile()
	local Arguments    = table.concat(self.m_Parameters, ", ")
	local ReturnValues = table.concat(self.m_ReturnValues, ", ")

	local PredefinedVariables = ""
	for _, Variable in ipairs(self.m_PredefinedConstants) do
		local Value = Variable.value
		if (type(Value) == "string") then
			Value = "\"" .. Value .. "\""
		end

		PredefinedVariables = PredefinedVariables .. "local " .. Variable.name .. " = " .. Value .. "\n"
	end

	-- The number of comparisons. This will be used to give each comparison a name (Comp<id>)
	local NumComparison = 1

	-- Split the formula into actions (For example in "data=5; x<y" data=5 is an action, and x<y is an action.)
	local Actions = StringSplitAndTrim(self.m_Formula, ";")

	-- If an action is an assignment in a format unsupported by Lua (a += 1), convert it into a supported format (a = a + 1).
	-- If an action is a comparison then give it the name "Comp<id>"
	for Idx, Action in ipairs(Actions) do
		-- Check if the = operator is found
		local IsAssignment = Action:match("[%a%d%s]=[%(%a%d%s]") ~= nil

		-- Check if one of the assignment operators is found. If one is found it's certain that the action is an assignment.
		for Idx, Assignment in pairs(cExpression.m_Assignments) do
			if (Action:match(Assignment)) then
				IsAssignment = true
			end
		end

		-- Make all the comparisons work properly. For example != is used instead of ~=, while ~= is used to see if 2 numbers are near each other.
		for _, Comparison in ipairs(cExpression.m_Comparisons) do
			if (Action:match(Comparison.Usage)) then
				Action = Comparison.Result:format(Action:match(Comparison.Usage))
			end
		end

		if (IsAssignment) then
			-- The action is an assignment. Since Lua only supports the simple = assignments we got to do some special handling for the <action>assign assignments like += and *=.
			for Idx, Assignment in pairs(cExpression.m_Assignments) do
				-- Get what type of assignment it is (multiply, divide etc)
				local Operator = Assignment:match(".="):sub(1, 1)

				-- This pattern will get the name of the variable to assign, and everything to add/devide/multiply etc
				local Pattern = "(.*)" .. Assignment .. "(.*)"
				Action:gsub(Pattern,
					function(a_Variable, a_Val2)
						Action = a_Variable .. " = " .. a_Variable .. Operator .. a_Val2
					end
				)
			end

			-- Add the assignment in the formula function
			Actions[Idx] = "local " .. Action
		else
			-- Add the comparison. The name will be Comp<id> where nr is how many comparison's there currently are.
			Actions[Idx]  = "local Comp" .. NumComparison .. " = " .. Action
			NumComparison = NumComparison + 1
		end
	end

	local formulaLoaderSrc = cExpression.m_ExpressionTemplate:format(PredefinedVariables, Arguments, table.concat(Actions, "\n\t"), ReturnValues, ReturnValues)
	local FormulaLoader = loadstring(formulaLoaderSrc)
	if (not FormulaLoader) then
		return false, "Invalid formula"
	end

	-- Only allow the FormulaLoader to use the math library and the Round function
	setfenv(FormulaLoader, cExpression.m_LoaderEnv)

	-- Try to get the formula checker
	local Succes, Formula = pcall(FormulaLoader, unpack(self.m_ReturnValidators))
	if (not Succes) then
		return false, "Invalid formula"
	end

	-- Don't allow Formula to interact with the rest of the server except the local variables it already has.
	setfenv(Formula, {})

	return Formula
end
