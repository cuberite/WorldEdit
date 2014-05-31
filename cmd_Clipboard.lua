
-- cmd_Clipboard.lua

-- Implements command handlers for the clipboard-related commands




function HandleCopyCommand(a_Split, a_Player)
	-- //copy
	
	-- Get the player state:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "copy")) then
		return
	end
	
	-- Cut into the clipboard:
	local NumBlocks = State.Clipboard:Copy(World, SrcCuboid, Vector3i(a_Player:GetPosition()) - SrcCuboid.p1)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) copied.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandleCutCommand(a_Split, a_Player)
	-- //cut
	
	-- Get the player state:
	local State = GetPlayerState(a_Player)
	if not(State.Selection:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Make a region selection first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local SrcCuboid = State.Selection:GetSortedCuboid()
	local World = a_Player:GetWorld()
	if not(CheckAreaCallbacks(SrcCuboid, a_Player, World, "copy")) then
		return
	end
	
	-- Push an undo snapshot:
	State.UndoStack:PushUndoFromCuboid(World, SrcCuboid, "cut")
	
	-- Cut into the clipboard:
	local NumBlocks = State.Clipboard:Cut(World, SrcCuboid, Vector3i(a_Player:GetPosition()) - SrcCuboid.p1)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) cut.")
	a_Player:SendMessage(cChatColor.LightPurple .. "Clipboard size: " .. State.Clipboard:GetSizeDesc())
	return true
end





function HandlePasteCommand(a_Split, a_Player)
	-- //paste

	-- Check if there's anything in the clipboard:
	local State = GetPlayerState(a_Player)
	if not(State.Clipboard:IsValid()) then
		a_Player:SendMessage(cChatColor.Rose .. "Your clipboard is empty. Use //copy or //cut first.")
		return true
	end
	
	-- Check with other plugins if the operation is okay:
	local DstCuboid = State.Clipboard:GetPasteDestCuboid(a_Player)
	if not(CheckAreaCallbacks(DstCuboid, a_Player, a_Player:GetWorld(), "paste")) then
		return
	end
	
	-- Check for parameters
	local UseOffset = true
	
	for Idx, Parameter in ipairs(a_Split) do
		if (Parameter == "-no") then -- No offset
			UseOffset = false
		end
	end
	
	-- Paste:
	State.UndoStack:PushUndoFromCuboid(a_Player:GetWorld(), DstCuboid, "paste")
	local NumBlocks = State.Clipboard:Paste(a_Player, DstCuboid.p1, UseOffset)
	a_Player:SendMessage(cChatColor.LightPurple .. NumBlocks .. " block(s) pasted relative to you.")
	return true
end





