#!/Library/Frameworks/LuaCocoa.framework/Versions/Current/Tools/luacocoa
--[[
Simple Scripting Bridge example using Xcode 3 to demonstrate automated building and running.
--]]

LuaCocoa.import("ScriptingBridge")
LuaCocoa.import("Foundation")

-- Not finding through scripting bridge, so adding here
kAEDefaultTimeout = -1
kNoTimeOut = -2

-- TODO: Add better 10.6 error handling. 
-- http://developer.apple.com/library/mac/#releasenotes/ScriptingAutomation/RN-ScriptingBridge/_index.html

function GetURLFromFileAndPath(file_name)
	local current_working_directory = NSFileManager:defaultManager():currentDirectoryPath()

	local file_string = NSString:stringWithUTF8String_(file_name):stringByExpandingTildeInPath():stringByStandardizingPath()
	if not file_string:isAbsolutePath() then
		file_string = current_working_directory:stringByAppendingPathComponent_(file_string):stringByStandardizingPath()
	end
	--print("file_string", file_string)

	local ns_url = NSURL:URLWithString_(file_string:stringByAddingPercentEscapesUsingEncoding_(NSUTF8StringEncoding))
	--print("ns_url", ns_url)

	return ns_url
end

local xcode_application = SBApplication:applicationWithBundleIdentifier_("com.apple.Xcode")

if xcode_application ~= nil then
	-- arg[0] is the script name
	-- arg[1] is either 'os' or 'simulator'
	-- negative index values represent arguments that come before the script
	-- we only want the arguments after the script name
	-- so use a numeric for
	local file_to_open = arg[1] or "MySampleProject.xcodeproj"
	local url_to_open = GetURLFromFileAndPath(file_to_open)
	local xcode_document = xcode_application:open(url_to_open)
	
	local simulator_or_device = arg[2] or "os"

	-- The sample project has "Debug" and "Release" configurations to choose from.
	local build_configuration_type = "Release"

	--[[
	local all_documents = xcode_application:projects()

	print(all_documents, #all_documents)
	for i=1, #all_documents do
		local a_doc = all_documents[i]
		print("doc", a_doc)
	end
	--]]
	
	-- I'm assuming that the document we just opened becomes the activeProjectDocument
	local active_project_document = xcode_application:activeProjectDocument()
	print("active_project", active_project_document, active_project_document:name(), active_project_document:path())


	local xcode_project = active_project_document:project()
	print(xcode_project, xcode_project:name())


	-- This could be a problem: activeSDK() is nil. Looks like an Apple bug.
	-- Hmmm, Sometimes it works. I don't understand this.
	-- iphoneos4.2
	-- iphonesimulator4.2
	print("activeSDK", xcode_project:activeSDK())
	local active_sdk = tostring(xcode_project:activeSDK())
	print("active_sdk", active_sdk)
	
	if not string.match(active_sdk, simulator_or_device) then
		if "simulator" == simulator_or_device then
			local sdk = string.gsub(active_sdk, "os", "simulator")
			print("sdk", sdk)
			xcode_project:setActiveSDK(sdk)
		else
			local sdk = string.gsub(active_sdk, "simulator", "os")
			print("sdk", sdk)
			xcode_project:setActiveSDK(sdk)
		end
		print("changed activeSDK", xcode_project:activeSDK())
	end


	-- I don't think we need to worry about setting the architexture since we build Universal (fat)
	-- However, have seen Xcode get into weird states when switching between simulator and device.
	-- Sometimes you need to set this and verify you actually changed it.
--	xcode_project:setActiveArchitecture("armv7")
--	xcode_project:setActiveArchitecture("i386")
--	print("activeArchitecture", xcode_project:activeArchitecture())


	-- I'm unclear on buildConfigurations vs buildConfigurationTypes
	-- I don't think we need to use buildConfigurations
	--[[
	local array_of_build_configurations = xcode_project:buildConfigurations()
	for i=1, #array_of_build_configurations do
		print("buildConfigurations[:".. tostring(i) .. "]" ..  array_of_build_configurations[i]:name())
	end
	--]]
	
	-- Get the list of build configuration types and then hunt for the one I want.	
	local array_of_build_configuration_types = xcode_project:buildConfigurationTypes()
	local desired_build_configuration_type = nil
	for i=1, #array_of_build_configuration_types do
		print("buildConfigurationType[".. tostring(i) .. "]" ..  array_of_build_configuration_types[i]:name())
		-- Xcode is acting weird. It seems to overwrite entries and replace them, but I don't think it is actually
		-- replacing them. We need to pick the right element.
		-- For us, Release is the 2nd position, not the first.
		if tostring(array_of_build_configuration_types[i]:name()) == tostring(build_configuration_type) then
			desired_build_configuration_type =  array_of_build_configuration_types[i]
		end
	end



	--print("config type", xcode_project:activeBuildConfigurationType():name())

	-- Find out what the current (active) configuration is set to and change it if necessary	
	-- You are not allowed to create a new instance of XcodeBuildConfigurationType
	-- Instead, you must use an object returned from the system.
	-- It appears you cannot use copy or mutableCopy as they throw exceptions.
--	XcodeBuildConfigurationType = NSClassFromString("XcodeBuildConfigurationType")
--	local build_configuration_type = XcodeBuildConfigurationType:alloc():init()
--	copy and mutableCopy throw exceptions
	local active_build_configuration_type = xcode_project:activeBuildConfigurationType()
	if active_build_configuration_type ~= desired_build_configuration_type then
		print("desired_build_configuration_type", desired_build_configuration_type)
		xcode_project:setActiveBuildConfigurationType_(desired_build_configuration_type)
	end
	-- Calling name() sometimes fails and crashes Xcode 3.2.6
--	print("config type", xcode_project:activeBuildConfigurationType():name())



	local array_of_targets = xcode_project:targets()
	local active_target = xcode_project:activeTarget()
	for i=1, #array_of_targets do
		print("targets[".. tostring(i) .. "]" ..  array_of_targets[i]:name())
		-- Watch out: __eq (==) always returns false for different types. 
		local the_name = array_of_targets[i]:name()
		if tostring(the_name) == "OpenGLES2" then
			active_target = array_of_targets[i]
		end
	end
	xcode_project:setActiveTarget_(active_target)

	print("ActiveTarget:", xcode_project:activeTarget():name())



	local array_of_executables = xcode_project:executables()
	for i=1, #array_of_executables do
		print("executables[".. tostring(i) .. "]" ..  array_of_executables[i]:name())
	end

	local active_executable = xcode_project:activeExecutable()
	print(active_executable, active_executable:name())
	active_executable:setName_("OpenGLES2")

	print("ActiveExecutable:", xcode_project:activeExecutable():name())

	

	-- Xcode building can take a long time. We don't want Scripting Bridge
	-- to timeout and move along before the build finishes.
	-- So disable the timeout.
	xcode_application:setTimeout_(kNoTimeOut)
	-- Build the project
	ret_string = xcode_project:buildStaticAnalysis_transcript_using_(false, false, desired_build_configuration_type)

--	local build_configuration_type = 

	print(ret_string)
	print("launching...")
	-- Refetch the object just in case since we tried changing it
	active_executable = xcode_project:activeExecutable()
	

	-- launch() doesn't seem to actually work. We must use debug()
--	local ret_string = active_executable:launch()
	-- calling debug() seems to hang and never return even when the app exits.
	-- We probably want the timeout.
	xcode_application:setTimeout_(kAEDefaultTimeout)
	local ret_string = active_executable:debug()
	print(ret_string)


else
	print("Xcode not available")
end


