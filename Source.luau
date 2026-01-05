local BaseScriptProperties = {
	"Disabled",
	"Enabled",
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
		if success and value == Enum.RunContext.Legacy then
			PropertyMap.Script = { "Disabled", "Enabled", "RunContext" }
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
	local lines = {}
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

return {
	PropertyMap,
	get_properties,
	get_class_chain,
	extract_properties
}
