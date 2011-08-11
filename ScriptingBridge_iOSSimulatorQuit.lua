#!/Library/Frameworks/LuaCocoa.framework/Versions/Current/Tools/luacocoa

LuaCocoa.import("ScriptingBridge")
LuaCocoa.import("Foundation")

-- Not finding through scripting bridge, so adding here
kAEDefaultTimeout = -1
kNoTimeOut = -2

local next_skin = arg[1] or nil

-- The simulator does not have a scripting dictionary. 
-- We must manipulate it through system events.
--local iOSSimulator = SBApplication:applicationWithBundleIdentifier_("com.apple.iphonesimulator")
local system_events = SBApplication:applicationWithBundleIdentifier_("com.apple.systemevents")
system_events:setTimeout_(kNoTimeOut)

--local iOSSimulator = systemEvents:processes():byName_("iPhone Simulator")
local processes = system_events:processes()
local ios_sim_process = nil
for i=1, #processes do
--	print("processes[".. tostring(i) .. "]" ..  processes[i]:name())
	if tostring(processes[i]:name()) == "iPhone Simulator" then
		ios_sim_process = processes[i]
	end
end

if not ios_sim_process then
	print("Could not find iPhone Simulator process running. Aborting...")
	os.exit(1)
end

-- Bring the app to the foreground
ios_sim_process:setFrontmost_(true)

--local menus = ios_sim_process:menuBars()[1]:menus()
local menu_items = ios_sim_process:menuBars()[1]:menus()[2]:menuItems()
local reset_option = nil
local quit_option = nil
--print(menu_items)
for i=1, #menu_items do
--	NSLog("%@", menu_items[i]:title())
	-- Note the ellipses is not 3 dots but Alt-Semicolon
	if  tostring(menu_items[i]:title()) == "Reset Content and Settings…" then
		reset_option = menu_items[i]
	elseif tostring(menu_items[i]:title()) == "Quit iOS Simulator" then
		quit_option = menu_items[i]
	end
end
if not reset_option then
	print("Warning: Could not find 'Reset Content and Settings…', setting to last known index position")
	reset_option = menu_items[3]
end
if not quit_option then
	print("Warning: Could not find 'Quit iOS Simulator', setting to last known index position")
	quit_option = menu_items[7]
end

local ret_val = reset_option:clickAt_(reset_option:position())

-- A confirmation dialog appears and we must hit the correct button.
-- The sleep helps make sure the alert has enough time to show up.
os.execute("sleep 1")
--print(ret_val)

-- This requires that keyboard navigation for buttons is on in Accessibility
system_events:keystroke_using_(" ", 0)


if next_skin == "iphone" then
	next_skin_index = 2
elseif next_skin == "ipad" then
	next_skin_index = 1
elseif next_skin == "iphone4" then
	next_skin_index = 3
end

if next_skin_index then

	--menu_items = ios_sim_process:menuBars()[1]:menus()[5]:menuItems()[1]:menuItems()
	-- Will take us to "Devices"
	menu_items = ios_sim_process:menuBars()[1]:menus()[5]:menuItems()
	local iphone_retina = nil
	--[[
	for i=1, #menu_items do
		NSLog("%@, %@", menu_items[i]:title(), menu_items[i])
	end
	--]]

	-- Can't figure out how to tell if checked
	--[==[ 
	local sub_menu_items = ios_sim_process:menuBars()[1]:menus()[5]:menuItems()[1]:menus()[1]:menuItems()
	for i=1, #sub_menu_items do
		NSLog("%@, %@", sub_menu_items[i]:title(), sub_menu_items[i]:value())
	end
	--]==]

	-- Setting the simulator to iPhone 4 mode via menu Menu->Hardware->Devices->iPhone (Retina) 
	-- This is because our launch tool doesn't have a way to set between iPhone/iPhone4, 
	-- so we leave it as the last user preference.
	iphone_retina = menu_items[1]:menus()[1]:menuItems()[next_skin_index]
	iphone_retina:clickAt_(iphone_retina:position())
end


-- Now quit the simulator via the menu option.
quit_option:clickAt_(quit_option:position())

os.exit(0)

