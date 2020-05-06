local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local GameConstants = import "Shared/Data/GameConstants"

local current = 0
local goal = GameConstants.SACRIFICE_GOAL
local maxGoal = goal

local currentSeason = 1

local tagModifiers = {
    Food = 2,
    Ore = 3,
    Tool = 4,
    Seed = 2,
}

local seasonIcons = {
    "FLOWER",
    "SUN",
    "LEAF",
    "SNOWFLAKE",
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

local function performStandardSeasonWeather(actualCurrentSeason)
    if actualCurrentSeason == 4 then
        Messages:send("CreateWeather", "Snow", 30)
    elseif actualCurrentSeason == 1 then
        Messages:send("CreateWeather", "Rain", 30)
    end
end

local function reactToSeason(category, actualCurrentSeason)
    local shouldLower = false
    if category == 1 then
        Messages:send("CreateDisaster", actualCurrentSeason)
    end
    if category == 2 then
        Messages:sendAllClients("Notify", "HUNGER_COLOR_DARK", seasonIcons[currentSeason], "ANOTHER SEASON COMES.")
        performStandardSeasonWeather(actualCurrentSeason)
        shouldLower = true
    end
    if category == 3 then
        --Messages:send("CreateWeather", "Rain", 30)
        Messages:sendAllClients("Notify", "HUNGER_COLOR", seasonIcons[currentSeason], "SOMETHING GOOD HAPPENS.")
        shouldLower = true
    end
    if category == 4 then
        Messages:send("CreateWeather", "Rain", 30)
        Messages:sendAllClients("Notify", "HEALTH_COLOR", seasonIcons[currentSeason], "THE PLANTS GROW.")
        Messages:send("GrowAllPlants")
        shouldLower = true
    end
    if shouldLower then
        Messages:sendAllClients("PlaySoundOnClient",{
            instance = game.ReplicatedStorage.Sounds.Rumble
        })
        Messages:sendAllClients("ShakeCamera","Earthquake")
        Messages:send("LowerOcean")
    end
end

local firstSeason = true

local function evaluateSeason()
    if firstSeason then
        firstSeason = false
        return
    end
    local percent = (current/goal)*100
    local actualCurrentSeason = currentSeason + 1
    if actualCurrentSeason > 4 then
        actualCurrentSeason = 1
    end
    local category
    if percent <= 33 then
        category = 1
    elseif percent > 33 and percent <= 66 then
        category = 2
    elseif percent <= 95 then
        category = 3
    else
        category = 4
    end
    reactToSeason(category, actualCurrentSeason)
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