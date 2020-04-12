local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local RespawnManager = {}

function RespawnManager:start()
    Messages:hook("PlayerDied", function(player, characterThatDied)
        if characterThatDied.PrimaryPart then
            local items = import "Server/Systems/Items"
            local skull = items.createItem("Skull", characterThatDied.PrimaryPart.Position)
            skull.Name = "PlayerSkull"
            local skullPlayer = Instance.new("ObjectValue", skull)
            skullPlayer.Name = "Player"
            skullPlayer.Value = player
            CollectionService:AddTag(skull, "PlayerSkull")
            Messages:send("PlaySound", "Smoke", characterThatDied.PrimaryPart.Position)
            Messages:send("PlayParticle", "DeathSmoke",  20, skull.PrimaryPart.Position)
            for _, part in pairs(characterThatDied:GetChildren()) do
                if part:IsA("BasePart") then
                    part:Destroy()
                end
            end
        else
            -- fell off map or something?
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
    end)
    Messages:hook("PlayerAdded", function(player)
        local Gamemode = import "Server/Systems/Gamemode"
        if Gamemode.loaded then
            print("loading char situation 1")
            player:LoadCharacter()
        end
    end)
    Messages:hook("SeasonSetTo", function(currentSeason)
        for _, p in pairs(game.Players:GetPlayers()) do
            if (not p.Character) or (p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health <= 0) then
                print("loading char situation 3")
                p:LoadCharacter()
            end
        end
    end)
end

return RespawnManager
