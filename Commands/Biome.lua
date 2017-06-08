




function HandleSetBiomeCommand(a_Split, a_Player)
	local function SendWrongArguments(Reason)
		a_Player:SendMessage(cChatColor.Rose .. Reason .. " arguments.")
		a_Player:SendMessage(cChatColor.Rose .. "//setbiome [-p] <biome>")
		a_Player:SendMessage(cChatColor.Rose .. "") -- Extra space
		a_Player:SendMessage(cChatColor.Rose .. "Sets the biome of the region.")
		a_Player:SendMessage(cChatColor.Rose .. "By default sets the biome in your selected area.")
		a_Player:SendMessage(cChatColor.Rose .. "-p sets biome in the column you are currently standing in.")
	end

	if #a_Split == 1 then
		SendWrongArguments("Too few")
		return true
	end

	if #a_Split > 3 then
		SendWrongArguments("Too many")
		return true
	end

	local World = a_Player:GetWorld()
	local PosX = math.floor(a_Player:GetPosX())
	local PosZ = math.floor(a_Player:GetPosZ())

	if #a_Split == 3 then
		if a_Split[2] ~= "-p" then
			SendWrongArguments("Too many")
			return true
		end

		local NewBiome = StringToBiome(a_Split[3])
		if NewBiome == biInvalidBiome then
			a_Player:SendMessage(cChatColor.Rose .. "Unknown biome type: '" .. a_Split[3] .. "'.")
			return true
		end

		World:SetAreaBiome(PosX, PosX, PosZ, PosZ, NewBiome)
		a_Player:SendMessage(cChatColor.LightPurple .. "Biome changed to " .. a_Split[3] .. " at your current location.")
		return true
	elseif #a_Split == 2 then
		local NewBiome = StringToBiome(a_Split[2])
		if NewBiome == biInvalidBiome then
			a_Player:SendMessage(cChatColor.Rose .. "Unknown " .. a_Split[2] .. " biome type.")
			return true
		end

		local State = GetPlayerState(a_Player)
		if not(State.Selection:IsValid()) then
			a_Player:SendMessage(cChatColor.Rose .. "You need to select a region first.")
			return true
		end
		local MinX, MaxX = State.Selection:GetXCoordsSorted()
		local MinZ, MaxZ = State.Selection:GetZCoordsSorted()

		World:SetAreaBiome(MinX, MaxX, MinZ, MaxZ, NewBiome)
		a_Player:SendMessage(cChatColor.LightPurple .. "Biome changed to " .. a_Split[2] .. ". " .. (1 + MaxX - MinX) * (1 + MaxZ - MinZ) .. " columns affected.")
		return true
	end
	return true
end





function HandleBiomeListCommand(a_Split, a_Player)
	-- /biomelist

	local Page = a_Split[2] ~= nil and a_Split[2] or 1

	-- TODO: Load the biomes on start, not when the command is executed
	local Biomes = {}
	for Key, Value in pairs(_G) do
		if (Key:match("bi(.*)")) then
			table.insert(Biomes, BiomeToString(Value))
		end
	end
	table.sort(Biomes)

	a_Player:SendMessage(cChatColor.Green .. "Page " .. Page .. "/" .. math.floor(#Biomes / 8))

	local MinIndex = Page * 8
	local MaxIndex = MinIndex + 8
	for I = MinIndex, MaxIndex do
		local Biome = Biomes[I]
		if (not Biome) then
			break
		end

		a_Player:SendMessage(cChatColor.LightPurple .. Biome)
	end
	return true
end





function HandleBiomeInfoCommand(a_Split, a_Player)
	-- /biomeinfo

	-- If a "-p" param is present, report the biome at player's position:
	if (a_Split[2] == "-p") then
		local Biome = BiomeToString(a_Player:GetWorld():GetBiomeAt(math.floor(a_Player:GetPosX()), math.floor(a_Player:GetPosZ())))
		a_Player:SendMessage(cChatColor.LightPurple .. "Biome: " .. Biome)
		return true
	end

	-- Get the player state:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end

	-- Retrieve set of biomes in the selection:
	local BiomesSet = {}
	local MinX, MaxX = State.Selection:GetXCoordsSorted()
	local MinZ, MaxZ = State.Selection:GetZCoordsSorted()
	local World = a_Player:GetWorld()
	for X = MinX, MaxX do
		for Z = MinZ, MaxZ do
			BiomesSet[World:GetBiomeAt(X, Z)] = true
		end
	end

	-- Convert set to array of names:
	local BiomesArr = {}
	for b, val in pairs(BiomesSet) do
		if (val) then
			table.insert(BiomesArr, BiomeToString(b))
		end
	end

	-- Send the list to the player:
	a_Player:SendMessage(cChatColor.LightPurple .. "Biomes: " .. table.concat(BiomesArr, ", "))
	return true
end
