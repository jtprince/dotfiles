require "window_drag"

-- Hotkey to reload Hammerspoon
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "R", function()
	hs.reload()
end)


hs.hotkey.bind({ "shift", "alt" }, "O", function()
	local home = os.getenv("HOME")
	local bin = home .. "/bin"
	local localbin = home .. "/.local/bin"

	-- Resolve symlink for ~/bin
	local resolvePipe = io.popen('readlink "' .. bin .. '"')
	local realBin = bin
	if resolvePipe then
		local resolved = resolvePipe:read("*l")
		if resolved and resolved ~= "" then
			-- Expand relative symlink
			if not resolved:match("^/") then
				realBin = home .. "/" .. resolved
			else
				realBin = resolved
			end
		end
		resolvePipe:close()
	end

	-- Directories to scan
	local binDirs = { realBin, localbin }

	-- Include first-level subdirectories of realBin (not bin symlink)
	local subdirPipe = io.popen('find "' .. realBin .. '" -mindepth 1 -maxdepth 1 -type d 2>/dev/null')
	if subdirPipe then
		for line in subdirPipe:lines() do
			table.insert(binDirs, line)
		end
		subdirPipe:close()
	end

	-- Collect all executables
	local choices = {}
	for _, dir in ipairs(binDirs) do
		local findCmd = 'find "' .. dir .. '" -type f -perm +111 2>/dev/null'
		local p = io.popen(findCmd)
		if p then
			for file in p:lines() do
				local displayName = file
				    :gsub("^" .. realBin .. "/", "") -- pretend ~/bin/
				    :gsub("^" .. localbin .. "/", "") -- pretend ~/.local/bin/
				table.insert(choices, { text = displayName, fullpath = file })
			end
			p:close()
		end
	end

	if #choices == 0 then
		hs.alert.show("No executables found!")
		return
	end

	-- Build the chooser
	local chooser = hs.chooser.new(function(choice)
		if choice then
			hs.execute(choice.fullpath .. " &", true)
		end
	end)

	chooser:choices(choices)
	chooser:placeholderText("Run a script...")
	chooser:show()
end)
