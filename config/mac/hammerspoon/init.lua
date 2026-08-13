-- Existing stuff
require "window_drag"

-- Modifier aliases.  Karabiner maps the keyboard's Windows key to macOS Alt.
local alt = { "alt" }
local alt_shift = { "alt", "shift" }
local ctrl_alt_shift = { "ctrl", "alt", "shift" }
local hyper = { "cmd", "alt", "ctrl" }
local hyper_shift = { "cmd", "alt", "ctrl", "shift" }

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
hs.hotkey.bind(alt, "I", function()
	sh([[open -na "Firefox" --args --new-window]])
end)

hs.hotkey.bind(alt, "C", function()
	sh([[open -na "Firefox" --args --new-window "https://calendar.google.com/calendar/"]])
end)

hs.hotkey.bind(alt, "E", function()
	sh([[open -na "Firefox" --args --new-window "https://mail.google.com/mail/"]])
end)

-- Chrome
hs.hotkey.bind(alt_shift, "I", function()
	sh([[open -na "Google Chrome" --args --new-window]])
end)

hs.hotkey.bind(ctrl_alt_shift, "C", function()
	sh([[open -na "Google Chrome" --args --new-window "https://calendar.google.com/calendar/"]])
end)

hs.hotkey.bind(alt_shift, "E", function()
	sh([[open -na "Google Chrome" --args --new-window "https://mail.google.com/mail/"]])
end)

-- ChatGPT
hs.hotkey.bind(alt_shift, "H", function()
	sh([[open -a "ChatGPT"]])
end)

-- Claude
hs.hotkey.bind(alt, "H", function()
	sh([[open -a "Claude"]])
end)



-- GUI Editor
hs.hotkey.bind(alt, "G", function()
	hs.alert.show("Opening Vimr")
	sh([[open -a VimR]])
end)

-- Terminals
hs.hotkey.bind(alt, "X", function()
	sh([[open -a "kitty"]])
end)

hs.hotkey.bind(alt_shift, "X", function()
	sh([[open -na "kitty"]])
end)

-- Quick TODO overlay
local TODO_OVERLAY_TITLE = "TODO Overlay"
local ALACRITTY_BIN = "/Applications/Alacritty.app/Contents/MacOS/alacritty"
local ALACRITTY_BUNDLE_ID = "org.alacritty"
local NVIM_BIN = "/opt/homebrew/bin/nvim"
local todoOverlayTask
local todoOverlayWindowRef

local function todoOverlayWindow()
	if todoOverlayWindowRef and todoOverlayWindowRef:title() == TODO_OVERLAY_TITLE then
		return todoOverlayWindowRef
	end

	-- Alacritty's process name is lowercase ("alacritty"), so match by
	-- bundle ID instead of app name (window filters key off app name).
	for _, app in ipairs(hs.application.applicationsForBundleID(ALACRITTY_BUNDLE_ID)) do
		for _, window in ipairs(app:allWindows()) do
			if window:title() == TODO_OVERLAY_TITLE then
				return window
			end
		end
	end
end

local function positionTodoOverlay(window)
	local screen = window:screen()
	local frame = screen:frame()

	local width = math.floor(frame.w * 0.4)
	local height = math.floor(frame.h * 0.6)

	window:setFrame({
		x = frame.x + math.floor((frame.w - width) / 2),
		-- right below the menu bar with a little buffer (20)
		y = frame.y + 20,
		w = width,
		h = height,
	})
end

local function toggleTodoOverlay()
	local window = todoOverlayWindow()
	if window then
		if window:isVisible() then
			window:application():hide()
		else
			window:application():unhide()
			window:focus()
		end
		return
	end

	local todoFile = home .. "/work/TODO.md"
	todoOverlayTask = hs.task.new(ALACRITTY_BIN, nil, {
		"--title",
		TODO_OVERLAY_TITLE,
		"-o",
		"window.dynamic_title=false",
		"-e",
		NVIM_BIN,
		todoFile,
	})
	todoOverlayTask:start()

	-- Alacritty starts asynchronously; poll briefly for its new window.
	local attempts = 0
	local timer
	timer = hs.timer.doEvery(0.1, function()
		attempts = attempts + 1
		local newWindow = todoOverlayWindow()
		if not newWindow and todoOverlayTask then
			local application = hs.application.get(todoOverlayTask:pid())
			if application then
				newWindow = application:allWindows()[1]
			end
		end
		if newWindow then
			todoOverlayWindowRef = newWindow
			timer:stop()
			positionTodoOverlay(newWindow)
			newWindow:focus()
		end
		if attempts >= 20 then
			timer:stop()
		end
	end)
