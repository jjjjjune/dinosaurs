--/
-- Richard's 3D Gui Core. (Written by Onogork, 2018)
--	The core script for easy custom 3D GUIs!
--/
-- Guis.
local import = require(game.ReplicatedStorage.Shared.Import)
local FastSpawn = import "Shared/Utils/FastSpawn"

local __GUIS = {};
FastSpawn(function()
	while wait() do
		for key, frame in pairs(__GUIS) do
			if (frame.Destroyed == true) then
				__GUIS[key] = nil; -- Remove from table.
			else
				frame:Update();
			end;
		end;
	end;
end);
-- Module ¬
local Gui3D = require(script.Parent:FindFirstChild("3DGuiMaster"));
local _GuiCore = {};
-- New frame.
function _GuiCore.new(paramModel)
	local result = Gui3D.buildFrame(paramModel);
	table.insert(__GUIS, result);
	return result;
end;
return _GuiCore;
--/
