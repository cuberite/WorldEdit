local player, arguments =...
table.insert(arguments, 1, "//fill")
local success, res = cCommandParser:new(2)
	:Arguments({
		{ name = "block",  extractor = Extractors.Block},
		{ name = "radius", extractor = Extractors.Number, extractorparameters = {0}},
		{ name = "depth",  extractor = Extractors.Number, optional = true },
	})
	:Flags({
		{ name = 'hollow', character = 'h' },
		{ name = 'fancyname', character = 'o' }
	})
	:Parse(arguments, player)

if (not success) then
	player:SendMessage(cChatColor.Rose .. res)
end
print(success, res)
print("Writing file")
print(cJson:Serialize(arguments))
if (success) then
	print(cJson:Serialize(res))
end