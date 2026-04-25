local dragging = false
local dragWindow = nil
local dragOffset = nil

local eventtap = hs.eventtap
local mouse = hs.mouse
local window = hs.window

local dragger = eventtap.new(
	{ eventtap.event.types.leftMouseDown, eventtap.event.types.leftMouseDragged, eventtap.event.types.leftMouseUp },
	function(e)
		local eventType = e:getType()
		local mods = eventtap.checkKeyboardModifiers()
		local pos = mouse.getAbsolutePosition()

		if mods["cmd"] and mods["ctrl"] then
			if eventType == eventtap.event.types.leftMouseDown then
				dragWindow = window.frontmostWindow()
				if dragWindow then
					local frame = dragWindow:frame()
					dragOffset = { x = pos.x - frame.x, y = pos.y - frame.y }
					dragging = true
				end
			elseif eventType == eventtap.event.types.leftMouseDragged and dragging and dragWindow then
				dragWindow:setTopLeft({ x = pos.x - dragOffset.x, y = pos.y - dragOffset.y })
			elseif eventType == eventtap.event.types.leftMouseUp and dragging then
				dragging = false
				dragWindow = nil
				dragOffset = nil
			end
		end
	end)

dragger:start()
