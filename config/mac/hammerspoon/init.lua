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



-- Terminals
hs.hotkey.bind(alt, "X", function()
	sh([[open -a "kitty"]])
end)

hs.hotkey.bind(alt_shift, "X", function()
	sh([[open -na "kitty"]])
end)

----------------------------------------------------------------------
-- 🪟 Floating overlay apps (toggle-able, positioned scratch windows)
----------------------------------------------------------------------
--
-- Uses a dedicated Alacritty clone (~/Applications/AlacrittyFloat.app,
-- bundle id "org.alacritty.floating") so that ONLY windows launched
-- through this helper float in Amethyst — regular Alacritty windows
-- keep tiling normally. See amethyst.yml's `floating:` list, which
-- whitelists "org.alacritty.floating" (not "org.alacritty").
local NVIM_BIN = "/opt/homebrew/bin/nvim"
local ALACRITTY_FLOAT_BIN = home .. "/Applications/AlacrittyFloat.app/Contents/MacOS/alacritty"
local ALACRITTY_FLOAT_BUNDLE_ID = "org.alacritty.floating"

-- Builds a toggle function for a floating scratch terminal running a single
-- command, identified by its (unique) window title. Each call returns an
-- independent toggler with its own window/task state, so you can bind many
-- of these to different hotkeys.
--
-- opts, one of:
--   title, args   (string, table)  static window title + alacritty CLI args,
--                                  e.g. args = {"-e", NVIM_BIN, file}
--   launch()      (function)      called fresh each time a NEW window needs
--                                  to be created (not on show/hide of an
--                                  existing one); must return title, args.
--                                  Use this when each cold-launch should get
--                                  distinct state (e.g. a new dated file).
--
-- plus, either way:
--   widthFrac   (number)  fraction of screen width  (default 0.4)
--   heightFrac  (number)  fraction of screen height (default 0.6)
--   yOffset     (number)  px from top of screen, below menu bar (default 20)
local function makeFloatingOverlayToggle(opts)
	local widthFrac = opts.widthFrac or 0.4
	local heightFrac = opts.heightFrac or 0.6
	local yOffset = opts.yOffset or 20

	local task
	local windowRef
	local currentTitle = opts.title

	local function findWindow()
		if not currentTitle then
			return nil
		end
		if windowRef and windowRef:title() == currentTitle then
			return windowRef
		end

		-- Match by bundle ID, not app/process name: Alacritty's process
		-- name is lowercase ("alacritty"), and window filters key off name.
		for _, app in ipairs(hs.application.applicationsForBundleID(ALACRITTY_FLOAT_BUNDLE_ID)) do
			for _, window in ipairs(app:allWindows()) do
				if window:title() == currentTitle then
					return window
				end
			end
		end
	end

	local function positionWindow(window)
		local frame = window:screen():frame()
		local width = math.floor(frame.w * widthFrac)
		local height = math.floor(frame.h * heightFrac)

		window:setFrame({
			x = frame.x + math.floor((frame.w - width) / 2),
			y = frame.y + yOffset,
			w = width,
			h = height,
		})
	end

	return function()
		local window = findWindow()
		if window then
			if window:isVisible() then
				window:application():hide()
			else
				window:application():unhide()
				window:focus()
			end
			return
		end

		local title, args
		if opts.launch then
			title, args = opts.launch()
		else
			title, args = opts.title, opts.args
		end
		currentTitle = title

		task = hs.task.new(ALACRITTY_FLOAT_BIN, nil, {
			"--title",
			title,
			"-o",
			"window.dynamic_title=false",
			table.unpack(args),
		})
		task:start()

		-- Alacritty starts asynchronously; poll briefly for its new window.
		local attempts = 0
		local timer
		timer = hs.timer.doEvery(0.1, function()
			attempts = attempts + 1
			local newWindow = findWindow()
			if not newWindow and task then
				local application = hs.application.get(task:pid())
				if application then
					newWindow = application:allWindows()[1]
				end
			end
			if newWindow then
				windowRef = newWindow
				timer:stop()
				positionWindow(newWindow)
				newWindow:focus()
			end
			if attempts >= 20 then
				timer:stop()
			end
		end)
	end
end

-- Quick TODO overlay (Alt+T)
local toggleTodoOverlay = makeFloatingOverlayToggle({
	title = "TODO Overlay",
	args = { "-e", NVIM_BIN, home .. "/work/TODO.md" },
	widthFrac = 0.4,
	heightFrac = 0.6,
	yOffset = 20,
})

hs.hotkey.bind(alt, "T", toggleTodoOverlay)

-- Scratch pad overlay (Alt+G): each cold-launch creates a fresh, timestamped
-- markdown file so old scratch sessions are never overwritten and stay
-- around to refer back to later.
local SCRATCH_DIR = home .. "/tmp/scratch"

local function newScratchFile()
	hs.execute(string.format("/bin/mkdir -p '%s'", SCRATCH_DIR))
	local stamp = hs.execute("/bin/date '+%Y-%m-%dT%H-%M-%S'"):gsub("%s+$", "")
	local path = SCRATCH_DIR .. "/" .. stamp .. "-scratch.md"
	hs.execute(string.format("/usr/bin/touch '%s'", path))
	return stamp .. "-scratch.md", path
end

local toggleScratchOverlay = makeFloatingOverlayToggle({
	launch = function()
		local title, path = newScratchFile()
		return title, { "-e", NVIM_BIN, path }
	end,
	widthFrac = 0.5,
	heightFrac = 0.7,
	yOffset = 20,
})

hs.hotkey.bind(alt, "G", toggleScratchOverlay)

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
