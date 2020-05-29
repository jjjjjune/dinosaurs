return function(useMouse)
    local pos = game.Players.LocalPlayer.Character and 
    game.Players.LocalPlayer.Character.PrimaryPart and 
    game.Players.LocalPlayer.Character.PrimaryPart.Position
    return pos
end