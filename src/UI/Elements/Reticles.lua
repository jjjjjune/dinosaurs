local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Reticles = {}

local player = game.Players.LocalPlayer

local function getReticle(reticle)
	if player.Team.Name == "Spectators" then return end
	if not CollectionService:HasTag(reticle,player.Team.Name) then
		reticle.Enabled = true
	end
end

function Reticles:start()
	CollectionService:GetInstanceAddedSignal("Reticle"):Connect(getReticle)
	for _,reticle in pairs(CollectionService:GetTagged("Reticle")) do
		getReticle(reticle)
	end
	Messages:hook("CharacterAdded",function()
		if player.Team.Name == "Spectators" then return end
		for _,reticle in pairs(CollectionService:GetTagged("Reticle")) do
			getReticle(reticle)
		end
	end)
end

return Reticles
