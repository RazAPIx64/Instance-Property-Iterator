local BaseScriptProperties = { --// LocalScript, ModuleScript, Script, BaseScript
	"Disabled",
	"Enabled",
	--"Source",
	--"LinkedSource",
}

local PropertyMap = {
	Instance = {
		"Name",
		"Parent",
		"Archivable",
		"ClassName",
	},

	BasePart = {
		"Position",
		"Size",
		"CFrame",
		"Anchored",
		"CanCollide",
		"Transparency",
		"Color",
		"Material",
		"Velocity",
		"RotVelocity",
		"Reflectance",
	},

	Part = { },
	MeshPart = {
		"MeshId",
		"TextureID",
		"Offset",
	},
	UnionOperation = { },
	Model = {
		"PrimaryPart",
		"WorldPivot",
	},
	Humanoid = {
		"Health",
		"MaxHealth",
		"WalkSpeed",
		"JumpPower",
		"RigType",
		"DisplayName",
		"HipHeight",
	},
	Player = {
		"UserId",
		"Name",
		"DisplayName",
		"Character",
		"Team",
		"Health",
	},
	ScreenGui = {
		"Enabled",
		"IgnoreGuiInset",
		"ResetOnSpawn",
	},
	Frame = {
		"BackgroundColor3",
		"BackgroundTransparency",
		"Size",
		"Position",
		"Visible",
	},
	TextLabel = {
		"Text",
		"TextColor3",
		"TextScaled",
		"TextTransparency",
		"Font",
	},
	TextButton = { },
	ImageLabel = {
		"Image",
		"ImageTransparency",
		"ScaleType",
	},
	ImageButton = { },
	Tool = {
		"Grip",
		"RequiresHandle",
		"CanBeDropped",
	},
	Folder = { },
	Attachment = { "Position", "Orientation" },

	Script = BaseScriptProperties,
	LocalScript = BaseScriptProperties,
	ModuleScript = BaseScriptProperties,
}

local ClassInheritance = {
	BasePart = "Instance",
	Part = "BasePart",
	MeshPart = "BasePart",
	UnionOperation = "BasePart",
	Model = "Instance",
	Humanoid = "Instance",
	Player = "Instance",
	ScreenGui = "Instance",
	Frame = "Instance",
	TextLabel = "Frame",
	TextButton = "TextLabel",
	ImageLabel = "Frame",
	ImageButton = "ImageLabel",
	Tool = "Instance",
	Script = "Instance",
	LocalScript = "Script",
	ModuleScript = "Script",
	Folder = "Instance",
	Attachment = "Instance",
}

local function get_class_chain(instance)
	local classes = {}
	local class = instance.ClassName

	while class do
		table.insert(classes, class)
		class = ClassInheritance[class]
	end

	return classes
end

local function get_properties(instance)
	local props = {}

	if instance.ClassName == "Script" or instance.ClassName == "LocalScript" or instance.ClassName == "ModuleScript" then
		local success, value = pcall(function() return instance.RunContext end)
    --// this is so my shit doesnt get the "Script"'s properties messed up
		if success and value == Enum.RunContext.Legacy then
			PropertyMap.Script = { "Name", "Parent", "Archivable", "RunContext" }
		end
	end

	local classes = get_class_chain(instance)

	for _, class in classes do
		if PropertyMap[class] then
			for i = 1, #PropertyMap[class] do
				local prop = PropertyMap[class][i]
				if pcall(function() return instance[prop] end) then
					props[prop] = instance[prop]
				end
			end
		end
	end

	for name, value in pairs(instance:GetAttributes()) do
		props["attribute->" .. name] = value
	end

	return props
end

local function extract_properties(unextracted_props, indent)
	indent = indent or ""
	local lines: {string} = {}

	for k, v in unextracted_props do
		if type(v) == "table" then
			table.insert(lines, indent .. tostring(k) .. ":")
			table.insert(lines, extract_properties(v, indent .. "  "))
		else
			table.insert(lines, indent .. tostring(k) .. " = " .. tostring(v))
		end
	end

	return table.concat(lines, "\n")
end
