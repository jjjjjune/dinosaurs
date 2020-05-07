local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Cookables = import "Shared/Data/Cookables"

local CollectionService = game:GetService("CollectionService")

local HEAT_STEP = 1

local function heatStep()
    for _, area in pairs(CollectionService:GetTagged("HeatArea")) do
        if not area:IsDescendantOf(game.ReplicatedStorage) then
            local checkPart = Instance.new("Part")
            checkPart.CanCollide = false
            CollectionService:AddTag(checkPart, "RayIgnore")
            checkPart.Transparency = 1
            checkPart.Size = Vector3.new(9,9,9)
            checkPart.CFrame = CFrame.new(area.position)
            checkPart.Anchored = true
            checkPart.Touched:connect(function() end)
            checkPart.Parent = workspace
            for _, p in pairs(checkPart:GetTouchingParts()) do
                local item = p.Parent
                if item and not item:FindFirstChild("Humanoid") then
                    local product = Cookables[item.Name]
                    if product then
                        local pos = item.PrimaryPart.Position
                        item:Destroy()
                        local items = import "Server/Systems/Items"
                        items.createItem(product, pos)
                        Messages:send("PlaySound", "Smoke", pos)
                        Messages:send("PlayParticle", "DeathSmoke", 20, pos)
                    else
                        if CollectionService:HasTag(item, "Organic") then
                            Messages:send("SetOnFire", item)
                        end
                    end
                elseif item and item:FindFirstChild("Humanoid") then
                    --Messages:send("SetOnFire", item)
                end
            end
            checkPart:Destroy()
        end
    end
end

local HeatAreas = {}

function HeatAreas:start()
    spawn(function()
        while wait(HEAT_STEP) do
            heatStep()
        end
    end)
end

return HeatAreas