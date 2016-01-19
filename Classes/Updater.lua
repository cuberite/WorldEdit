
-- Updater.lua

-- Contains the cUpdater class used to CheckForNewerVersion if there is a newer version of WorldEdit available




cUpdater = {}




local g_CheckAttempts = 0
local g_DownloadAttempts = 0
local g_ReceivedPluginInfo = ""
local g_LatestVersion = nil
local g_WorldEditZip = nil





local VersionCheckForNewerVersionerCallbacks =
{
	OnConnected = function(a_TCPLink)
		local res, msg = a_TCPLink:StartTLSClient()
		a_TCPLink:Send("GET /cuberite/WorldEdit/master/Info.lua HTTP/1.0\r\nHost: raw.githubusercontent.com\r\n\r\n")
	end,
	
	OnError = function(a_TCPLink, a_ErrorCode, a_ErrorMsg) 
		LOGWARNING("Error while checking for newer WorldEdit version: " .. a_ErrorMsg)
	end,
	
	OnReceivedData = function(a_TCPLink, a_Data)
		g_ReceivedPluginInfo = g_ReceivedPluginInfo .. a_Data
	end,
	
	OnRemoteClosed = function(a_TCPLink)
		cUpdater:ParseResults()
	end,
}





local NewVersionDownloaderCallbacks =
{
	OnConnected = function(a_TCPLink)
		-- Start a secured connection
		local res, msg = a_TCPLink:StartTLSClient("", "", "")
		
		-- Send Request Header
		a_TCPLink:Send("GET /cuberite/WorldEdit/zip/master HTTP/1.0\r\nHost: codeload.github.com\r\nConnection: Keep-alive\r\n\r\n")
		
		-- Clear data we might have from previous attempts
		g_WorldEditZip = ""
	end,
	
	OnError = function(a_TCPLink, a_ErrorCode, a_ErrorMsg)
		if (g_DownloadAttempts < g_Config.Updates.NumAttempts) then
			g_DownloadAttempts = g_DownloadAttempts + 1
			cUpdater:DownloadLatestVersion()
		else
			LOGWARNING("Error while downloading newer worldedit version: " .. a_ErrorCode)
		end
	end,
	
	OnReceivedData = function(a_TCPLink, a_Data)
		-- Append the received Data to the saved data
		g_WorldEditZip = g_WorldEditZip .. a_Data
	end,
	
	OnRemoteClosed = function(a_TCPLink)
		-- Split the data and the headers
		local Header, Data = g_WorldEditZip:match("^(.-)\r\n\r\n(.*)")
		
		-- Parse the headers so we can actually use them to validate the data
		Header = cUpdater:ParseHeaders(Header)
		
		-- Check if the received data size matches that that was expected
		if (Data:len() ~= tonumber(Header["content-length"] or -1)) then
			if (g_DownloadAttempts < g_Config.Updates.NumAttempts) then
				g_DownloadAttempts = g_DownloadAttempts + 1
				cUpdater:DownloadLatestVersion()
			else
				LOGWARNING("Error while downloading newer worldedit version")
			end
			return
		end
		
		-- Write the ZIP data to the file. The filename looks like this: "WorldEdit v<DisplayVersion>.zip"
		local ZipFile = assert(io.open("Plugins/WorldEdit v" .. (g_LatestVersion or "_Unknown") .. ".zip", "wb"), "Failed to open \"Plugins/WorldEdit v" .. (g_LatestVersion or "_Unknown") .. ".zip\"")
		ZipFile:write(Data)
		ZipFile:close()
		
		LOGINFO(string.format("New WorldEdit version downloaded to %q", "Plugins/WorldEdit v" .. (g_LatestVersion or "_Unknown") .. ".zip"))
	end,	
}





function cUpdater:CheckForNewerVersion()
	cNetwork:Connect("raw.githubusercontent.com", 443, VersionCheckForNewerVersionerCallbacks)
end





function cUpdater:DownloadLatestVersion()
	cNetwork:Connect("codeload.github.com", 443, NewVersionDownloaderCallbacks)
end





function cUpdater:ParseResults()
	if (g_ReceivedPluginInfo == "") then
		-- Version info download failed, retry
		if (g_CheckAttempts < g_Config.Updates.NumAttempts) then
			g_CheckAttempts = g_CheckAttempts + 1
			cUpdater:CheckForNewerVersion()
		else
			LOGWARNING("Could not connect to Github to check for a newer version for WorldEdit")
		end
		return
	end
	
	-- Remove the HTTP header
	local Content = g_ReceivedPluginInfo:match("^.-\r\n\r\n(.*)") or ""
	local Func, ErrMsg = loadstring(Content)
	if (not Func) then
		LOGWARNING("Error while checking for newer WorldEdit version")
		return
	end
	
	local Env = {}
	
	-- Protect from malicious code (though this shouldn't be possible)
	setfenv(Func, Env)
	
	-- Execute the code
	Func()
	
	-- Extract the plugin version:
	if (not Env.g_PluginInfo) then
		LOGWARNING("Error while checking for newer WorldEdit version")
		return
	end
	
	if (type(Env.g_PluginInfo.Version) ~= "number") then
		LOGWARNING("Error while checking for newer WorldEdit version")
		return
	end
	
	if (Env.g_PluginInfo.Version <= g_PluginInfo.Version) then
		if (g_Config.Updates.ShowMessageWhenUpToDate) then
			LOGINFO("Your WorldEdit plugin is up-to-date")
		end
		return
	end
	
	g_LatestVersion = Env.g_PluginInfo.DisplayVersion
	LOGINFO("There is a newer WorldEdit version available: v" .. Env.g_PluginInfo.DisplayVersion)
	if (not g_Config.Updates.DownloadNewerVersion) then
		return
	end
	
	cUpdater:DownloadLatestVersion()
end





--- Splits a HTTP header up and saves it in a table as a dictionary
-- The key is always lowercase
function cUpdater:ParseHeaders(a_Headers)
	local Res = {}
	
	-- Go through each line of the header except for the first one.
	local SplittedHeaders = StringSplit(a_Headers, "\n")
	for I = 2, #SplittedHeaders do
		local Header = SplittedHeaders[I]
		local HeaderInfo = StringSplitAndTrim(Header, ":")
		local Name = HeaderInfo[1]:lower()
		local Value = HeaderInfo[2]
		
		Res[Name] = Value
	end
	
	return Res
end