end

hs.hotkey.bind(alt, "T", toggleTodoOverlay)

----------------------------------------------------------------------
-- 🎵 Media Controls  (via your run-osascript helpers)
----------------------------------------------------------------------

-- local SPOTIFY = "/opt/homebrew/bin/spotify_player"
--
-- local function sp_playback(cmd)
-- 	hs.execute(SPOTIFY .. " playback " .. cmd)
-- end
--
-- local function sp(cmd)
-- 	hs.execute(SPOTIFY .. " " .. cmd)
-- end
--
-- -- Play / Pause (Alt + P)
-- hs.hotkey.bind({ "alt" }, "P", function()
-- 	sp_playback("play-pause")
-- end)
--
-- -- Next track (your right bracket keycode)
-- hs.hotkey.bind({ "alt" }, 0x1E, function()
-- 	sp_playback("next")
-- end)
--
-- -- Previous track (your left bracket keycode)
-- hs.hotkey.bind({ "alt" }, 0x21, function()
-- 	sp_playback("previous")
-- end)
--
-- -- toggle like/un
-- hs.hotkey.bind({ "alt" }, "L", function()
-- 	sp("like")
-- end)

-- -- Shuffle toggle (Alt + Shift + S)
-- hs.hotkey.bind({ "alt", "shift" }, "S", function()
-- 	sp("shuffle")
-- end)
--
-- -- Repeat cycle (Alt + Shift + R)
-- hs.hotkey.bind({ "alt", "shift" }, "R", function()
-- 	sp("repeat")
-- end)

-- -- Volume up (Alt + =)
-- hs.hotkey.bind({ "alt" }, "=", function()
-- 	sp("volume 5")
-- end)
--
-- -- Volume down (Alt + -)
-- hs.hotkey.bind({ "alt" }, "-", function()
-- 	sp("volume -5")
-- end)

-- SPOTIFY

-- Spotify
hs.hotkey.bind(alt, "P", function()
	run_osascript("spotify-playpause")
end)

-- Previous track
hs.hotkey.bind(alt, 0x21, function()
	run_osascript("spotify-prev-track")
end)

-- Next track
hs.hotkey.bind(alt, 0x1E, function()
	run_osascript("spotify-next-track")
end)

-- VOLUME

-- Volume down
hs.hotkey.bind(alt, 0x19, function()
	run_osascript("volume-down")
end)

-- Volume up
hs.hotkey.bind(alt, 0x1D, function()
	run_osascript("volume-up")
end)

-- Volume mute toggle
hs.hotkey.bind(alt, 0x1B, function()
	run_osascript("volume-mute-toggle")
end)

----------------------------------------------------------------------
-- 🧰 System Actions
----------------------------------------------------------------------

-- Edit this Hammerspoon config (replaces skhdrc edit binding)
hs.hotkey.bind(hyper_shift, "K", function()
	run_gvim(home .. "/dotfiles/config/hammerspoon/init.lua")
end)

-- reload Hammerspoon
hs.hotkey.bind(alt_shift, "U", function()
	hs.reload()
end)

-- Close window gently
hs.hotkey.bind(alt_shift, "W", function()
	run_osascript("close-window-gently")
end)

-- Optional: Close harsh – you had same script, so same binding
hs.hotkey.bind(alt_shift, "C", function()
	run_osascript("close-window-gently")
end)

-- Sleep / Power
hs.hotkey.bind(hyper_shift, "S", function()
	sh([[pmset sleepnow]])
end)

hs.hotkey.bind(hyper_shift, "P", function()
	run_osascript("system-shutdown")
end)

hs.hotkey.bind(hyper_shift, "R", function()
	run_osascript("system-restart")
end)

----------------------------------------------------------------------
-- 🧰 Existing Script Chooser (shift+alt+O from your init.lua)
----------------------------------------------------------------------

hs.hotkey.bind(alt_shift, "O", function()
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
