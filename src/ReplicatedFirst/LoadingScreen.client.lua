local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

game.ReplicatedFirst:RemoveDefaultLoadingScreen()

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game.StarterGui:SetCore("TopbarEnabled", false)

local assets = {"rbxassetid://4879346736"}


local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
--PlayerGui:SetTopbarTransparency(0)
 
local screen = Instance.new("ScreenGui")
screen.Parent = PlayerGui
screen.DisplayOrder = 10

local frame = Instance.new("Frame", screen)
frame.Size = UDim2.new(1,0,1,0)
frame.BorderSizePixel = 0
frame.BackgroundColor3 = Color3.fromRGB(141,255,198)

local sunImage 

ContentProvider:PreloadAsync(assets, function()
    sunImage = Instance.new("ImageLabel")
    sunImage.Size = UDim2.new(0, 532, 0 , 531)
    sunImage.BackgroundTransparency = 1
    sunImage.AnchorPoint = Vector2.new(.5,.5)
    sunImage.Position = UDim2.new(.5, 0, .5, 0)
    sunImage.Image = "rbxassetid://4900465789"
    sunImage.ImageColor3 = Color3.fromRGB(255,114,114)
    sunImage.Parent = screen
end)

local connection = RunService.RenderStepped:connect(function()
    if sunImage then
        sunImage.Rotation = sunImage.Rotation + .5
    end
end)

repeat wait() until game.Players.LocalPlayer.Character

sunImage:TweenSize(UDim2.new(0,5320,0,5310), "Out", "Quad", 1, false, function()
    screen:Destroy()
    --[[local info = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local props = {FieldOfView = 70}
    local tween = TweenService:Create(workspace.CurrentCamera, info, props)
    tween:Play()--]]
end)

game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
game.StarterGui:SetCore("TopbarEnabled", true)
connection:disconnect()

--workspace.CurrentCamera.FieldOfView = 1
--workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p, workspace.Effects.Sun.Position)