local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Binds = import "Client/Systems/Binds"
local GetCharacter = import "Shared/Utils/GetCharacter"
local CollectionService = game:GetService("CollectionService")
local ActionBinds = import "Shared/Data/ActionBinds"
local ContextActionService = game:GetService("ContextActionService")

local function attemptCarryItem(item)
    if item.Parent ~= workspace then
        return
    end
    local character = GetCharacter()
    Messages:sendServer("CarryItem", item)
    item:SetPrimaryPartCFrame(character.Head.CFrame * CFrame.new(0,4,0))
    local tempWeld = Instance.new("WeldConstraint", item)
    tempWeld.Name = "TemporaryInstantWeld"
    tempWeld.Part0 = item.PrimaryPart
    tempWeld.Part1 = character.Head
    Messages:send("PlayAnimationClient", "Carry")
    return true
end

local function attemptThrowItem()
    local character = GetCharacter()
    for _, possibleItem in pairs(character:GetChildren()) do
        if CollectionService:HasTag(possibleItem, "Item") then
            possibleItem:WaitForChild("ServerWeld")
            possibleItem.ServerWeld:Destroy()
            possibleItem.Parent = workspace
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
    Messages:hook("Throw", function()
        attemptThrowItem()
        bindCarry()
    end)
    Messages:hook("SetCarryItem", function(carryItemInstance)
        if carryItemInstance:FindFirstChild("TemporaryInstantWeld") then
            carryItemInstance.TemporaryInstantWeld:Destroy()
        end
    end)
    Messages:hook("CharacterAddedClient", function(character)
        bindCarry()
        character:WaitForChild("Humanoid").Died:connect(function()
            unbindCarry()
        end)
    end)
end

return Items