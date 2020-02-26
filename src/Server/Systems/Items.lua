local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function attemptCarryItem(player, item)
    local character = player.Character
    if not character then
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
        return
    end
    local alive = character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    if not alive then 
        return
    end
    Messages:send("PlaySound", "UiClick", character.Head)
    print("Play sound")
    character.PrimaryPart.RootPriority = 200
    item.Parent = character
    item.PrimaryPart.RootPriority = 10 -- for later when you're throwing
    item.PrimaryPart:SetNetworkOwner(player)
    item.PrimaryPart.CFrame = player.Character.Head.CFrame * CFrame.new(0, item.PrimaryPart.Size.Y/2 + player.Character.Head.Size.Y/2, 0)
    local serverWeld = Instance.new("WeldConstraint", item)
    serverWeld.Part0 = player.Character.Head
    serverWeld.Part1 = item.PrimaryPart
    serverWeld.Name = "ServerWeld"
    Messages:sendClient(player, "SetCarryItem", item)
end

local function throw(player, item)
    if item:FindFirstChild("ServerWeld") then
        item.ServerWeld:Destroy()
    end
    item.Parent = workspace
    Messages:send("PlaySound", "HeavyWhoosh", item.PrimaryPart)
    delay(6, function()
        if item:IsDescendantOf(game) and item.PrimaryPart:CanSetNetworkOwnership() then 
            local netOwner = item.PrimaryPart:GetNetworkOwner() 
            if netOwner == nil or netOwner == player then
                item.PrimaryPart:SetNetworkOwnershipAuto()
            end
        end
    end)
end

local function throwAllPlayerItems(player)
    local character = player.Character
    for _, p in pairs(character:GetChildren()) do
        if CollectionService:HasTag(p, "Item") then
                throw(player, p)
            break
        end
    end
end

local Items = {}

function Items.createItem(itemName, position)
    local itemModel = game.ServerStorage.Items[itemName]:Clone()
    itemModel.PrimaryPart = itemModel.Base
    itemModel:SetPrimaryPartCFrame(CFrame.new(position))
    itemModel.Parent = workspace
    return itemModel
end

function Items:start()
    -- todo: force drop an item if a player is carrying it on leave
    Messages:hook("CreateItem", function(itemName, position)
        Items.createItem(itemName, position)
    end)
    Messages:hook("PlayerDied", function(player, character)
        throwAllPlayerItems(player)
    end)
    Messages:hook("PLayerRemoving", function(player)
        if player.Character then
            throwAllPlayerItems(player)
        end
    end)
    Messages:hook("CarryItem", function(player, item)
        attemptCarryItem(player, item)
    end)
    Messages:hook("Throw", function(player, item)
        if item.Parent == player.Character then
            throw(player, item)
        end
    end)
end

return Items