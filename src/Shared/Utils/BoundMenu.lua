---DOCUMENTATION
--THANKS SHELLC FOR UR HELP
--GOLLY

--[[
	<BoundMenu> BoundMenu.new(Array)
		@param Array
			-- list of objects the BoundMenu can interact with

		--==Functions==--
		<nil> :LoadObjects(Array)
		-- Refreshes the list of objects the BoundMenu can interact with
			@param Array
				-- list of objects the BoundMenu can interact with
		<nil> :SetSelection(GuiObject)
			@param GuiObject
				-- Desired object for selection
			-- Forces the menu to select the GuiObject passed
		<nil> :Destroy()
			-- Disconnects input events connected from the BoundMenu

		--==Properties==--
		.Enabled = true
			-- Determines if input events are enabled for the BoundMenu
		.KeyboardEnabled = true
			-- Determines if input events listen to Keyboard input
		.GamepadEnabled = true
			-- Determines if input events listen to Gamepad input
		.DirectionThreshold = 0.5
			-- Determines how sensitive the menu is when it comes to direction
		.Selection = <GuiObject>
			-- References the curerent selection from the BoundMenu

		--==Events==--
		.SelectionChanged(<GuiObject> OldObject, <GuiObject> NewObject)
			@param OldObject
				-- the previous selection
			@param NewObject
				-- the new selection
			-- Fires when the selection changes through the BoundMenu
--]]



local UserInputService = game:GetService("UserInputService")

local BoundMenu = {} do
	BoundMenu.__index = BoundMenu

	function BoundMenu.new(Array)
		local this = setmetatable({}, BoundMenu)

		this._ListOfObjects = {}
		this.Selection = nil
		this._SelectionChangedEvent = Instance.new("BindableEvent")
		this.SelectionChanged = this._SelectionChangedEvent.Event

		-----------
		this.Enabled = true
		this.KeyboardEnabled = true
		this.GamepadEnabled = true
		this.DirectionThreshold = 0.5
		----------------------
		--Initialize
		this:_HookEvents()
		this:LoadObjects(Array)
		this:SetSelection(Array[1])

		return this
	end

	function BoundMenu:_HookEvents()
		self._BeganConnection = UserInputService.InputBegan:connect(function(InputObject)
			if self.Enabled then
				if (self.KeyboardEnabled) and (InputObject.UserInputType.Name == "Keyboard") then
					if (InputObject.KeyCode.Name == "A")  or (InputObject.KeyCode.Name == "Left") then
						self:_GetObjectByDirection(Vector2.new(-1, 0))
					elseif (InputObject.KeyCode.Name == "D")  or (InputObject.KeyCode.Name == "Right") then
						self:_GetObjectByDirection(Vector2.new(1, 0))
					elseif (InputObject.KeyCode.Name == "W")  or (InputObject.KeyCode.Name == "Up") then
						self:_GetObjectByDirection(Vector2.new(0, -1))
					elseif (InputObject.KeyCode.Name == "S") or (InputObject.KeyCode.Name == "Down") then
						self:_GetObjectByDirection(Vector2.new(0, 1))
					end
				elseif (self.GamepadEnabled) and (InputObject.UserInputType.Name == "Gamepad1") then
					if (InputObject.KeyCode.Name == "DPadLeft") then
						self:_GetObjectByDirection(Vector2.new(-1, 0))
					elseif (InputObject.KeyCode.Name == "DPadRight") then
						self:_GetObjectByDirection(Vector2.new(1, 0))
					elseif (InputObject.KeyCode.Name == "DPadUp") then
						self:_GetObjectByDirection(Vector2.new(0, -1))
					elseif (InputObject.KeyCode.Name == "DPadDown") then
						self:_GetObjectByDirection(Vector2.new(0, 1))
					end
				end
			end
		end)

		local LastVector = Vector3.new()
		self._ChangedConnection = UserInputService.InputChanged:connect(function(InputObject)
			if (self.GamepadEnabled) and (InputObject.UserInputType.Name == "Gamepad1") then
				if (InputObject.KeyCode.Name == "Thumbstick1") then
					local UnitPosition = InputObject.Position.unit
					if (LastVector - InputObject.Position).magnitude >= 0.5 then
						if LastVector == Vector3.new() then
							self:_GetObjectByDirection(Vector2.new(UnitPosition.X, -UnitPosition.Y))
						else
							if  LastVector:Dot(InputObject.Position.unit) < 0 then --opposite direction?
								self:_GetObjectByDirection(Vector2.new(UnitPosition.X, -UnitPosition.Y))
							end
						end
						LastVector = InputObject.Position.unit
					end
				end
			end
		end)

		self._EndedConnection = UserInputService.InputEnded:connect(function(InputObject)
			if (self.GamepadEnabled) and (InputObject.UserInputType.Name == "Gamepad1") then
				if (InputObject.KeyCode.Name == "Thumbstick1") then
					LastVector = Vector3.new()
				end
			end
		end)



	end

	function BoundMenu:SetSelection(GuiObject)
		local OldGuiObject = self.Selection
		self.Selection = GuiObject
		self:_DoEvent(OldGuiObject, GuiObject)
	end

	function BoundMenu:LoadObjects(Array)
		self._ListOfObjects = Array
	end

	function BoundMenu:_DoEvent(OldGuiObject, NewGuiObject)
		if self.Enabled then
			self._SelectionChangedEvent:Fire(OldGuiObject, NewGuiObject)
		end
	end

	function BoundMenu:_GetObjectByDirection(Direction)
		if self.Selection then
			local Canidates = {}
			for _, Object in pairs (self._ListOfObjects) do
				if Object ~= self.Selection then
					local ObjectDirection = ((Object.AbsolutePosition)
					- self.Selection.AbsolutePosition).unit
					if (ObjectDirection - Direction).magnitude <= self.DirectionThreshold then
						Canidates[#Canidates + 1] = Object
					end
				end
			end
			if #Canidates == 1 then
				self:SetSelection(Canidates[1])
				return
			elseif #Canidates > 0 then
				local BestCanidate = Canidates[1]
				for _, Object in pairs (Canidates) do
					local ObjectDistance = (
						(Object.AbsolutePosition + (Object.AbsoluteSize / 2))
						- (self.Selection.AbsolutePosition + (self.Selection.AbsoluteSize / 2))
						).magnitude
					local CanidateDistance = (
						(BestCanidate.AbsolutePosition + (BestCanidate.AbsoluteSize / 2))
						- (self.Selection.AbsolutePosition + (self.Selection.AbsoluteSize / 2))
						).magnitude
					if ObjectDistance <= CanidateDistance then
						BestCanidate = Object
					end
				end
				self:SetSelection(BestCanidate)
			end
		end
	end

	function BoundMenu:Destroy()
		self.Enabled = false
		self._SelectionChangedEvent:Destroy()
		self._BeganConnection:disconnect()
		self._ChangedConnection:disconnect()
		self._EndedConnection:disconnect()
	end
end


return BoundMenu
