
-- History.lua

-- Contains all the command handlers in the History category 





function HandleUndoCommand(a_Split, a_Player)
	-- //undo
	
	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Undo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Undo Successful.")
	else
		a_Player:SendMessage(cChatColor.Rose .. "Cannot undo: " .. (Msg or "<unknown error>"))
	end
	return true
end





function HandleRedoCommand(a_Split, a_Player)
	-- //redo
	
	local State = GetPlayerState(a_Player)
	local IsSuccess, Msg = State.UndoStack:Redo(a_Player:GetWorld())
	if (IsSuccess) then
		a_Player:SendMessage(cChatColor.LightPurple .. "Redo Successful.")
	else
		a_Player:SendMessage(cChatColor.Rose .. "Cannot redo: " .. (Msg or "<unknown error>"))
	end
	return true
end




