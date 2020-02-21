local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local GetCharacter = import "Shared/Utils/GetCharacter"

local carryingObject = nil

local function findCarryableObject()
    local character = GetCharacter()
    if character then
        local r = Ray.new(character.PrimaryPart.Position, (character.PrimaryPart.CFrame * CFrame.Angles(0,0, math.rad(25))).lookVector * 10)
        local hit, pos = workspace:FindPartOnRayWithWhitelist(r, CollectionService:GetTagged("Carryable"))
        if hit then
            return hit 
        else
            local x = Instance.new("Part", workspace)
            x.Size = Vector3.new()
            x.Anchored = true
            x.CFrame = CFrame.new(pos)
            x.Material = Enum.Material.Neon
            x.CanCollide = false
        end
    end
end

local function putDown()
    Messages:sendServer("PutDownCarry")
end

local function pickUp()
    local object = findCarryableObject()
    if object then
        Messages:sendServer("CarryObject", object)
    end
end

local function carryAction()
    if carryingObject then
        if carryingObject.Parent ~= GetCharacter() then
            carryingObject = nil
            pickUp()
        else
            putDown()
        end
    else
        pickUp()
    end
end

local Carrying = {}

function Carrying:start()
    Messages:hook("SetCarryingObject", function(object)
        carryingObject = object
    end)
    UserInputService.InputBegan:connect(function(input, gameProcessed)
        if input.KeyCode == Enum.KeyCode.E and not gameProcessed then
            carryAction()
        end
    end)
end

return Carrying