local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local current = 0
local goal = 12
local maxGoal = goal

local currentSeason = 1

local tagModifiers = {
    Food = 2,
    Ore = 3,
    Tool = 4,
    Seed = 2,
}

local function onSacrificedItem(item, pit)

    local itemName = item.Name
    local sacrificePoints = 1

    local lavaPos = Vector3.new(item.PrimaryPart.Position.X, pit.Lava.Position.Y, item.PrimaryPart.Position.Z)

    Messages:send("PlaySound", "Smoke", lavaPos)
    Messages:send("PlayParticle", "DeathSmoke",  10, lavaPos)

    for tag, modifier in pairs(tagModifiers) do
        if CollectionService:HasTag(item, tag) then
            sacrificePoints = sacrificePoints + modifier
        end
    end

    if itemName == "PlayerSkull" then
        local player = item:FindFirstChild("Player")
        if player then
            spawn(function() player.Value:LoadCharacter() end)
            sacrificePoints = 0
        end
    end

    item:Destroy()
    current = math.min(goal, current + sacrificePoints)

    Messages:sendAllClients("UpdateSacrificePercent", current/goal)
end

local function initializeAltar(altar)
    altar.Lava.Touched:connect(function(hit)
        if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
            --hit.Parent.Humanoid:TakeDamage(10)
        end
        if CollectionService:HasTag(hit.Parent, "Item") then
            if not hit.Parent:FindFirstChild("Humanoid") then
                onSacrificedItem(hit.Parent, altar)
            end
        end
    end)
end

local firstSeason = true

local function evaluateSeason()
    if firstSeason then
        firstSeason = false
        return
    end
    local percent = (current/goal)*100
    local actualCurrentSeason = currentSeason + 1
    local seasonIcons = {
        "FLOWER",
        "SUN",
        "LEAF",
        "SNOWFLAKE",
    }
    if percent <= 33 then
        Messages:send("DryAllWater")
        Messages:sendAllClients("Notify", "HUNGER_COLOR", "ANGRY", "THE GODS DISPLEASED. ALL WATER RECEDED TO DUST.")
        if actualCurrentSeason == 4 then
            Messages:send("CreateWeather", "Snow", 30)
        end
    elseif percent > 33 and percent <= 66 then
        if actualCurrentSeason == 4 then
            Messages:send("CreateWeather", "Snow", 30)
        end
        Messages:send("LowerOcean")
        Messages:sendAllClients("Notify", "HUNGER_COLOR", seasonIcons[currentSeason], "ANOTHER SEASON COMES.")
    elseif percent <= 95 then
        Messages:send("WetAllWater")
        if actualCurrentSeason ~= 4 then
            Messages:send("CreateWeather", "Rain", 30)
        else
            Messages:send("CreateWeather", "Snow", 30)
        end
        Messages:sendAllClients("Notify", "HUNGER_COLOR", seasonIcons[currentSeason], "THE WINDS BRING GOOD WEATHER.")
        Messages:send("LowerOcean")
    else
        Messages:send("WetAllWater")
        if actualCurrentSeason ~= 4 then
            Messages:send("CreateWeather", "Rain", 30)
        else
            Messages:send("CreateWeather", "Snow", 30)
        end
        Messages:sendAllClients("Notify", "HUNGER_COLOR", seasonIcons[currentSeason], "THE GODS AKNOWLEDGE THE BLESSINGS.")
        Messages:send("GrowAllPlants")
        Messages:send("LowerOcean")
    end
end

local Sacrifices = {}

function Sacrifices:start()
    for _, altar in pairs(CollectionService:GetTagged("Altar")) do
        initializeAltar(altar)
    end
    CollectionService:GetInstanceAddedSignal("Altar"):connect(function(altar)
        initializeAltar(altar)
    end)
    Messages:hook("SeasonSetTo", function(newSeason)
        evaluateSeason()
        currentSeason = newSeason
        current = 0
        goal = maxGoal
        Messages:sendAllClients("UpdateSacrificePercent", current/goal)
    end)
    Messages:hook("PlayerAdded", function(player)
        Messages:sendClient("UpdateSacrificePercent", player, current/goal)
    end)
end

return Sacrifices