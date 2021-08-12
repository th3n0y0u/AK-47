local function mainclass()
	local tool = script.Parent
	local player = game.Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local userinputservice = game:GetService("UserInputService")
	local runservice = game:GetService("RunService")
	local humanoid = char:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local mouse = player:GetMouse()
	local events = tool:WaitForChild("Events")
	local values = tool:WaitForChild("Settings")
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local onbayonet = events:WaitForChild("OnBayonet")
	local onsprint = events:WaitForChild("OnSprint")
	local onstab = events:WaitForChild("OnStab")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local gui = tool:WaitForChild("ToolGUI")
	local equipped = false
	local reloading = false
	local hasBayonet = false
	local zoomed = false
	local sprinting = false

	local Players = game:GetService("Players")
	local client = Players.LocalPlayer
	local animator = char:WaitForChild("Humanoid"):WaitForChild("Animator") 
	local cursor = client:GetMouse() 
	local userinputservice = game:GetService("UserInputService")
	local Camera = workspace.CurrentCamera
	local Head = char:WaitForChild("Head")
	local Neck = Head:WaitForChild("Neck")
	local Torso = char:WaitForChild("UpperTorso")
	local Waist = Torso:WaitForChild("Waist")
	local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	local NeckOriginC0 = Neck.C0
	local WaistOriginC0 = Waist.C0 

	local animations = {
		script.Shoot,
		script.Reload,
		script.Equip,
		script.Unequip,
		script.BayonetEquip,
		script.BayonetUnequip
	}

	local loadedanimations = {
		animator:LoadAnimation(animations[1]),
		animator:LoadAnimation(animations[2]),
		animator:LoadAnimation(animations[3]),
		animator:LoadAnimation(animations[4]),
		animator:LoadAnimation(animations[5]),
		animator:LoadAnimation(animations[6])  
	}

	Neck.MaxVelocity = 1/2 

	local function equip()
		local success, errormessage = pcall(function()
			if equipped == false then
				equipped = true
			
				loadedanimations[3]:Play()
				local clone = gui:Clone()
				clone.Parent = player.PlayerGui
			
				while equipped == true and reloading == false and hasBayonet == false and wait() do 
					
					if equipped == false then
						break
					elseif reloading == true then
						while wait() do
							if reloading == false then
								break
							end
						end
					else
						clone.Frame.Ammo.Text = tostring(ammo.Value).."/5" 
						clone.Frame.ReserveAmmo.Text = reserveammo.Value 
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
				reloading = false
				local length = loadedanimations[4].Length
				loadedanimations[3]:Stop()
				loadedanimations[4]:Play()
				local toolgui = player.PlayerGui:WaitForChild("ToolGUI")
				toolgui:Destroy()
				loadedanimations[4]:Stop()
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function reload(input, gameprocessed)
		local success, errormessage = pcall(function()
			if input ~= nil then
				if input.KeyCode == Enum.KeyCode.R then
					if reloading == false and equipped == true and hasBayonet == false then
						if ammo.Value <= clipsize.Value and reserveammo.Value >= 1 then

							local animationlength = loadedanimations[2].Length
							loadedanimations[2]:Play()
							reloading = true 
							local newgui = player.PlayerGui:WaitForChild("ToolGUI")

							if newgui then
								newgui.Frame.Ammo.Text = "Reloading..."
								onreload:FireServer() 
								wait(animationlength)
								wait(2) -- temp until animation 
								newgui.Frame.Ammo.Text = ammo.Value.."/"..ammo.Value
							end

							reloading = false
							loadedanimations[2]:Stop()
						else
							print("No.")
						end
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function shoot()
		local success, errormessage = pcall(function()
			if equipped == true and reloading == false and hasBayonet == false then
				loadedanimations[1]:Play()
				onshoot:FireServer(mouse.Hit.Position)
				loadedanimations[1]:Stop()
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function bayonet(input, gameproccessed)
		local success, errormessage = pcall(function()
			if input then
				if input.KeyCode == Enum.KeyCode.B then
					if hasBayonet == true then
						hasBayonet = false
						local length = loadedanimations[5].Length
						loadedanimations[5]:Play()
						wait(length)
						loadedanimations[5]:Stop()
						humanoid:UnequipTools()
						humanoid:EquipTool(tool) 
					elseif hasBayonet == false then
						hasBayonet = true
						local length = loadedanimations[6].Length
						loadedanimations[6]:Play()
						wait(length)
						loadedanimations[6]:Stop()
					end
					onbayonet:FireServer(hasBayonet)
				elseif input.KeyCode == Enum.KeyCode.X then
					if hasBayonet == true then
						onstab:FireServer()
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function zoom(input, gameproccessed)
		local success, errormessage = pcall(function()
			local cam = game.Workspace.Camera
			if input ~= nil then
				if input.UserInputType == Enum.UserInputType.MouseButton2 then
					if zoomed == false then
						zoomed = true
						cam.FieldOfView = 30
					elseif zoomed == true then
						zoomed = false
						cam.FieldOfView = 70
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

			if char:FindFirstChild("UpperTorso") and char:FindFirstChild("Head") then 
				local TorsoLookVector = Torso.CFrame.LookVector
				local HeadPosition = Head.CFrame.p

				if Neck and Waist then
					if Camera.CameraSubject:IsDescendantOf(char) or Camera.CameraSubject:IsDescendantOf(client) then
						local Point = cursor.Hit.p

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

	local function sprint(input, gameproccessed)
		local success, errormessage = pcall(function()
			if input then
				if input.KeyCode == Enum.KeyCode.LeftShift then
					if sprinting == false then
						sprinting = true
						onsprint:FireServer(sprinting)
					elseif sprinting == true then
						sprinting = false  
						onsprint:FireServer(sprinting)
					end
				end
			end
		end)

		if not success then
			warn(errormessage)
		end
	end

	tool.Activated:Connect(shoot)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	userinputservice.InputBegan:Connect(reload)
	userinputservice.InputBegan:Connect(bayonet)
	userinputservice.InputBegan:Connect(zoom)
	userinputservice.InputBegan:Connect(sprint)
	runservice.RenderStepped:Connect(look)
end

print("Client-Sided script loaded - from Kar98k")
mainclass()
