local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local ServerData = import "Server/Systems/ServerData"

local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local FastSpawn = import "Shared/Utils/FastSpawn"
local GetGateName = import "Shared/Utils/GetGateName"
local GateValidationFunctions = import "Shared/Data/GateValidationFunctions"
local TileRenderer = import "Server/MapRenderComponents/TileRenderer"

local alreadyCheckedTiles = {} -- tiles that have been scanned for gates already

local function createChestForGate(gateModel, tile)
	local savedGates = ServerData:getValue("gates")
	local myGateData = savedGates[tile.Name]
	myGateData.hasCreatedChest = true
	ServerData:setValue("Gates", savedGates)
	local chest = game.ServerStorage.Entities.Chest:Clone()
	chest.Parent = workspace.Entities
	chest:SetPrimaryPartCFrame(gateModel.ChestSpawn.CFrame)
end

local function playOpenGateEffect(gateModel)
	Messages:send("PlaySound", "Rumble", gateModel.PrimaryPart.Position)

	for _, v in pairs(game.Players:GetPlayers()) do
		if v.Character and v.Character.PrimaryPart then
			local dist = (v.Character.PrimaryPart.Position - gateModel.PrimaryPart.Position).magnitude
			if dist < 150 then
				Messages:sendClient(v, "ShakeCamera", "Earthquake")
			end
		end
	end

	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
	local goals = {CFrame = gateModel.BottomPosition.CFrame}
	local tween = TweenService:Create(gateModel.Bottom, tweenInfo, goals)
	tween:Play()

	FastSpawn(function()
		wait(.25)
		goals = {
			CFrame = gateModel.Offering.Base.CFrame * CFrame.new(0,-5,0)
		}
		tween = TweenService:Create(gateModel.Offering.Base, tweenInfo, goals)
		tween:Play()

		goals = {
			CFrame = gateModel.Offering.Bowl.CFrame * CFrame.new(0,-5,0)
		}
		tween = TweenService:Create(gateModel.Offering.Bowl, tweenInfo, goals)
		tween:Play()

		goals = {
			Rate = 0
		}
		tween = TweenService:Create(gateModel.Offering.Base.Sparks, tweenInfo, goals)
		tween:Play()
	end)

end

local function updateGate(gateModel, tile)
	local savedGates = ServerData:getValue("gates")
	local myGateData = savedGates[tile.Name]

	local progressPercent = myGateData.has/myGateData.needed
	local progressBG = gateModel.EyeProgressBG
	local progressFG = gateModel.EyeProgressFG

	progressFG.Size = progressBG.Size

	local goals = {
		CFrame = progressBG.CFrame * CFrame.new(0, (-progressBG.Size.Y) * (1 - progressPercent), .2)
	}

	local tweenInfo = TweenInfo.new(.25, Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
	local tween = TweenService:Create(progressFG, tweenInfo, goals)
	tween:Play()

	if myGateData.has >= myGateData.needed then
		if not myGateData.hasCreatedChest then
			playOpenGateEffect(gateModel)
			createChestForGate(gateModel, tile)
		else
			gateModel.Offering:Destroy()
			gateModel.Bottom.CFrame = gateModel.BottomPosition.CFrame
		end
		if gateModel:FindFirstChild("BlackPart1") then
			gateModel.BlackPart1:Destroy()
		end
	end
end

local function onSacrificedItemToGate(item, gateModel, tile)
	local savedGates = ServerData:getValue("gates")
	local myGateData = savedGates[tile.Name]

	if myGateData.has >= myGateData.needed then
		return
	end

	if not GateValidationFunctions[myGateData.gateType](item) then
		return
	end

	myGateData.has = myGateData.has + 1

	local pos = item.PrimaryPart.Position

	Messages:send("DestroyItem", item)
	Messages:send("PlayParticle", "PurpleDeathSmoke",  10, Vector3.new(pos.X , gateModel.Offering.TouchPart.Position.Y, pos.Z))
	Messages:send("PlaySound", "Burn", pos)

	ServerData:setValue("Gates", savedGates)

	updateGate(gateModel, tile)
end

local function connectEventsForGate(gateModel, tile)
	gateModel.Offering.TouchPart.Touched:connect(function(hit)
		if CollectionService:HasTag(hit.Parent, "Item") and not hit.Parent.Parent:FindFirstChild("Humanoid") then
			onSacrificedItemToGate(hit.Parent, gateModel, tile)
		end
	end)
end

local function createOrLoadGateFromTemplate(gateTemplate, tile)
	local savedGates = ServerData:getValue("gates")

	local yLevel = TileRenderer.getCellYLevelOfPosition(tile.PrimaryPart.Position)

	print("Y LEVEL IS : ", yLevel)

	local gateType = GetGateName(yLevel)
	local needed = 10
	local has = 0
	local hasCreatedChest = false

	if savedGates[tile.Name] then
		gateType = savedGates[tile.Name].gateType
		needed = savedGates[tile.Name].needed
		has = savedGates[tile.Name].has
		hasCreatedChest = savedGates[tile.Name].hasCreatedChest
	end

	local gateModel = game.ServerStorage.Gates[gateType]:Clone()
	gateModel:SetPrimaryPartCFrame(gateTemplate.PrimaryPart.CFrame)
	gateTemplate:Destroy()
	gateModel.Parent = workspace.Gates

	savedGates[tile.Name] = {
		gateType = gateType,
		needed = needed,
		has = has,
		hasCreatedChest = hasCreatedChest,
	}

	ServerData:setValue("Gates", savedGates)

	connectEventsForGate(gateModel, tile)
	updateGate(gateModel, tile)
end

local function checkTileForGates(tile)
	if alreadyCheckedTiles[tile] then
		return
	end
	alreadyCheckedTiles[tile] = true
	for _, v in pairs(tile:GetDescendants()) do
		if CollectionService:HasTag(v, "Gate") then
			createOrLoadGateFromTemplate(v, tile)
		end
	end
end

local function checkTilesForGates()
	for _, tile in pairs(CollectionService:GetTagged("Tile")) do
		checkTileForGates(tile)
	end
end

local Gates = {}

function Gates:start()
	Messages:hook("MapDoneGenerating", checkTilesForGates)
end

return Gates
