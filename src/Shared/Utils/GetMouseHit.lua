local import = require(game.ReplicatedStorage.Shared.Import)
local MobileInput = import "Client/Systems/MobileInput"
local GetDevice = import "Shared/Utils/GetDevice"

local CollectionService = game:GetService("CollectionService")

local ignoreList = {unpack(CollectionService:GetTagged("RayIgnore"))}

CollectionService:GetInstanceAddedSignal("RayIgnore"):Connect(function(instance)
	table.insert(ignoreList,#ignoreList+1,instance)
end)

return function(additionalIgnore)
	local player = game.Players.LocalPlayer

	if player.Character then
		table.insert(ignoreList, player.Character)
	end
	local mouse = player:GetMouse()
	local ray = mouse.UnitRay


	if GetDevice() == "Mobile" then
		ray = MobileInput.getMouseRay()
	end

	local finalIgnore = {}
	for i, v in pairs(ignoreList) do
		table.insert(finalIgnore, v)
	end
	if additionalIgnore then
		for i, v in pairs(additionalIgnore) do
			table.insert(finalIgnore, v)
		end
	end

	local r = Ray.new(ray.Origin, ray.Direction*10000)
	local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(r, finalIgnore)
	return hit, pos, normal
end
