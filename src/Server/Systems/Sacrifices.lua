local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local current = 0
local goal = 4

local currentSeason = 1

local function onSacrificedItem(item, pit)
    local itemName = item.Name
    local sacrificePoints = 1

    local lavaPos = Vector3.new(item.PrimaryPart.Position.X, pit.Lava.Position.Y, item.PrimaryPart.Position.Z)

    Messages:send("PlaySound", "Smoke", lavaPos)
    Messages:send("PlayParticle", "DeathSmoke",  10, lavaPos)

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
        if hit.Parent:FindFirstChild("Humanoid") then
            --hit.Parent.Humanoid:TakeDamage(10)
        end
        if CollectionService:HasTag(hit.Parent, "Item") then
            if not hit.Parent:FindFirstChild("Humanoid") then
                onSacrificedItem(hit.Parent, altar)
            end
        end
    end)
end

local function evaluateSeason()
    local percent = (current/goal)*100
    local actualCurrentSeason = currentSeason + 1
    if percent <= 33 then
        Messages:send("DryAllWater")
        if actualCurrentSeason == 4 then
            Messages:send("CreateWeather", "Snow", 30)
        end
    elseif percent > 33 and percent <= 66 then
        if math.random(1,2) == 1 then
            Messages:send("DryAllWater")
        end
        if actualCurrentSeason == 4 then
            Messages:send("CreateWeather", "Snow", 30)
        end
        Messages:send("LowerOcean")
    elseif percent <= 95 then
        Messages:send("WetAllWater")
        if actualCurrentSeason ~= 4 then
            Messages:send("CreateWeather", "Rain", 30)
        else
            Messages:send("CreateWeather", "Snow", 30)
        end
        Messages:send("LowerOcean")
    else
        Messages:send("WetAllWater")
        if actualCurrentSeason ~= 4 then
            Messages:send("CreateWeather", "Rain", 30)
        else
            Messages:send("CreateWeather", "Snow", 30)
        end
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
        goal = 4
        Messages:sendAllClients("UpdateSacrificePercent", current/goal)
    end)
    Messages:hook("PlayerAdded", function(player)
        Messages:sendClient("UpdateSacrificePercent", player, current/goal)
    end)
end

return Sacrifices