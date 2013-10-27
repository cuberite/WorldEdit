------------------------------------------------
---------------------REMOVE---------------------
------------------------------------------------
function HandleRemoveCommand(Split, Player)
	if Split[2] == nil then -- check if the player gave a radius
		Player:SendMessage(cChatColor.Rose .. "Too few arguments.\n/remove <type>")
		return true
	end
	Entitys = 0
	if string.upper(Split[2]) == "ITEMS" then -- check if the plugin has to destroy pickups
		local LoopEntity = function(Entity)
			if Entity:IsPickup() then -- if the entity is a pickup then destroy it.
				Entity:Destroy()
				Entitys = Entitys + 1
			end
		end
		Player:GetWorld():ForEachEntity(LoopEntity)
	elseif string.upper(Split[2]) == "MINECARTS" then -- check if the plugin needs to destroy minecarts
		local LoopEntity = function(Entity)
			if Entity:IsMinecart() then -- if the entity is a minecart then destroy it 
				Entity:Destroy()
				Entitys = Entitys + 1
			end
		end
		Player:GetWorld():ForEachEntity(LoopEntity)	
	else
		Player:SendMessage(cChatColor.Rose .. "Acceptable types: items, minecarts") -- the entity that the player wants to destroy does not exist.
		return true
	end
	Player:SendMessage(cChatColor.LightPurple .. "Marked " .. Entitys .. " entit(ies) for removal.")
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
	Cuboid = cCuboid()
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
