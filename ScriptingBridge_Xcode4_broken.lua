#!/Library/Frameworks/LuaCocoa.framework/Versions/Current/Tools/luacocoa
--[[
Simple Scripting Bridge example using iTunes.
Script will launch iTunes (if not already open),
Pause playback (if not already paused),
Start/resume playing,
and print out the name, artist, year of the current track.
--]]

LuaCocoa.import("ScriptingBridge")
LuaCocoa.import("Foundation")

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

local xcode_application = SBApplication:applicationWithBundleIdentifier_("com.apple.dt.Xcode")

if xcode_application ~= nil then
	-- arg[0] is the script name
	-- negative index values represent arguments that come before the script
	-- we only want the arguments after the script name
	-- so use a numeric for
	local file_to_open = arg[1] or "MySampleProject.xcodeproj"
	local url_to_open = GetURLFromFileAndPath(file_to_open)
	local xcode_document = xcode_application:open(url_to_open)


	--[[
	local all_documents = xcode_application:projects()

	print(all_documents, #all_documents)
	for i=1, #all_documents do
		local a_doc = all_documents[i]
		print("doc", a_doc)
	end
	--]]
	
	-- I'm assuming that the document we just opened becomes the activeProjectDocument
	--[[ Broken in Xcode 4
	local active_project_document = xcode_application:activeProjectDocument()
	print("active_project", active_project_document )
	print("active_project name", active_project_document:name())
	print("active_project path", active_project_document:path())
	--]]
	
	NSLog("workspace docs %@", xcode_application:workspaceDocuments())
	local workspace_documents = xcode_application:workspaceDocuments()

	for i=1, #workspace_documents do
		print("workspace_documents " ..  workspace_documents[i]:name())
	end

	local active_workspace_document = xcode_application:activeWorkspaceDocument()
	print("active_workspace_document name", active_workspace_document:name())

	local active_workspace_document_projects = active_workspace_document:projects()
	local xcode_project = nil
	for i=1, #active_workspace_document_projects do
		print("active_workspace_document_projects " ..  active_workspace_document_projects[i]:name())
		if tostring(active_workspace_document_projects[i]:name()) == "ratatouille" then
			xcode_project = active_workspace_document_projects[i]
			print("xcode_project set", xcode_project)
		end
	end

	

	local xcode_project = active_project_document:project()
--	print("xcode project, name ", xcode_project, xcode_project:name())

	local xcode_project_schemes = active_workspace_document:schemes()
NSLog("schemes %@, %d", xcode_project_schemes, xcode_project_schemes:count())
	for i=1, #xcode_project_schemes do
		print("xcode_project_schemes " ..  xcode_project_schemes[i]:name())
	end

	-- This could be a problem: activeSDK() is nil. Looks like an Apple bug.
	--print("activeSDK", xcode_project:activeSDK())
	-- I don't think we need to worry about setting the architexture since we build Universal (fat)
	--print("activeArchitecture", xcode_project:activeArchitecture())

	-- I'm unclear on buildConfigurations vs buildConfigurationTypes
	-- I don't think we need to use buildConfigurations
	--[[
	local array_of_build_configurations = xcode_project:buildConfigurations()
	for i=1, #array_of_build_configurations do
		print("buildConfigurations[:".. tostring(i) .. "]" ..  array_of_build_configurations[i]:name())
	end
	--]]
	
	local array_of_build_configuration_types = xcode_project:buildConfigurationTypes()
	for i=1, #array_of_build_configuration_types do
		print("buildConfigurationType[".. tostring(i) .. "]" ..  array_of_build_configuration_types[i]:name())
	end

	local array_of_executables = xcode_project:executables()
	for i=1, #array_of_executables do
		print("executables[".. tostring(i) .. "]" ..  array_of_executables[i]:name())
	end

	local array_of_targets = xcode_project:targets()
	local active_target = xcode_project:activeTarget()
	for i=1, #array_of_targets do
		print("targets[".. tostring(i) .. "]" ..  array_of_targets[i]:name())
		-- Watch out: __eq (==) always returns false for different types. 
		local the_name = array_of_targets[i]:name()
--		if the_name:isEqualToString_("rttplayer-all") then
		if tostring(the_name) == "rttplayer-all" then
			active_target = array_of_targets[i]
		end
	end
	xcode_project:setActiveTarget_(active_target)

	local build_configuration_type = xcode_project:activeBuildConfigurationType()
	print("config type", xcode_project:activeBuildConfigurationType():name())
--	print("Bypass")
	ret_string = xcode_project:buildStaticAnalysis_transcript_using_(false, false, build_configuration_type)
--	xcode_project:launch()
	print("Bypass2")
	
	active_workspace_document:buildStaticAnalysis_transcript_using_(false, false, build_configuration_type)
--	active_workspace_document:debug()
	do
		return
	end

	--print("config type", xcode_project:activeBuildConfigurationType():name())

	-- You are not allowed to create a new instance of XcodeBuildConfigurationType
	-- Instead, you must use an object returned from the system.
	-- It appears you cannot use copy or mutableCopy as they throw exceptions.
--	XcodeBuildConfigurationType = NSClassFromString("XcodeBuildConfigurationType")
--	local build_configuration_type = XcodeBuildConfigurationType:alloc():init()
--	copy and mutableCopy throw exceptions
	local build_configuration_type = xcode_project:activeBuildConfigurationType()
	build_configuration_type:setName_("Release")
	xcode_project:setActiveBuildConfigurationType_(build_configuration_type)
	print("config type", xcode_project:activeBuildConfigurationType():name())


	local active_executable = xcode_project:activeExecutable()
	print(active_executable, active_executable:name())
	active_executable:setName_("rttplayer-all")

	print("ActiveTarget:", xcode_project:activeTarget():name())
	print("ActiveExecutable:", xcode_project:activeExecutable():name())
	ret_string = xcode_project:buildStaticAnalysis_transcript_using_(false, false, build_configuration_type)

--	local build_configuration_type = 

	print(ret_string)
	print("launching...")
	-- Refetch the object just in case since we tried changing it
	active_executable = xcode_project:activeExecutable()
	
	-- launch() doesn't seem to actually work. We must use debug()
--	local ret_string = active_executable:launch()
	local ret_string = active_executable:debug()
	print(ret_string)


else
	print("Xcode not available")
end


