
Extractors = 
{
	Number = function(a_Value, a_Player, a_Min, a_Max)
		local min = a_Min ~= nil and a_Min or -math.huge;
		local max = a_Max ~= nil and a_Max or math.huge;
		local res = tonumber(a_Value)
		if (not res) then
			return false, "Number expected; " .. a_Value .. " provided";
		else
			if (res < min) then
				return false, "Provided number is too low; The minimum is " .. min;
			elseif (res > max) then
				return false, "Provided number is too large; The maximum is " .. max
			else
				return true, res;
			end
		end
	end,
	
	Block = function(a_Value, a_Player)
		local parsed, errorBlock = GetBlockDst(a_Value, a_Player)
		if (not parsed) then
			return false, (errorBlock or a_Value) .. " is not a valid block.";
		else
			return true, parsed;
		end
	end,
	
	PositiveMask = function(a_Value, a_Player)
		local mask, errorMsg = cMask:new(a_Value)
		if (not mask) then
			return false, errorMsg
		else
			return true, mask
		end
	end,
	
	String = function(a_Value, a_Player)
		return true, a_Value;
	end,
}





cCommandParser = {}
cCommandParser.__index = cCommandParser





function cCommandParser:new(a_StartIndex)
	local obj = setmetatable({}, self);
	obj.StartIndex = a_StartIndex;
	obj.ArgumentList = {};
	obj.FlagList = {};
	return obj;
end





--[[ Syntax for a_Arguments
{
	{ name = "block", extractor = Extractors.Block},
	{ name = "radius", extractor = Extractors.Number},
	{ name = "depth", extractor = Extractors.Number, optional = true },
}
]]
function cCommandParser:Arguments(a_Arguments)
	table.insert(self.ArgumentList, a_Arguments);
	return self
end





--[[ Syntax for a_Flags:
{
	{ name = 'hollow', character = 'h' },
	{ name = 'other', character = 'o' }
}
]]
function cCommandParser:Flags(a_Flags)
	self.FlagList = a_Flags
	return self
end





function cCommandParser:GetMinimalArguments()
	local minimalRequired = self.StartIndex - 1;
	local allSyntaxMinRequired = {}
	for idx, syntax in ipairs(self.ArgumentList) do
		local numRequiredArguments = self:GetMinimalArgumentsFor(syntax);
		table.insert(allSyntaxMinRequired, numRequiredArguments);
	end
	return minimalRequired + math.min(unpack(allSyntaxMinRequired))
end




function cCommandParser:GetMinimalArgumentsFor(a_Syntax)
	local numRequiredArguments = 0;
	for idx, argument in ipairs(a_Syntax) do
		if (argument.optional) then
			-- Assume all optional arguments are at the end
			break;
		end
		numRequiredArguments = numRequiredArguments + 1
	end
	return numRequiredArguments;
end





function cCommandParser:GetMaximalArguments()
	local allSyntaxMaxRequired = {}
	for idx, syntax in ipairs(self.ArgumentList) do
		local numRequiredArguments = self:GetMaximalArgumentsFor(syntax);
		table.insert(allSyntaxMaxRequired, numRequiredArguments);
	end
	return math.max(unpack(allSyntaxMaxRequired))
end





function cCommandParser:GetMaximalArgumentsFor(a_Syntax)
	return #a_Syntax + self.StartIndex - 1 + #self.FlagList;
end





function cCommandParser:HasEnoughParameters(a_NumParams)
	if (a_NumParams < self:GetMinimalArguments()) then
		return false, "Too few arguments. CHANGEME!";
	elseif (a_NumParams > self:GetMaximalArguments()) then
		return false, "Too many arguments. CHANGEME!";
	end
	return true
end





function cCommandParser:GetCompatibalSyntaxes(a_NumParameters)
	local res = {}
	for idx, syntax in ipairs(self.ArgumentList) do
		if (
			(a_NumParameters >= self:GetMinimalArgumentsFor(syntax)) and
			(a_NumParameters <= self:GetMaximalArgumentsFor(syntax))
		) then
			table.insert(res, syntax)
		end
	end
	return res;
end





function cCommandParser:CreateSuggestionMessage(a_Split)
	local start = table.concat(a_Split, " ", 1, self.StartIndex - 1)
	local res = "Usages:\n"
	local usages = {}
	for key, syntax in ipairs(self.ArgumentList) do
		table.insert(usages, self:CreateSuggestionMessageFor(syntax, start))
	end
	res = res .. table.concat(usages, "\n")
	return res;
end





function cCommandParser:CreateSuggestionMessageFor(a_Syntax, a_Prefix)
	local res = a_Prefix;
	
	if (self.FlagList[1]) then
		res = res .. " -"
		for idx, flag in ipairs(self.FlagList) do
			res = res .. flag.character
		end
	end

	for idx, argument in ipairs(a_Syntax) do
		local template = "<%s>"
		if (argument.optional) then
			template = "[%s]"
		end
		res = res .. " " .. template:format(argument.name)
	end
	return res;
end





function cCommandParser:ExtractFlags(a_Argument)
	local workingString = a_Argument
	local returnObj = {}
	for key, flag in ipairs(self.FlagList) do
		returnObj[flag.name] = false
	end
	
	while (true) do
		local foundFlag = false
		for idx, flag in ipairs(self.FlagList) do
			if (workingString:sub(1, flag.character:len()) == flag.character) then
				returnObj[flag.name] = true
				foundFlag = true
				workingString = workingString:sub(flag.character:len() + 1)
				break;
			end
		end
		if (not foundFlag) then
			break;
		end
	end
	return returnObj
end




function cCommandParser:Match(a_Split, a_ArgumentSyntax, a_CurrentIndex, a_Player)
	local numArguments = #a_Split - self.StartIndex + 1
	if (numArguments < self:GetMinimalArgumentsFor(a_ArgumentSyntax)) then
		return false, "Not enough parameters";
	end
	local returnObj = {}
	for idx, argument in ipairs(a_ArgumentSyntax) do
		local splitValue = a_Split[a_CurrentIndex + idx - 1]
		if (not splitValue) then
			if (argument.optional) then
				return true, returnObj
			end
			return false, "Not enough parameters"
		end
		
		local success, res = argument.extractor(splitValue, a_Player, unpack(argument.extractorparameters or {}))
		if (not success) then
			return false, res
		end
		returnObj[argument.name] = res
	end
	return true, returnObj
end





function cCommandParser:Parse(a_Split, a_Player)
	local compatibalSyntaxes = self:GetCompatibalSyntaxes(#a_Split - self.StartIndex + 1)
	if (#compatibalSyntaxes == 0) then
		return false, self:CreateSuggestionMessage(a_Split)
	end
	
	local returnObj = 
	{
		Arguments = {},
		Flags = {}
	}
	local currentIndex = self.StartIndex;
	if (self.FlagList[1]) then
		if (a_Split[currentIndex]:sub(1, 1) == "-") then
			returnObj.Flags = self:ExtractFlags(a_Split[currentIndex]:sub(2));
			currentIndex = currentIndex + 1
		end
	end
	
	local success, res
	for idx, syntax in ipairs(compatibalSyntaxes) do
		success, res = self:Match(a_Split, syntax, currentIndex, a_Player)
		if (success) then
			returnObj.Arguments = res
			return true, returnObj
		end
	end
	return false, res
end





