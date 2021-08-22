local function mainclass()
	
	local tool = script.Parent
	local players = game:GetService("Players")
	local player = players.LocalPlayer
	local char = (player.Character or player.CharacterAdded:Wait())
	local humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local userinputservice = game:GetService("UserInputService")
	local runservice = game:GetService("RunService")
	local events = tool:WaitForChild("Events")
	local values = tool:WaitForChild("Settings")
	local damage = values:WaitForChild("Damage")
	local spread = values:WaitForChild("Spread")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local mouse = player:GetMouse()
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local gui = tool:WaitForChild("ToolGUI")
	local reloading = false
	local equipped = false

	local userinputservice = game:GetService("UserInputService")
	local Camera = workspace.CurrentCamera
	local Head = char:WaitForChild("Head")
	local Neck = Head:WaitForChild("Neck") or Head:FindFirstChildOfClass("Motor6D")
	local Torso = char:WaitForChild("UpperTorso")
	local Waist = Torso:WaitForChild("Waist")
	local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local NeckOriginC0 = Neck.C0
	local WaistOriginC0 = Waist.C0 

	Neck.MaxVelocity = 1/2 
	 
	local animations = {
		script.Equip,
		script.Unequip,
		script.Reload
	}

	local loadedanimations = {
		animator:LoadAnimation(animations[1]),
		animator:LoadAnimation(animations[2]),
		animator:LoadAnimation(animations[3]) 
	}

	local function equip()
		
		local success, errormessage = pcall(function()
			
			if equipped == false then
				equipped = true
				
				player.CameraMode = Enum.CameraMode.LockFirstPerson
				mouse.Icon = "rbxassetid://117431027";
				game.ReplicatedStorage.ConnectM6D:FireServer(tool.BodyAttach)
				char.UpperTorso.ToolGrip.Part0 = char.UpperTorso
				char.UpperTorso.ToolGrip.Part1 = tool.BodyAttach 
				loadedanimations[1]:Play()
				local newgui = gui:Clone()
				newgui.Parent = player.PlayerGui
				
				while reloading == false and equipped == true and wait() do
					if equipped == false then
						wait()
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
				end
			end
			
		end)
		
		if not success then
			warn(errormessage)
		end
		
	end

	local function reload(input, gameprocessed)
		
		local success, errormessage = pcall(function()
			
			if input then
				if input.KeyCode == Enum.KeyCode.R then
					if ammo.Value >= 0 then
						if reloading == false and equipped == true then
							reloading = true
							local newgui = player.PlayerGui:FindFirstChild("ToolGUI")
							if not newgui then return end
							if newgui then
								local length = loadedanimations[3].Length
								loadedanimations[3]:Play()
								newgui.Frame.Ammo.Text = "Reloading..."
								onreload:FireServer() 
								wait(1)
								wait(length)
								reloading = false
								equip()
								loadedanimations[3]:Stop()
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
	 
	local function unequip()
		
		local success, errormessage = pcall(function()
			
			if equipped == true then
				equipped = false
				local newgui = player.PlayerGui:FindFirstChild("ToolGUI")
				if newgui then
					newgui:Destroy()
					player.CameraMode = Enum.CameraMode.Classic
					mouse.Icon = "rbxassetid://0";
					game.ReplicatedStorage.DisconnectM6D:FireServer()  
					loadedanimations[1]:Stop()
					local length = loadedanimations[2].Length
					loadedanimations[2]:Play()
					wait(length)
					loadedanimations[2]:Stop()
				end
			end
			
		end)
		
		if not success then
			warn(errormessage)
		end
		
	end

	local function shoot()
		
		local success, errormessage = pcall(function()
			
			if equipped == true and reloading == false then
				onshoot:FireServer(mouse.Hit.Position)
			end
			
		end)
		
		if not success then
			warn(errormessage)
		end
		
	end

	local function look()
		local success, errormessage = pcall(function()
			
			local CameraCFrame = Camera.CoordinateFrame

			if char:FindFirstChild("UpperTorso") and char:FindFirstChild("Head") then 
				local TorsoLookVector = Torso.CFrame.LookVector
				local HeadPosition = Head.CFrame.p

				if Neck and Waist then
					if Camera.CameraSubject:IsDescendantOf(char) or Camera.CameraSubject:IsDescendantOf(player) then
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
	
	local function died()
		local success, errormessage = pcall(function()
			mouse.Icon = "rbxassetid://0"; 
			player.CameraMode = Enum.CameraMode.Classic
		end)

		if not success then
			warn(errormessage)
		end
	end 

	tool.Activated:Connect(shoot)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	userinputservice.InputBegan:Connect(reload)
	runservice.RenderStepped:Connect(look)
	char.Humanoid.Died:Connect(died)
	
end

print("Client-Sided script loaded - from pistol")
mainclass()
