
-- PlayerState.lua

-- Implements the cPlayerState object, representing the full information that is remembered per player
-- Also implements the GetPlayerState() function for retrieving / initializing the player state





--- The dict-table of player states.
--[[
Each player has an entry in this dictionary, indexed by the player's Key.
The player name has been chosen as the Key, this means that multiple players of the same name
share their state and the state is global for all worlds.
Each entry is a cPlayerState class instance
--]]
local g_PlayerStates = {}





--- Class for storing the player's state
local cPlayerState = {}





--- Creates a new PlayerState object
function cPlayerState:new(a_Obj, a_PlayerKey, a_Player)
	assert(a_PlayerKey ~= nil)
	assert(a_Player ~= nil)
	
	a_Obj = a_Obj or {}
	setmetatable(a_Obj, cPlayerState)
	self.__index = self
	
	-- Initialize the object members to their defaults:
	local ClientHandle = a_Player:GetClientHandle()
	a_Obj.Clipboard = cClipboard:new()
	if (ClientHandle ~= nil) then
		a_Obj.IsWECUIActivated = ClientHandle:HasPluginChannel("WECUI")
	end
	a_Obj.PlayerKey = a_PlayerKey
	a_Obj.Selection = cPlayerSelection:new({}, a_Obj)
	a_Obj.UndoStack = cUndoStack:new({}, 10, a_Obj)  -- TODO: Settable Undo depth (2nd param)
	a_Obj.WandActivated = true
	
	return a_Obj
end





--- Calls the specified callback with the cPlayer instance of the player to whom this state belongs
-- Returns true if the callback has been called, false otherwise
function cPlayerState:DoWithPlayer(a_Callback)
	local HasCalled = false
	cRoot:Get():ForEachPlayer(
		function(a_Player)
			if (a_Player:GetName() == self.PlayerKey) then
				HasCalled = true
				a_Callback(a_Player)
				return true
			end
		end
	)
	return HasCalled
end





--- Loads the state from persistent storage (if so configured)
function cPlayerState:Load()
	-- TODO
end





--- Pushes one level of Undo onto the Undo stack, by cloning the BlockArea within the Selection
-- a_World is the cWorld where the selection is being copied, a_UndoName is a user-visible name that can be listed
function cPlayerState:PushUndoInSelection(a_World, a_UndoName)
	-- Read the BlockArea:
	local Area = cBlockArea()
	local MinX, MaxX = self.Selection:GetXCoordsSorted()
	local MinY, MaxY = self.Selection:GetYCoordsSorted()
	local MinZ, MaxZ = self.Selection:GetZCoordsSorted()
	Area:Read(a_World, MinX, MaxX, MinY, MaxY, MinZ, MaxZ)
	
	-- Push the Undo onto the stack:
	self.UndoStack:PushUndo(a_World, Area, a_UndoName)
end





--- Saves the state to persistent storage (if so configured)
function cPlayerState:Save()
	-- TODO
end





--- Returns a PlayerState object for the specified Player
-- Creates one if it doesn't exist yet
function GetPlayerState(a_Player)
	assert(tolua.type(a_Player) == "cPlayer")
	
	local Key = a_Player:GetName()
	local res = g_PlayerStates[Key]
	if (res ~= nil) then
		return res
	end
	
	-- The player state doesn't exist yet, create a new one:
	res = cPlayerState:new({}, Key, a_Player)
	g_PlayerStates[Key] = res
	res:Load()
	
	return res
end





local function OnPlayerDestroyed(a_Player)
	-- Allow the player state to be saved to a persistent storage:
	local State = g_PlayerStates[a_Player:GetName()]
	if (State == nil) then
		return false
	end
	State:Save()

	-- Remove the player state altogether:
	g_PlayerStates[a_Player:GetName()] = nil
end





--- Common code to set selection position based on player clicking somewhere
local function SetPos(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_SetFn, a_PosName)
	-- Check if a valid click:
	if (a_BlockFace == BLOCK_FACE_NONE) then
		return false
	end
	
	-- Check if a wand is used:
	if (a_Player:GetEquippedItem().m_ItemType ~= Wand) then
		return false
	end
	
	-- Check the WE permission:
	if not(a_Player:HasPermission("worldedit.selection.pos")) then
		return false
	end
	
	-- Check the wand activation state:
	local State = GetPlayerState(a_Player)
	if not(State.WandActivated) then
		return false
	end
	
	-- When shift is pressed, use the air block instead of the clicked block:
	if (a_Player:IsCrouched()) then
		a_BlockX, a_BlockY, a_BlockZ = AddFaceDirection(a_BlockX, a_BlockY, a_BlockZ, a_BlockFace)
	end
	
	-- Set the position in the internal representation:
	a_SetFn(State.Selection, a_BlockX, a_BlockY, a_BlockZ)
	
	-- Send a success message to the player:
	a_Player:SendMessage(cChatColor.LightPurple .. a_PosName .. " position set to {" .. a_BlockX .. ", " .. a_BlockY .. ", " .. a_BlockZ .. "}.")
	
	return true
end





local function OnPlayerRightClick(Player, BlockX, BlockY, BlockZ, BlockFace, CursorX, CursorY, CursorZ)
	return SetPos(Player, BlockX, BlockY, BlockZ, BlockFace, cPlayerSelection.SetSecondPoint, "Second")
end





local function OnPlayerLeftClick(Player, BlockX, BlockY, BlockZ, BlockFace, Action)
	if ((Action ~= DIG_STATUS_STARTED) and (Action ~= DIG_STATUS_FINISHED)) then
		return false
	end
	return SetPos(Player, BlockX, BlockY, BlockZ, BlockFace, cPlayerSelection.SetFirstPoint, "First")
end





local function OnPluginMessage(a_Client, a_Channel, a_Message)
	if (a_Channel ~= "REGISTER") then
		return
	end
	
	-- The client has registered for some channels, if they did register for WECUI, send the selection to them:
	-- Find the cPlayer object for this client, if available:
	local Player = a_Client:GetPlayer()
	if (Player == nil) then
		return
	end
	
	-- Send the selection (if there is one):
	local State = GetPlayerState(Player)
	State.IsWECUIActivated = a_Client:HasPluginChannel("WECUI")
	State.Selection:NotifySelectionChanged()
end





-- Register the hooks needed:
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_DESTROYED,   OnPlayerDestroyed)
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_RIGHT_CLICK, OnPlayerRightClick)
cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_LEFT_CLICK,  OnPlayerLeftClick)
cPluginManager.AddHook(cPluginManager.HOOK_PLUGIN_MESSAGE,     OnPluginMessage)




