local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Binds = import "Client/Systems/Binds"
local GetCharacter = import "Shared/Utils/GetCharacter"
local CollectionService = game:GetService("CollectionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local ContextActionService = game:GetService("ContextActionService")
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"
local UseTexts = import "Shared/Data/UseTexts"

local itemModule
local carryItemInstance
local lastToolUse = time()

local function getItemModule(itemInstance)
    local itemModule
    for tag, moduleState in pairs(TagsToModulesMap.Items) do
        if CollectionService:HasTag(itemInstance, tag) then
            print("WE GOT ONE FOR : ", tag)
            itemModule = moduleState
            break
        end
    end
    if not itemModule then
        itemModule = import "Shared/ItemModules/Default"
    end
    return itemModule
end

local function unequipCarryItem()
    local holdAnimation = "Carry"
    if carryItemInstance:FindFirstChild("HoldAnimation") then
        holdAnimation = carryItemInstance.HoldAnimation.Value
    end
    Messages:send("StopAnimationClient", holdAnimation)
    if itemModule then
        itemModule.clientUnequip(carryItemInstance)
        itemModule = nil
    else
        warn("bad item module? look into this")
    end
    Messages:send("DestroyContextualBind", "USE")
    Messages:send("DestroyContextualBind", "GRAB")
    Messages:send("DestroyContextualBind", "STORE")
end


local function attemptCarryItem(item)
    if item.Parent ~= workspace then
        return
    end
    Messages:sendServer("CarryItem", item)
    local holdAnimation = "Carry"
    if item:FindFirstChild("HoldAnimation") then
        holdAnimation = item.HoldAnimation.Value
    end
    Messages:send("PlayAnimationClient", holdAnimation)
    return true
end

local function attemptThrowItem() -- the fact that this is for both normal items and buildings
    -- is one of the most unfortunate aspects of this code base so far
    local character = GetCharacter()
    for _, possibleItem in pairs(character:GetChildren()) do
        if CollectionService:HasTag(possibleItem, "Item") or CollectionService:HasTag(possibleItem, "Building")then
            if not CollectionService:HasTag(possibleItem, "Building") then 
                Messages:send("PlaySoundOnClient",{
                    instance = game.ReplicatedStorage.Sounds.HeavyWhoosh,
                    part = character.Head, 
                    volume = (possibleItem.PrimaryPart.Velocity.Magnitude > 2 and .25) or .1
                })
            else
                Messages:send("PlaySoundOnClient",{
                    instance = game.ReplicatedStorage.Sounds.ClickHigh,
                    part = character.Head, 
                })
            end
            possibleItem:WaitForChild("ServerWeld")
            possibleItem.ServerWeld:Destroy()
            possibleItem.Parent = workspace
            if not CollectionService:HasTag(possibleItem, "Building") then 
                possibleItem.PrimaryPart.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-4)
                possibleItem.PrimaryPart.Velocity = character.HumanoidRootPart.Velocity * 1.5
            else
                for _, v in pairs(possibleItem:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Velocity = Vector3.new()
                    end
                end
            end
            local holdAnimation = "Carry"
            if possibleItem:FindFirstChild("HoldAnimation") then
                holdAnimation = possibleItem.HoldAnimation.Value
            end
            Messages:send("StopAnimationClient", holdAnimation)
            if CollectionService:HasTag(possibleItem, "Building") then
                local Building = import "Client/Systems/Building"
                print("placed building")
                possibleItem:SetPrimaryPartCFrame(Building.placementCF)
                Messages:sendServer("Throw", possibleItem, Building.placementCF, Building.placementTarget)
            else
                Messages:sendServer("Throw", possibleItem)
            end
        end
    end
end

local function unbindCarry()
    Binds.unbindTagFromAction("Item", "GRAB")
    Binds.unbindTagFromAction("Building", "GRAB")
end

local function carryItem(item)
    local bindInfo = ActionBinds.GRAB
    ContextActionService:BindAction("Throw", function(contextActionName, inputState, inputObject)
        if inputState == Enum.UserInputState.Begin then
            Messages:send("Throw")
        end
    end, false, bindInfo.pcBind, bindInfo.gamepadBind)
    unbindCarry()
end


local function bindCarry()
    ContextActionService:UnbindAction("Throw")
    Binds.bindTagToAction("Item", "GRAB", function(item)
        if attemptCarryItem(item) then
           carryItem(item)
        end
    end)
    Binds.bindTagToAction("Building", "GRAB", function(item)
        if attemptCarryItem(item) then
           carryItem(item)
        end
    end)
end

local function equipCarryItem(itemInstance)
    itemModule = getItemModule(itemInstance)
    itemModule.clientEquip(itemInstance)
    carryItemInstance = itemInstance
    Messages:send("CreateContextualBind", "USE", function()
        local canUse = true
        if itemModule.debounce and time() - lastToolUse < itemModule.debounce then
            canUse = false
        end
        if canUse then
            lastToolUse = time()
            itemModule.clientUse(itemInstance)
            Messages:sendServer("UseItem", itemInstance)
        end
    end, UseTexts[itemInstance.Name] or "USE")
    local throwOrPlaceText = (CollectionService:HasTag(itemInstance, "Building") and "PLACE") or "THROW"
    Messages:send("CreateContextualBind", "GRAB", nil, throwOrPlaceText)
    if CollectionService:HasTag(itemInstance, "Tool") then

        Messages:send("CreateContextualBind", "STORE", function()
            unequipCarryItem()
            Messages:send("StoreTool", carryItemInstance)
            bindCarry()
            -- the server will tell us what to do with respect to equipping/unequipping
        end, "STORE")

    end
end

local Items = {}

function Items:start()
    Messages:hook("ForceSetItem", function(item)
        if attemptCarryItem(item) then
            carryItem(item)
         end
    end)
    Messages:hook("Unequip", function()
        unequipCarryItem()
        bindCarry()
    end)
    Messages:hook("ForceThrowItems", function()
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("Throw", function()
        unequipCarryItem()
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("SetCarryItem", function(carryItemInstance)
        if carryItemInstance then 
            if carryItemInstance:FindFirstChild("TemporaryInstantWeld") then
                carryItemInstance.TemporaryInstantWeld:Destroy()
            end
            unbindCarry() -- just in case!
            equipCarryItem(carryItemInstance)
        end
    end)
    Messages:hook("CharacterAddedClient", function(character)
        bindCarry()
        character:WaitForChild("Humanoid").Died:connect(function()
            unbindCarry()
            unequipCarryItem()
        end)
    end)
end

return Items