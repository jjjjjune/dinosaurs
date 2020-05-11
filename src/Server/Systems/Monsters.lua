local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local monsterGroupId = PhysicsService:CreateCollisionGroup("MonsterGroup")

PhysicsService:CollisionGroupSetCollidable("MonsterGroup", "Default", false)

local TagsToModulesMap = import "Shared/Data/TagsToModulesMap"

local function getComponent(monster)
    for tagName, moduleState in pairs(TagsToModulesMap.Monsters) do
        if CollectionService:HasTag(monster, tagName) then
            return moduleState
        end
    end
end

local Monsters = {}

function Monsters:start()
    repeat wait() until workspace:FindFirstChild("Wheatlies")
    wait(1)
    local monster = game.ServerStorage.Monsters.Lizard:Clone()
    monster.Parent = workspace
    monster.PrimaryPart.CFrame = CFrame.new(workspace.Wheatlies.Head.Position)
    local component = getComponent(monster).new()
    component:init(monster)
    PhysicsService:SetPartCollisionGroup(monster.Torso, "MonsterGroup")
    PhysicsService:SetPartCollisionGroup(monster.Head, "MonsterGroup")
end

return Monsters