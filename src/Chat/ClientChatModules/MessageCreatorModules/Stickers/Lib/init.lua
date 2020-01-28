--- Nevermore module loader.
-- Used to simply module loading
-- @module Nevermore

--[[
USAGE:

See README.md
https://github.com/Quenty/NevermoreEngine/blob/version2/loader/ReplicatedStorage/Nevermore/README.md

In general usage is simple
1) Put this script, and all of its children in ReplicatedStorage.Nevermore (or your preferred parent)

2) Put a uniquely named module in appropriate parent
* By default `ServerScriptService.Modules` and all submodules is loaded
* Modules in folders named "Client" or "Server" will only be available on the Client or Server
* Modules parented to other modules will not be moved or loadable by name

3) Use the module loader
```lua
local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))
```

4) Require by name or instance. This will detect auto-cyclic issues
```lua
local MyModule = require("MyModule")
local MyOtherModule = require(script.MyOtherModule)
```
]]

local ModuleScriptLoader = require(script:WaitForChild("Require"):WaitForChild("ModuleScriptLoader"))
local ReplicationUtils = require(script:WaitForChild("Require"):WaitForChild("ReplicationUtils"))

local loader = ModuleScriptLoader.new({
	ReplicationUtils.ScriptType.SHARED;
})

loader:AddModulesFromParent(script)

return loader