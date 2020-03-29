local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetCharacter = import "Shared/Utils/GetCharacter"
local CastRay = import "Shared/Utils/CastRay"
local CollectionService = game:GetService("CollectionService")

local RunService = game:GetService("RunService")

local placementModel

local function setCharTransparency()
    local character = GetCharacter()
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BasePart") and v.Parent ~= placementModel then
            v.LocalTransparencyModifier = .8
        end
    end
end

local function startBuilding(buildingModel)
    placementModel = buildingModel:Clone()
    CollectionService:AddTag(placementModel, "RayIgnore")
    CollectionService:AddTag(GetCharacter(), "RayIgnore")
    for _, v in pairs(placementModel:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Anchored = true
        end
    end
    for _, x in pairs(placementModel:GetChildren()) do
        if x:IsA("JointInstance") or x:IsA("WeldConstraint") then
            print("ok destroying hjoin")
            x:Destroy()
        end
    end
end
 
local function endBuilding(buildingModel)
    placementModel:Destroy()
    placementModel = nil
    CollectionService:RemoveTag(GetCharacter(), "RayIgnore")
end

local Building = {}

function Building.step()
    if placementModel then
        print("yeah")
        setCharTransparency()
        local camera = Workspace.CurrentCamera
        local mouse = game.Players.LocalPlayer:GetMouse()
        local mHit, mPos, mNormal = CastRay(mouse.UnitRay.Origin, mouse.UnitRay.Direction)
        local hit,  pos, normal = CastRay(camera.CFrame.p, (mPos - camera.CFrame.p).unit*300)
        if hit then
            local character = GetCharacter()
            placementModel.Name = "What"
            placementModel.Parent = character
            local dir = CFrame.new(Vector3.new(), normal)
            dir = dir - dir.p
            placementModel:SetPrimaryPartCFrame(CFrame.new(pos) * dir * CFrame.Angles(-math.pi/2,0,0) * CFrame.new(0, placementModel.PrimaryPart.Size.Y/2, 0) )
            Building.placementCF = placementModel.PrimaryPart.CFrame
            Building.placementTarget = hit
       --[[works else
            print("hit nothing")--]]
        end
    else
        local character = GetCharacter()
        if character then
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.LocalTransparencyModifier = 0
                end
            end
        end
    end
end

function Building:start()
    Messages:hook("StartBuilding", startBuilding)
    Messages:hook("EndBuilding", endBuilding)
    RunService.RenderStepped:connect(self.step)
end

return Building