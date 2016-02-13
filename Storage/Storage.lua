
-- Storage.lua

-- Implements the SQL storage.





-- The current database version. If something changes in the structure of the database or table use this 
local g_CurrentDatabaseVersion = 1





local g_Queries = {}
local QueryPath = cPluginManager:Get():GetCurrentPlugin():GetLocalFolder() .. "/Storage/Queries"
for _, FileName in ipairs(cFile:GetFolderContents(QueryPath)) do
	if (FileName:match("%.sql$")) then
		g_Queries[FileName:match("^(.*)%.sql$")] = cFile:ReadWholeFile(QueryPath .. "/" .. FileName)
	end
end





local g_ChangeScripts = {}
local ChangeScriptPath = cPluginManager:Get():GetCurrentPlugin():GetLocalFolder() .. "/Storage/ChangeScripts"
for _, FileName in ipairs(cFile:GetFolderContents(ChangeScriptPath)) do
	if (FileName:match("%.sql$")) then
		g_ChangeScripts[FileName:match("^(.*)%.sql$")] = cFile:ReadWholeFile(ChangeScriptPath .. "/" .. FileName)
	end
end





cSQLStorage = {}





-- Creates new cSQLStorage object and initializes or updates the database
local function cSQLStorage_new()
	local Obj = {}
	
	setmetatable(Obj, cSQLStorage)
	cSQLStorage.__index = cSQLStorage
	
	local PluginRoot = cPluginManager:Get():GetCurrentPlugin():GetLocalFolder()
	local ErrorCode, ErrorMsg;
	Obj.DB, ErrorCode, ErrorMsg = sqlite3.open(PluginRoot .. "/Storage/storage.sqlite")
	if (Obj.DB == nil) then
		LOGWARNING("Database could not be opened. Aborting");
		error(ErrMsg);  -- Abort the plugin
	end
	
	-- Get the version of the database
	local SavedDatabaseVersion = -1
	Obj:ExecuteStatement("SELECT * FROM sqlite_master WHERE name = 'DatabaseInfo' AND type='table'", nil,
		function()
			-- This function will be called if the "DatabaseInfo" table exists.
			Obj:ExecuteStatement("SELECT `DatabaseVersion` FROM DatabaseInfo", nil,
				function(a_Data)
					SavedDatabaseVersion = a_Data["DatabaseVersion"]
				end
			)
		end
	)
	
	-- Check if the database version is valid or if we should update it.
	if (SavedDatabaseVersion < g_CurrentDatabaseVersion) then
		-- Check if we are allowed to update the database.
		if (g_Config.BackupDatabaseWhenUpdating) then
			-- Only back up the database if the database wasn't just created
			if (SavedDatabaseVersion ~= -1) then
				if (not cFile:IsFolder(PluginRoot .. "/Storage/Backups")) then
					cFile:CreateDirectory(PluginRoot .. "/Storage/Backups")
				end
				
				cFile:Copy(PluginRoot .. "/Storage/storage.sqlite", PluginRoot .. ("/Storage/Backups/storage %s.sqlite"):format(os.date("%Y-%m-%d")))
			end
		end
		
		for I = math.max(SavedDatabaseVersion, 1), g_CurrentDatabaseVersion do
			Obj:ExecuteChangeScript(tostring(I))
		end
	elseif (SavedDatabaseVersion > g_CurrentDatabaseVersion) then
		error("Unknown database version!")
	end
	
	return Obj
end





--- Returns the cSQLStorage singleton object.
-- Creates it first if it doesn't exist yet.
function cSQLStorage:Get()
	if (not cSQLStorage.Storage) then
		cSQLStorage.Storage = cSQLStorage_new()
		
	end
	
	return cSQLStorage.Storage
end






--- Executes a query that was loaded before.
-- The parameters is a dictionary. The key is the name of the parameter. 
-- This can be found with a $ or : in front of it in the actual query.
-- If a callback is given it calls that for each row where the parameter is a dictionary
-- Returns true on success, while it returns false with the error message when failing
function cSQLStorage:ExecuteCommand(a_QueryName, a_Parameters, a_Callback)
	local Command = assert(g_Queries[a_QueryName], "Requested Query doesn't exist")
	local Commands = StringSplit(Command, ";")
	
	for _, Sql in ipairs(Commands) do
		local CommandExecuted, ErrMsg = self:ExecuteStatement(Sql, a_Parameters, a_Callback)
		if (not CommandExecuted) then
			return false, ErrMsg
		end
	end
	
	return true
end





-- Executes a ChangeScript that was loaded before.
-- This is to update the database if something changed in it's structure
function cSQLStorage:ExecuteChangeScript(a_ChangeScriptName)
	local Command = assert(g_ChangeScripts[a_ChangeScriptName], "Requested changescript doesn't exist")
	local Commands = StringSplit(Command, ";")
	for _, Sql in ipairs(Commands) do
		local CommandExecuted, ErrMsg = self:ExecuteStatement(Sql)
		if (not CommandExecuted) then
			return false, ErrMsg
		end
	end
end





--- Executes an SQL statement
-- The parameters is a dictionary. The key is the name of the parameter. 
-- This can be found with a $ or : in front of it in the actual query.
-- If a callback is given it calls that for each row where the parameter is a dictionary
-- Returns true on success, while it returns false with the error message when failing
function cSQLStorage:ExecuteStatement(a_Sql, a_Parameters, a_Callback)
	local Stmt, ErrCode, ErrMsg = self.DB:prepare(a_Sql)
	if (not Stmt) then
		LOGWARNING("Cannot prepare query >>" .. a_Sql .. "<<: " .. (ErrCode or "<unknown>") .. " (" .. (ErrMsg or "<no message>") .. ")")
		return false, ErrorMsg or "<no message>"
	end
	
	if (a_Parameters ~= nil) then
		Stmt:bind_names(a_Parameters)
	end
	
	if (a_Callback ~= nil) then
		for val in Stmt:nrows() do
			if (a_Callback(val)) then
				break
			end
		end
	else
		Stmt:step()
	end
	
	Stmt:finalize()
	return true
end




