-------------------------------------------------
--------------------WORLDEDIT--------------------
-------------------------------------------------
function HandleWorldEditCommand( Split, Player )
	if Split[2] == nil then
		Player:SendMessage( cChatColor.Rose .. "/we <help:reload:version>" )
	elseif string.upper( Split[2] ) == "VERSION" or string.upper(Split[2]) == "VER" then -- check if the player wants to get the version of the plugin
		Player:SendMessage( cChatColor.LightPurple .. "This is version " .. PLUGIN:GetVersion() )
	elseif string.upper( Split[2] ) == "RELOAD" then -- check if the player wants to reload the plugin
		if Player:HasPermission("worldedit.reload") or Player:HasPermission("worldedit.*") then
			Player:SendMessage( cChatColor.LightPurple .. "Worldedit is reloading" )
			PluginManager:DisablePlugin( PLUGIN:GetName() ) -- disable the plugin
			DisablePlugin = true -- make sure the plugin loads again ;)
		end
	elseif string.upper( Split[2] ) == "HELP" then -- check if the player wants to know all the commands.
		if Player:HasPermission("worldedit.help") or Player:HasPermission("worldedit.*") then
			local EachCommand = function( Command ) 
				local Start, End = string.find( PluginManager:GetCommandPermission( Command ), "worldedit" )
				if Start == 1 and End == 9 then -- check if the command is from this plugin
					table.insert( CommandList, Command ) -- insert command into the CommandList table
				end
			end
			CommandList = {} -- create/clear the CommandList table
			PluginManager:ForEachCommand( EachCommand ) -- for each command do the local function EachCommand
			Player:SendMessage( cChatColor.LightPurple .. table.concat( CommandList, ", " ) ) -- give the player a message with the commands split by  ", "
		end
	else
		Player:SendMessage( cChatColor.Rose .. "/we <help:reload:version>" ) -- command not found
	end
	return true
end


------------------------------------------------
----------------------WAND----------------------
------------------------------------------------
function HandleWandCommand( Split, Player )
	Item = cItem( Wand, 1 ) -- create the cItem object
	if( Player:GetInventory():AddItem( Item ) == true ) then -- check if the player got the item
		Player:SendMessage( cChatColor.Green .. "You have a wooden axe now." )
	else
		Player:SendMessage( cChatColor.Green .. "Not enough inventory space" )
	end
	return true
end









