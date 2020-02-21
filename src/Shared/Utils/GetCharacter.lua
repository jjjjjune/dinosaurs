return function()
    return game.Players.LocalPlayer.Character and 
    game.Players.LocalPlayer.Character.PrimaryPart and 
    game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and
    game.Players.LocalPlayer.Character.Humanoid.Health > 0 and
    game.Players.LocalPlayer.Character
end