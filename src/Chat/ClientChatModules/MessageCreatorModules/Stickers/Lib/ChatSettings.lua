--- A shortcut, if you will.
--  I have sinned.
-- @classmod ChatSettings
-- @author Quenty

local messageCreatorFolder = script:FindFirstAncestorOfClass("ModuleScript").Parent.Parent
local baseFolder = messageCreatorFolder.Parent

return require(baseFolder:WaitForChild("ChatSettings"))