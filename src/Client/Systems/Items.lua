local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Binds = import "Client/Systems/Binds"
local GetCharacter = import "Shared/Utils/GetCharacter"
local CollectionService = game:GetService("CollectionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local ContextActionService = game:GetService("ContextActionService")
local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local itemModule
local carryItemInstance

local function getItemModule(itemInstance)
    local itemModule
    for tag, moduleState in pairs(TagsToModulesMap) do
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

local function equipCarryItem(itemInstance)
    itemModule = getItemModule(itemInstance)
    itemModule.clientEquip(itemInstance)
    carryItemInstance = itemInstance
    Messages:send("CreateContextualBind", "USE", function()
        itemModule.clientUse(itemInstance)
        Messages:sendServer("UseItem", itemInstance)
    end)
end

local function unequipCarryItem()
    itemModule.clientUnequip(carryItemInstance)
    itemModule = nil
    Messages:send("DestroyContextualBind", "USE")
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

local function attemptThrowItem()
    local character = GetCharacter()
    for _, possibleItem in pairs(character:GetChildren()) do
        if CollectionService:HasTag(possibleItem, "Item") then
            Messages:send("PlaySoundOnClient",{
                instance = game.ReplicatedStorage.Sounds.HeavyWhoosh,
                part = character.Head
            })
            possibleItem:WaitForChild("ServerWeld")
            possibleItem.ServerWeld:Destroy()
            possibleItem.Parent = workspace
            possibleItem.PrimaryPart.CFrame = possibleItem.PrimaryPart.CFrame * CFrame.new(0,0,-2)
            possibleItem.PrimaryPart.Velocity = character.HumanoidRootPart.Velocity * 2
            Messages:sendServer("Throw", possibleItem)
            Messages:send("StopAnimationClient", "Carry")
        end
    end
end

local function unbindCarry()
    Binds.unbindTagFromAction("Item", "GRAB")
end

local function bindCarry()
    ContextActionService:UnbindAction("Throw")
    Binds.bindTagToAction("Item", "GRAB", function(item)
        if attemptCarryItem(item) then
            local bindInfo = ActionBinds.GRAB
            ContextActionService:BindAction("Throw", function(contextActionName, inputState, inputObject)
                if inputState == Enum.UserInputState.Begin then
                    Messages:send("Throw")
                end
            end, false, bindInfo.pcBind, bindInfo.gamepadBind)
            unbindCarry()
        end
    end)
end

local Items = {}

function Items:start()
    Messages:hook("Unequip", function()
        Messages:send("StopAnimationClient", "Carry")
        unequipCarryItem()
        bindCarry()
    end)
    Messages:hook("Throw", function()
        unequipCarryItem()
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("SetCarryItem", function(carryItemInstance)
        if carryItemInstance:FindFirstChild("TemporaryInstantWeld") then
            carryItemInstance.TemporaryInstantWeld:Destroy()
        end
        equipCarryItem(carryItemInstance)
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