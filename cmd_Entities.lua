
-- cmd_Entities.lua

-- Contains commands that do things with entities.





------------------------------------------------
---------------------REMOVE---------------------
------------------------------------------------
function HandleRemoveCommand(a_Split, a_Player)
	-- /remove <EntityTypes>
	
	-- Collect all the entity names with their corresponding type
	local Types = {}
	for Key, Value in pairs(cEntity) do
		if ((type(Value) == "number") and (Key:sub(1, 2) == "et") and (Value ~= cEntity.etPlayer)) then
			Types[Key:sub(3, Key:len()):lower()] = Value
		end
	end
	
	-- Check if the player gave a parameter. If not show them a list of acceptable types.
	if (a_Split[2] == nil) then
		a_Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n/remove <type>")
		local ListEntityNames = ""
		for EntityName, _ in pairs(Types) do
			ListEntityNames = ListEntityNames .. EntityName .. ", "
		end
		
		a_Player:SendMessage(cChatColor.Rose .. "Acceptable types: " .. ListEntityNames:sub(1, ListEntityNames:len() - 2))
		return true
	end
	
	-- Used to check if there is at least one entity type to be removed.
	local NumEntityTypes = 0
	
	-- Check if the parameters given are valid. If not, then ignore them.
	local EntityTypes = {}
	local EntityNames = StringSplit(a_Split[2], ",")
	for Idx, EntityName in ipairs(EntityNames) do
		local LowerCasedEntityName = EntityName:lower()
		if (Types[LowerCasedEntityName]) then
			EntityTypes[Types[LowerCasedEntityName]] = true
			NumEntityTypes = NumEntityTypes + 1
		else
			a_Player:SendMessage(cChatColor.Rose .. "Unknown entity \"" .. EntityName .. "\". Ignoring it.")
		end
	end
	
	-- Bail out of not even one entity type will be removed.
	if (NumEntityTypes == 0) then
		return true
	end
	
	local NumRemovedEntities = 0
	
	-- Go through every entity and check if it should be removed
	a_Player:GetWorld():ForEachEntity(
		function(a_Entity)
			if (EntityTypes[a_Entity:GetEntityType()]) then
				a_Entity:Destroy()
				NumRemovedEntities = NumRemovedEntities + 1
			end
		end
	)
	
	-- Send a message to the player.
	a_Player:SendMessage(cChatColor.LightPurple .. "Marked " .. NumRemovedEntities .. " entit(ies) for removal.")
	return true
end


-------------------------------------------------
---------------------BUTCHER---------------------
-------------------------------------------------
function HandleButcherCommand(Split, Player)
	if Split[2] == nil then -- if the player did not give a radius then the radius is the normal radius
		Radius = ButcherRadius
	elseif tonumber(Split[2]) == nil then -- if the player gave a string as radius then stop
		Player:SendMessage(cChatColor.Rose .. 'Number expected; string "' .. Split[2] .. '" given')
		return true
	else -- the radius is set to the given radius
		Radius = tonumber(Split[2])
	end
	local Cuboid = cCuboid()
	Cuboid.p1 = Vector3i(Player:GetPosX() + Radius, Player:GetPosY() + Radius, Player:GetPosZ() + Radius)
	Cuboid.p2 = Vector3i(Player:GetPosX() - Radius, Player:GetPosY() - Radius, Player:GetPosZ() - Radius)
	Cuboid:Sort()
	local Mobs = 0
	local EachEntity = function(Entity)
		if (Entity:IsMob()) then -- if the entity is a mob 
			if Radius == 0 then -- if the radius is 0 then destroy all the mobs
				Entity:Destroy() -- destroy the mob
				Mobs = Mobs + 1
			else
				if Cuboid:IsInside(Entity:GetPosX(), Entity:GetPosY(), Entity:GetPosZ()) then -- If the mob is inside the radius then destroy it.
					Entity:Destroy()
					Mobs = Mobs + 1
				end
			end
		end
	end
	local World = Player:GetWorld()
	World:ForEachEntity(EachEntity) -- loop through all the entitys
	Player:SendMessage(cChatColor.LightPurple .. "Killed " .. Mobs .. " mobs.")
	return true
end
