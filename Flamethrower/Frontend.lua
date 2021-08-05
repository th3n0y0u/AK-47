local function mainclass()
	local tool = script.Parent
	local player = game.Players.LocalPlayer 
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = player.Character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local mouse = player:GetMouse()
	local values = tool:WaitForChild("Settings")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local damage = values:WaitForChild("Damage")
	local events = tool:WaitForChild("Events")
	local onshoot = events:WaitForChild("OnShoot")
	local ondeactivate = events:WaitForChild("OnDeactivate")
	local onreload = events:WaitForChild("OnReload")
	local runservice = game:GetService("RunService")
	local userinputservice = game:GetService("UserInputService")
	local gui = tool:WaitForChild("ToolGUI")

	local Camera = workspace.CurrentCamera
	local Character = player.Character or player.CharacterAdded:Wait()
	local Head = Character:WaitForChild("Head")
	local Neck = Head:WaitForChild("Neck")
	local Torso = Character:WaitForChild("UpperTorso")
	local Waist = Torso:WaitForChild("Waist")
	local Humanoid = Character:WaitForChild("Humanoid")
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	local NeckOriginC0 = Neck.C0
	local WaistOriginC0 = Waist.C0 
	local debounce = false
	local reloading = false

	Neck.MaxVelocity = 1/2

	local animations = {
		script.Equip, 
		script.Unequip
	}

	local loadedanimations = {
		animator:LoadAnimation(animations[1]),
		animator:LoadAnimation(animations[2])
	}

	local equipped = true

	local function shoot()
		
		local success, errormessage = pcall(function()
			if equipped == true then
				if debounce == false then
					if mouse.Hit then
						debounce = true
						onshoot:FireServer(mouse.Hit.Position)
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function deactivate()
		
		local success, errormessage = pcall(function()
			if equipped == true then
				debounce = false
				ondeactivate:FireServer()
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function equip()
		
		local success, errormessage = pcall(function()
			if equipped == false then
				equipped = true
				local newgui = gui:Clone()
				newgui.Parent = player.PlayerGui
				loadedanimations[1]:Play()
				while equipped == true and wait() do
					if equipped == false then 
						break
					elseif reloading == true then
						while wait() do
							if reloading == false then
								break 
							end
						end
					else
						newgui.Frame.Ammo.Text = ammo.Value.."/"..clipsize.Value
						newgui.Frame.ReserveAmmo.Text = reserveammo.Value
					end
					if player.Character.Humanoid.Health < 0 then
						Camera.CameraMode = Enum.CameraMode.Classic
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function unequip()
		
		local success, errormessage = pcall(function()
			if equipped == true then
				equipped = false
				local newgui = player.PlayerGui:FindFirstChild("ToolGUI")
				if newgui then
					newgui:Destroy()
				end
				loadedanimations[1]:Stop()
				local length = loadedanimations[2].Length
				loadedanimations[2]:Play()
				wait(length)
				loadedanimations[2]:Stop()
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function reload(input, gameproccesed)
		
		local success, errormessage = pcall(function()
			if input then
				if input.KeyCode == Enum.KeyCode.R then
					if ammo.Value <= 0 then
						onreload:FireServer()
						local newgui = player.PlayerGui:FindFirstChild("ToolGUI")
						if newgui then
							if reloading == false then
								reloading = true
								newgui.Frame.Ammo.Text = "Reloading..."
								wait(1)
								equip()
								wait(0.04)
								reloading = false
							end
						end
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function look()
		local success, errormessage = pcall(function()
			local CameraCFrame = Camera.CoordinateFrame

			if Character:FindFirstChild("UpperTorso") and Character:FindFirstChild("Head") then
				local TorsoLookVector = Torso.CFrame.LookVector
				local HeadPosition = Head.CFrame.p

				if Neck and Waist then
					if Camera.CameraSubject:IsDescendantOf(Character) or Camera.CameraSubject:IsDescendantOf(player) then
						local Point = mouse.Hit.p

						local Distance = (Head.CFrame.p - Point).Magnitude
						local Difference = Head.CFrame.Y - Point.Y

						Neck.C0 = Neck.C0:Lerp(NeckOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 1, 0), 0.5 / 2)
						Waist.C0 = Waist.C0:Lerp(WaistOriginC0 * CFrame.Angles(-(math.atan(Difference / Distance) * 0.5), (((HeadPosition - Point).Unit):Cross(TorsoLookVector)).Y * 0.5, 0), 0.5 / 2)
					end
				end
			end	
		end)

		if not success then
			warn(errormessage)
		end
	end

	tool.Activated:Connect(shoot)
	tool.Deactivated:Connect(deactivate)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	runservice.RenderStepped:Connect(look)
	userinputservice.InputBegan:Connect(reload) 
end


print("Client-Sided Loaded - From Flamethrower")
mainclass()
