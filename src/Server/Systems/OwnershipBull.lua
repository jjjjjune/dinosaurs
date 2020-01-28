local import = require(game.ReplicatedStorage.Shared.Import)

local OwnershipBull = {}

function OwnershipBull:start()
    game.Players.PlayerAdded:connect(function(player)
        player.CharacterAdded:connect(function(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Touched:connect(function(hit)
                if hit:CanSetNetworkOwnership() then
                    --if hit:GetNetworkOwner() == nil then
                        hit:SetNetworkOwner(player)
                   -- end
                end
            end)
        end)
    end)
end

return OwnershipBull