local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local TweenService = game:GetService("TweenService")

local lastTextures = {}

local NEON_COLOR = BrickColor.new("CGA brown")
local SPECIALMESH_COLOR = Color3.fromRGB(234, 148, 0)

local function playRespawnEffect(player, character)
    local length = 1.1
    local parts = {}
    for i, possiblePart in pairs(character:GetDescendants()) do
        if possiblePart:IsA("Accessory") then
            --possiblePart.Transparency = 1
            if possiblePart:FindFirstChild("Handle") then
                lastTextures[possiblePart.Handle.SpecialMesh] = possiblePart.Handle.SpecialMesh.TextureId
                possiblePart.Handle.SpecialMesh.TextureId = ""
                possiblePart.Handle.Color = SPECIALMESH_COLOR
            end
        end
        if possiblePart:IsA("BasePart") and possiblePart.Transparency < 1 and not possiblePart.Parent:IsA("Accessory") then
            local part = possiblePart:Clone()
            part.Name = "x"
            part.Size = possiblePart.Size * 1.1
            part:BreakJoints()
            part.RootPriority = 0
            part.Massless = true
            part.Transparency = 0
            part.CanCollide = false
            part.Anchored = false
            part.CFrame = possiblePart.CFrame --* CFrame.new(.1,0,0)
            if part:IsA("MeshPart") then
                part.TextureID = ""
            end
            part.BrickColor = NEON_COLOR
            if part:FindFirstChild("Mesh") then
                part.Mesh.TextureId = ""
                if part.Mesh:IsA("SpecialMesh") then
                    print("SPECIAL MESH")
                    part.Mesh.Scale = part.Mesh.Scale * 2
                    part.Mesh.TextureId = ""
                    part.Color = SPECIALMESH_COLOR
                end
            end
            for _, n in pairs(part:GetChildren()) do
                if n:IsA("Attachment") or n:IsA("Motor6D") or n:IsA("Decal") then
                    n:Destroy()
                end
            end
            part.Material = Enum.Material.Neon
            part.Parent = possiblePart.Parent
            part.CFrame = possiblePart.CFrame
            local w = Instance.new("WeldConstraint")
            w.Part0 = possiblePart
            w.Part1 = part
            w.Parent = part
            table.insert(parts, part)
            game:GetService("Debris"):AddItem(part, length*2)
        end
    end
    local light = Instance.new("PointLight", character.Head)
    light.Brightness = 8
    light.Color = SPECIALMESH_COLOR
    Messages:send("PlayParticle", "DeathSmoke",  10, character.Head.Position)
    Messages:send("PlaySound", "Smoke", character.Head.Position)
    spawn(function()
        wait(length)
        for _, part in pairs(parts) do
            local tweenInfo = TweenInfo.new(
                length,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out,
                0
            )
            local tween = TweenService:Create(part,tweenInfo, {Size = part.Size*.9, Transparency = 1})
            tween:Play()
            if part:FindFirstChild("Mesh") and part.Mesh:IsA("SpecialMesh") then
                local tween = TweenService:Create(part.Mesh,tweenInfo, {Scale = part.Mesh.Scale*.9})
                tween:Play()
            end
        end
        wait(length)
        for mesh, id in pairs(lastTextures) do
            mesh.TextureId = id
        end
        light:Destroy()
        Messages:send("SpawnEffectPlayed", player, character)
    end)
end

local SpawnEffect = {}

function SpawnEffect:start()
    Messages:hook("CharacterAppearanceSet", function(player, character)
        playRespawnEffect(player, character)
    end)
end

return SpawnEffect