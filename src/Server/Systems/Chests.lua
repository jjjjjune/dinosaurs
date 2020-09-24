local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local ChestDrops = import "Server/Data/ChestDrops"

local function random(min, max)
    local randomObj = Random.new()
    return randomObj:NextInteger(min, max)
end

local function open(entity)
    local Items = import "Server/Systems/Items"
    local pos = entity.PrimaryPart.Position
    local dropTable = ChestDrops[entity.Type.Value]
    local itemsToMake = {}
    for i, itemTable in pairs(dropTable) do
        if itemTable.min > 0 then
            for i = 1, itemTable.min do
                table.insert(itemsToMake, itemTable.name)
            end
        end
        local remaining = math.random(0, itemTable.max - itemTable.min)
        if remaining > 0 then
            for i = 1, remaining do
                local n = random(1, 100)
                if n < itemTable.chance then
                    table.insert(itemsToMake, itemTable.name)
                end
            end
        end
    end
    for i, itemName in pairs(itemsToMake) do
        local newPos = pos + Vector3.new(random(-5,5), 6 + i*3, random(-5,5))
		local item = Items.createItem(itemName, newPos)
		item.Parent = workspace
		Messages:send("PlayParticle", "PurpleDeathSmoke",  20, newPos)
		Messages:send("PlaySound", "AppearSmoke", newPos)
    end
end

local function claimChest(player, chest)
	Messages:sendAllClients("PlayChestEffect", chest)
	open(chest)
end

local function updateChest(chest)
	local baseColor = BrickColor.new("Persimmon").Color
	local endColor = BrickColor.new("Shamrock").Color

	local lastUse = chest.LastUse.Value
	local useInterval = chest.UseInterval.Value
	local endTime = lastUse + useInterval
	local currentTime = os.time()
	local timeLeft = math.max(0, endTime - currentTime)

	local percentReady = 1 - timeLeft/useInterval

	local result = baseColor:lerp(endColor, percentReady)
	chest.Lock.Color = result

	if percentReady == 1 then
		chest.Sparkles.Sparkles.Rate = 2
	else
		chest.Sparkles.Sparkles.Rate = 0
	end
end

local function step()
	for _, chest in pairs(CollectionService:GetTagged("Chest")) do
		updateChest(chest)
	end
end

local Chests = {}

function Chests:start()
	RunService.Heartbeat:connect(function()
		step()
	end)
	Messages:hook("ClaimChest", claimChest)
end

return Chests
