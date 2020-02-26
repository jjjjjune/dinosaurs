local UserInputService = game:GetService("UserInputService")

return function()
    if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
        return "Gamepad"
    elseif UserInputService:GetLastInputType() == Enum.UserInputType.Touch then
        return "Mobile"
    end
    return "Desktop"
end