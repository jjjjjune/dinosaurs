local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local ServerData = import "Server/Systems/ServerData"

local CollectionService = game:GetService("CollectionService")

local function emptyToolInventory(player, characterThatDied)
    local storedTools = ServerData:getPlayerValue(player, "storedTools")
    for slot, data in pairs(storedTools) do
        if data.item and not data.equipped then
            if characterThatDied then
                local items = import "Server/Systems/Items"
				local item = items.createItem(data.item, characterThatDied.PrimaryPart.Position)
				item.Parent = workspace
            end
            data.item = nil
        end
    end
    ServerData:setPlayerValue(player, "storedTools", storedTools)
end

local RespawnManager = {}

function RespawnManager:start()
    Messages:hook("PlayerDied", function(player, characterThatDied)
        if characterThatDied.PrimaryPart then
           --[[ local items = import "Server/Systems/Items"
            local skull = items.createItem("Skull", characterThatDied.PrimaryPart.Position)
            skull.Name = "PlayerSkull"
            local skullPlayer = Instance.new("ObjectValue", skull)
            skullPlayer.Name = "Player"
            skullPlayer.Value = player
            CollectionService:AddTag(skull, "PlayerSkull")
            Messages:send("PlaySound", "Smoke", characterThatDied.PrimaryPart.Position)--]]
            --Messages:send("PlayParticle", "DeathSmoke",  20, skull.PrimaryPart.Position)
            Messages:send("PlaySound", "Smoke", characterThatDied.PrimaryPart.Position)
            Messages:send("PlayParticle", "DeathSmoke",  20, characterThatDied.PrimaryPart.Position)
			emptyToolInventory(player, characterThatDied)

            for _, part in pairs(characterThatDied:GetDescendants()) do
                if part:IsA("BasePart") then
					local w = Instance.new("WeldConstraint", part)
					w.Part0 = part
					w.Part1 = characterThatDied.PrimaryPart
				end
				if CollectionService:HasTag(part, "Mask") then
					part:Destroy()
				end
				if part:IsA("Accessory") then
					part:Destroy()
				end
			end

			if characterThatDied:FindFirstChild("Head") then
				local skull = game.ServerStorage.PlayerResources.Skull:Clone()
				skull.CFrame = characterThatDied.Head.CFrame * CFrame.Angles(0, math.pi, 0)
				skull.Parent = characterThatDied
				local w = Instance.new("WeldConstraint", skull)
				w.Part0 = skull
				w.Part1 = characterThatDied.Head
				characterThatDied.Head.Transparency = 1
			end
            wait(3)
            player:LoadCharacter()
        else
            --emptyToolInventory(player, nil)
            -- fell off map or something?
            wait(1)
            player:LoadCharacter()
        end
    end)
    Messages:hook("PlayerRemoving", function(player)
        for _, skull in pairs(CollectionService:GetTagged("PlayerSkull")) do
            if skull.Player.Value == player then
                Messages:send("PlaySound", "Smoke", skull.PrimaryPart.Position)
                Messages:send("PlayParticle", "DeathSmoke",  20, skull.PrimaryPart.Position)
                Messages:send("DestroyItem", skull)
            end
        end
    end)
    Messages:hook("CharacterAdded", function(player, character)
        for _, skull in pairs(CollectionService:GetTagged("PlayerSkull")) do
            if skull.Player.Value == player then
                Messages:send("PlaySound", "Smoke", skull.PrimaryPart.Position)
                Messages:send("PlayParticle", "DeathSmoke",  20, skull.PrimaryPart.Position)
                Messages:send("DestroyItem", skull)
            end
        end
        repeat wait() until workspace:FindFirstChild("Altar", true)
        local altar = workspace:FindFirstChild("Altar", true)
        character.PrimaryPart.RootPriority = 127
        wait()
		character.PrimaryPart.CFrame = altar.PrimaryPart.CFrame * CFrame.new(0,4,6)
		Messages:send("PlayParticleSystem", "Explosion", character.PrimaryPart)
		Messages:send("PlaySound", "ExplosionRocket1", character.PrimaryPart)
    end)
    Messages:hook("PlayerAdded", function(player)
        local Gamemode = import "Server/Systems/Gamemode"
        if Gamemode.loaded then
            player:LoadCharacter()
        end
    end)
    Messages:hook("MapDoneGenerating", function()
        for _, p in pairs(game.Players:GetPlayers()) do
            p:LoadCharacter()
        end
    end)
    Messages:hook("SeasonSetTo", function(currentSeason, isFirstServerLoad)
        if isFirstServerLoad then
            return
        end
        for _, p in pairs(game.Players:GetPlayers()) do
            if (not p.Character) or (p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health <= 0) then
                p:LoadCharacter()
            end
        end
    end)
end

return RespawnManager
