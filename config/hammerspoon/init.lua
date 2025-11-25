-- Existing stuff
require "window_drag"

-- Convenience alias for your "hyper" chord
local hyper = { "cmd", "alt", "ctrl" }

-- Reload Hammerspoon
hs.hotkey.bind(hyper, "R", function()
	hs.reload()
end)

----------------------------------------------------------------------
-- Small helpers
----------------------------------------------------------------------

local function sh(cmd)
	-- async-ish: don't block on commands
	-- be aware that all calls and subcalls must not rely on PATH
	hs.execute(cmd .. " &", false)
end

local home = os.getenv("HOME")
local run_osascript_bin = home .. "/bin/run-osascript"


local function run_osascript(name)
	sh(run_osascript_bin .. " " .. name)
end

----------------------------------------------------------------------
-- 🏃 Quick Launch Applications  (from skhdrc)
----------------------------------------------------------------------

-- Firefox
hs.hotkey.bind({ "alt" }, "I", function()
	sh([[open -na "Firefox" --args --new-window]])
end)

hs.hotkey.bind({ "alt" }, "C", function()
	sh([[open -na "Firefox" --args --new-window "https://calendar.google.com/calendar/"]])
end)

hs.hotkey.bind({ "alt" }, "E", function()
	sh([[open -na "Firefox" --args --new-window "https://mail.google.com/mail/"]])
end)

-- Chrome
hs.hotkey.bind({ "alt", "shift" }, "I", function()
	sh([[open -na "Google Chrome" --args --new-window]])
end)

hs.hotkey.bind({ "ctrl", "alt", "shift" }, "C", function()
	sh([[open -na "Google Chrome" --args --new-window "https://calendar.google.com/calendar/"]])
end)

hs.hotkey.bind({ "alt", "shift" }, "E", function()
	sh([[open -na "Google Chrome" --args --new-window "https://mail.google.com/mail/"]])
end)

-- ChatGPT
hs.hotkey.bind({ "alt" }, "H", function()
	sh([[open -na "ChatGPT"]])
end)


-- GUI Editor
hs.hotkey.bind({ "alt" }, "G", function()
	hs.alert.show("Opening Vimr")
	sh([[open -na VimR]])
end)

-- Terminals
hs.hotkey.bind({ "alt" }, "X", function()
	sh([[open -na "Alacritty"]])
end)

hs.hotkey.bind({ "alt", "shift" }, "X", function()
	sh([[open -na "kitty"]])
end)

----------------------------------------------------------------------
-- 🎵 Media Controls  (via your run-osascript helpers)
----------------------------------------------------------------------

-- Spotify
hs.hotkey.bind({ "alt" }, "P", function()
	run_osascript("spotify-playpause")
end)

-- Previous track
hs.hotkey.bind({ "alt" }, 0x21, function()
	run_osascript("spotify-prev-track")
end)

-- Next track
hs.hotkey.bind({ "alt" }, 0x1E, function()
	run_osascript("spotify-next-track")
end)

-- Volume down
hs.hotkey.bind({ "alt" }, 0x19, function()
	run_osascript("volume-down")
end)

-- Volume up
hs.hotkey.bind({ "alt" }, 0x1D, function()
	run_osascript("volume-up")
end)

-- Volume mute toggle
hs.hotkey.bind({ "alt" }, 0x1B, function()
	run_osascript("volume-mute-toggle")
end)

----------------------------------------------------------------------
-- 🧰 System Actions
----------------------------------------------------------------------

-- Edit this Hammerspoon config (replaces skhdrc edit binding)
hs.hotkey.bind({ "ctrl", "shift", "alt", "cmd" }, "K", function()
	run_gvim(home .. "/dotfiles/config/hammerspoon/init.lua")
end)

-- Formerly "Restart skhd" – now: reload Hammerspoon
hs.hotkey.bind({ "alt", "shift" }, "U", function()
	hs.reload()
end)

-- Close window gently
hs.hotkey.bind({ "alt", "shift" }, "W", function()
	run_osascript("close-window-gently")
end)

-- Optional: Close harsh – you had same script, so same binding
hs.hotkey.bind({ "alt", "shift" }, "C", function()
	run_osascript("close-window-gently")
end)

-- Sleep / Power
hs.hotkey.bind({ "ctrl", "shift", "alt", "cmd" }, "S", function()
	sh([[pmset sleepnow]])
end)

hs.hotkey.bind({ "ctrl", "shift", "alt", "cmd" }, "P", function()
	run_osascript("system-shutdown")
end)

hs.hotkey.bind({ "ctrl", "shift", "alt", "cmd" }, "R", function()
	run_osascript("system-restart")
end)

----------------------------------------------------------------------
-- 🧰 Existing Script Chooser (shift+alt+O from your init.lua)
----------------------------------------------------------------------

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
				    :gsub("^" .. realBin .. "/", "")
				    :gsub("^" .. localbin .. "/", "")
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
