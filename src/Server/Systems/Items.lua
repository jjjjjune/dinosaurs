local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function attemptCarryItem(player, item)
    local character = player.Character
    if not character then
        print("no char")
        return
    end
    local foundItem = false
    if item.Parent == workspace then
        for _, v in pairs(character:GetChildren()) do
            if CollectionService:HasTag(v, "Item") then
                foundItem = true
            end
        end
    end
    if foundItem == true then
        print("oh no found uitem")
        return
    end
    local alive = character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    if not alive then 
        print("da alive !!")
        return
    end
    character.PrimaryPart.RootPriority = 200
    item.Parent = character
    item.PrimaryPart.RootPriority = 10 -- for later when you're throwing
    item.PrimaryPart:SetNetworkOwner(player)
    item:SetPrimaryPartCFrame(player.Character.Head.CFrame * CFrame.new(0,4,0))
    local serverWeld = Instance.new("WeldConstraint", item)
    serverWeld.Part0 = player.Character.Head
    serverWeld.Part1 = item.PrimaryPart
    serverWeld.Name = "ServerWeld"
    Messages:sendClient(player, "SetCarryItem", item)
end

local function throw(item)
    if item:FindFirstChild("ServerWeld") then
        item.ServerWeld:Destroy()
    end
    item.Parent = workspace
    delay(2, function()
        if item:IsDescendantOf(game) then 
            item.PrimaryPart:SetNetworkOwnershipAuto()
        end
    end)
end

local Items = {}

function Items:start()
    -- todo: force drop an item if a player is carrying it on leave
    Messages:hook("PlayerDied", function(player, character)
        for _, p in pairs(character:GetChildren()) do
            if CollectionService:HasTag(p, "Item") then
                    throw(p)
                break
            end
        end
    end)
    Messages:hook("CarryItem", function(player, item)
        attemptCarryItem(player, item)
    end)
    Messages:hook("Throw", function(player, item)
        if item.Parent == player.Character then
            throw(item)
        end
    end)
end

return Items