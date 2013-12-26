function RegisterCallback(a_Plugin, a_FunctionName, a_World)
	table.insert(ExclusionArea[a_World:GetName()], {Plugin = a_Plugin, FunctionName = a_FunctionName})
end