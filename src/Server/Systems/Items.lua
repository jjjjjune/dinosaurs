local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"
local CastRay = import "Shared/Utils/CastRay"

-- local collideMap = {}

-- local function getAttachedItems(item)
-- 	local itemsToIgnore = {}
-- 	local ignored = {}
-- 	if item:FindFirstChild("ObjectWeld") then
--         local weldedItem = item.ObjectWeld.Part1.Parent
-- 		if not ignored[item] then
-- 			ignored[item] = true
--             for _, v in pairs((getAttachedItems(weldedItem, itemsToIgnore))) do
--                 table.insert(itemsToIgnore, v)
--             end
--         end
-- 	end
-- 	return (itemsToIgnore)
-- end

local function prepare(item)
    if CollectionService:HasTag(item, "Building") then
        if not item.PrimaryPart:FindFirstChild("WeldConstraint") then
            for _, v in pairs(item:GetChildren()) do
                if v:IsA("BasePart") then
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = v
                    w.Part1 = item.PrimaryPart
                    w.Parent = v
                end
            end
        end
        for _, v in pairs(item:GetChildren()) do
            if v:IsA("BasePart") then
                v.Anchored = false
            end
        end
	end
	-- do i really want to do this..
	for _, v in pairs(item.PrimaryPart:GetConnectedParts(true)) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
end

