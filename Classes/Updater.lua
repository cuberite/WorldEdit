
-- Updater.lua

-- Contains the cUpdater class used to CheckForNewerVersion if there is a newer version of WorldEdit available




cUpdater = {}




cUpdater.s_CheckAttempts = 0
cUpdater.s_DownloadAttempts = 0




function cUpdater:CheckForNewerVersion()
	if (cUpdater.s_CheckAttempts > g_Config.Updates.NumAttempts) then
		LOGWARNING("Could not connect to Github to check for a newer version for WorldEdit")
		return;
	end
	cUpdater.s_CheckAttempts = cUpdater.s_CheckAttempts + 1;

	cUrlClient:Get("https://raw.githubusercontent.com/cuberite/WorldEdit/master/Info.lua",
		function(a_Body, a_Data)
			if (a_Body) then
				cUpdater:ParsePluginInfo(a_Body)
			else
				-- The request failed, schedule a retry
				cRoot:Get():GetDefaultWorld():QueueTask(
					function()
						cUpdater:CheckForNewerVersion()
					end
				)
			end
		end
	)
end





function cUpdater:DownloadLatestVersion(a_DisplayVersion)
	if (cUpdater.s_DownloadAttempts > g_Config.Updates.NumAttempts) then
		LOGWARNING("Error while downloading newer worldedit version")
		return
	end
	cUpdater.s_DownloadAttempts = cUpdater.s_DownloadAttempts + 1;

	cUrlClient:Get("https://raw.githubusercontent.com/cuberite/WorldEdit/zip/master",
		function (a_Body, a_Data)
			if (not a_Body or (a_Body:len() ~= tonumber(a_Data["Content-Length"]))) then
				-- Downloading failed, schedule a retry
				cRoot:Get():GetDefaultWorld():QueueTask(
					function()
						cUpdater:DownloadLatestVersion(a_DisplayVersion)
					end
				)
				return
			end

			-- Write the ZIP data to the file. The filename looks like this: "WorldEdit v<DisplayVersion>.zip"
			local ZipFile = assert(io.open("Plugins/WorldEdit v" .. a_DisplayVersion .. ".zip", "wb"), "Failed to open \"Plugins/WorldEdit v" .. (a_DisplayVersion or "_Unknown") .. ".zip\"")
			ZipFile:write(a_Body)
			ZipFile:close()

			LOGINFO(string.format("New WorldEdit version downloaded to %q", "Plugins/WorldEdit v" .. a_DisplayVersion .. ".zip"))
		end
	)
end





function cUpdater:ParsePluginInfo(a_PluginInfo)
	local Func, ErrMsg = loadstring(a_PluginInfo)
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

	LOGINFO("There is a newer WorldEdit version available: v" .. Env.g_PluginInfo.DisplayVersion)
	if (not g_Config.Updates.DownloadNewerVersion) then
		return
	end

	cUpdater:DownloadLatestVersion(Env.g_PluginInfo.DisplayVersion)
end