local function attemptCarryItem(player, item)
    local character = player.Character
    if not character then
        return
    end
    local foundItem = false
    if item:IsDescendantOf(workspace) then
        for _, v in pairs(character:GetChildren()) do
            if CollectionService:HasTag(v, "Item") then
                foundItem = true
            end
        end
	end
	for _, v in pairs(item:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = false
			v.CanCollide = false
		end
	end
	if CollectionService:HasTag(item, "Building") then
		local ConstraintManager = import "Server/Systems/ConstraintManager"
		ConstraintManager.removeRopesAttachedTo(item)
	end
	-- for _, item in pairs(getAttachedItems(item)) do
	-- 	for _, v in pairs(item:GetChildren()) do
	-- 		if v:IsA("BasePart") then
	-- 			v.CanCollide = false
	-- 		end
	-- 	end
	-- end
    if foundItem == true then
        return
    end
    local alive = character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
    if not alive then
        return
    end
	local ConstraintManager = import "Server/Systems/ConstraintManager"
	ConstraintManager.destroyAllWelds(item)
    Messages:send("PlaySound", "UiClick", character.Head, 200)
    character.PrimaryPart.RootPriority = 200
    item.Parent = character
    item.PrimaryPart.RootPriority = 10 -- for later when you're throwing
    prepare(item)
    item.PrimaryPart:SetNetworkOwner(player)
    local targetPart = player.Character.Head
    if item:FindFirstChild("AttachPart") then
        targetPart = player.Character[item.AttachPart.Value]
        if item.AttachPart.Value == "RightHand" then
            item.PrimaryPart.CFrame = targetPart.CFrame * CFrame.Angles(-math.pi/2,0,0)
        end
    else
        item.PrimaryPart.CFrame = targetPart.CFrame * CFrame.new(0, item.PrimaryPart.Size.Y/2 + targetPart.Size.Y/2, 0)
    end
    local serverWeld = Instance.new("WeldConstraint", item)
    serverWeld.Part0 = targetPart
    serverWeld.Part1 = item.PrimaryPart
    serverWeld.Name = "ServerWeld"
    Messages:sendClient(player, "SetCarryItem", item)
end

local function throw(player, item, desiredCF, target)
    if item:FindFirstChild("ServerWeld") then
        item.ServerWeld:Destroy()
    end
    item.Parent = workspace
    for _, v in pairs(item:GetChildren()) do
		if v:IsA("BasePart") then
            v.CanCollide = true
        end
	end
	-- for _, item in pairs(getAttachedItems(item)) do
	-- 	for _, v in pairs(item:GetChildren()) do
	-- 		if v:IsA("BasePart") then
	-- 			v.CanCollide = true
	-- 		end
	-- 	end
	-- end
    Messages:reproOnClients(player, "PlaySound", "HeavyWhoosh", item.PrimaryPart.Position)
    local welded = false
    if CollectionService:HasTag(item, "Building") and desiredCF then
		item:SetPrimaryPartCFrame(desiredCF)
    end
	if target and target.Anchored == false and not target.Parent:FindFirstChild("Humanoid") then
		print("welding")
		desiredCF = desiredCF * CFrame.new(0, item.PrimaryPart.Size.Y/2, 0)
		local ConstraintManager = import "Server/Systems/ConstraintManager"
		ConstraintManager.createObjectWeld(item, target.Parent, desiredCF.p)
		welded = true
    end
    delay(6, function()
        if item:IsDescendantOf(game) and item.PrimaryPart:CanSetNetworkOwnership() then
            local netOwner = item.PrimaryPart:GetNetworkOwner()
            if netOwner == nil or netOwner == player then
                item.PrimaryPart:SetNetworkOwnershipAuto()
            end
        end
    end)
    if CollectionService:HasTag(item, "Building") and not CollectionService:HasTag(item, "Unanchored") then
        if not welded then
            for _, v in pairs(item:GetDescendants()) do
                if v:IsA("BasePart") then
					v.Anchored = true
					v.CanCollide = true
					v.Velocity = Vector3.new()
					v.RotVelocity = Vector3.new()
                end
            end
        end
    end
end

local function throwAllPlayerItems(player)
    local character = player.Character
    for _, p in pairs(character:GetChildren()) do
        if CollectionService:HasTag(p, "Item") or CollectionService:HasTag(p, "Building")then
                throw(player, p, nil, nil)
            break
        end
    end
end

local function getItemModule(itemInstance)
    local itemModule
    for tag, moduleState in pairs(TagsToModulesMap.Items) do
        if CollectionService:HasTag(itemInstance, tag) then
            itemModule = moduleState
            break
        end
    end
    if not itemModule then
        itemModule = import "Shared/ItemModules/Default"
    end
    return itemModule
end

local Items = {}

function Items.createItem(itemName, position)
   local itemModel do
        if game.ReplicatedStorage.Items:FindFirstChild(itemName) then
            itemModel = game.ReplicatedStorage.Items[itemName]:Clone()
        else
            itemModel = game.ReplicatedStorage.Buildings[itemName]:Clone()
        end
	end
	itemModel.PrimaryPart = itemModel.Base
	local hit, pos = CastRay(position, Vector3.new(0,-4,0))

    itemModel:SetPrimaryPartCFrame(CFrame.new(pos + Vector3.new(0, itemModel.PrimaryPart.Size.Y/2, 0)))
    itemModel.Parent = workspace
    --Messages:send("PlaySound", "Pop", position)
    return itemModel
end

function Items:start()
    Messages:hook("UseItem", function(player, item)
        if item.Parent == player.Character then
            local module = getItemModule(item)
            if module.serverUse(player, item) then
                throwAllPlayerItems(player)
                Messages:sendClient(player, "Unequip")
                item:Destroy()
            end
        end
    end)
    Messages:hook("DestroyItem", function(item)
        if item.Parent:FindFirstChild("Humanoid") then
            local player = game.Players:GetPlayerFromCharacter(item.Parent)
            throwAllPlayerItems(player)
            Messages:sendClient(player, "Unequip")
        end
        item:Destroy()
    end)
    Messages:hook("CreateItem", function(itemName, position)
        Items.createItem(itemName, position)
    end)
    Messages:hook("PlayerDied", function(player, character)
        throwAllPlayerItems(player)
    end)
    Messages:hook("ThrowAllItems", throwAllPlayerItems)
    Messages:hook("PlayerRemoving", function(player)
        if player.Character then
            throwAllPlayerItems(player)
        end
    end)
    Messages:hook("CarryItem", function(player, item)
        attemptCarryItem(player, item)
    end)
    Messages:hook("Throw", function(player, item, desiredCF, target)
        if item.Parent == player.Character then
            throw(player, item, desiredCF, target)
        end
        Messages:send("OnItemThrown", item)
	end)
end

return Items
