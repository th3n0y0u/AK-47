local function mainclass()
	local tool = script.Parent
	local values = tool:WaitForChild("Settings")
	local events = tool:WaitForChild("Events")
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local onknife = events:WaitForChild("OnKnife")
	local onzoom = events:WaitForChild("OnZoom")
	local onsprint = events:WaitForChild("OnSprint")
	local oncrouch = events:WaitForChild("OnCrouch")
	local onheat = events:WaitForChild("OnHeat")
	local userinputservice = game:GetService("UserInputService")
	local runservice = game:GetService("RunService")
	local ammo = values:WaitForChild("Ammo")
	local clipsize = values:WaitForChild("ClipSize")
	local firerate = values:WaitForChild("FireRate")
	local damage = values:WaitForChild("Damage")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local spread = values:WaitForChild("Spread")
	local gui = tool:WaitForChild("ToolGUI")
	local heat = tool:WaitForChild("HeatBar")
	local sprinting = false 
	local hasBayonet = false
	local reloading = false
	local equipped = false
	local zoomed = false
	local crouching = false
	local prone = false
	local jammed = false
	local heatvalue = 0

	local Players = game:GetService("Players")
	local client = Players.LocalPlayer
	local animator = client.Character:WaitForChild("Humanoid"):WaitForChild("Animator")
	local cursor = client:GetMouse() 
	local userinputservice = game:GetService("UserInputService")
	local Camera = workspace.CurrentCamera
	local Character = client.Character or client.CharacterAdded:Wait()
	local Head = Character:WaitForChild("Head")
	local Neck = Head:WaitForChild("Neck")
	local Torso = Character:WaitForChild("UpperTorso")
	local Waist = Torso:WaitForChild("Waist")
	local Humanoid = Character:WaitForChild("Humanoid")
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	local NeckOriginC0 = Neck.C0
	local WaistOriginC0 = Waist.C0 
	
	local animations = {
		script:WaitForChild("Equip"),
		script:WaitForChild("Unequip"),
		script:WaitForChild("Reload"), 
		script:WaitForChild("Aim"), 
		script:WaitForChild("KnifeEquip"),
		script:WaitForChild("KnifeUnequip"), 
		script:WaitForChild("Sprinting"), 
		script:WaitForChild("Crouch"), 
		script:WaitForChild("Prone"),
	}
	
	local loadanimations = {
		animator:LoadAnimation(animations[1]), 
		animator:LoadAnimation(animations[2]), 
		animator:LoadAnimation(animations[3]),
		animator:LoadAnimation(animations[4]), 
		animator:LoadAnimation(animations[5]), 
		animator:LoadAnimation(animations[6]), 
		animator:LoadAnimation(animations[7]), 
		animator:LoadAnimation(animations[8]), 
		animator:LoadAnimation(animations[9])
	}
	
	Neck.MaxVelocity = 1/2

	local function equip()
		local success, errormessage = pcall(function()
			if equipped == false and hasBayonet == false then
				equipped = true
				local newheat = heat:Clone()
				newheat.Parent = tool.Body 
				newheat.Enabled = true
				local animationlength = loadanimations[1].Length
				loadanimations[1]:Play()
				client.CameraMode = Enum.CameraMode.LockFirstPerson
				cursor.Icon = "rbxassetid://117431027";
				local newgui = client.PlayerGui:WaitForChild("ToolGUI")
				if equipped == true and reloading == false then
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
							newgui.Frame.Ammo.Text = ammo.Value.."/"..clipsize.Value
							newgui.Frame.ReserveAmmo.Text = reserveammo.Value
							
							newheat.BarFrame.Bar.Size = UDim2.new(0.01 * heatvalue, 0, 0, 0)  
							if heatvalue ~= 0 then
								heatvalue -= 0.1
							end
							if heatvalue < 50 then
								newheat.BarFrame.Bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
							elseif heatvalue >= 51 then
								newheat.BarFrame.Bar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
							elseif heatvalue >= 75 then
								newheat.BarFrame.Bar.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
							end
						end
						if client.Character.Humanoid.Health < 0 then
							Camera.CameraMode = Enum.CameraMode.Classic
						end
					end
					wait(animationlength)
					loadanimations[1]:Stop()
				else
					print("No.")
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function unequip()
		local success, errormessage = pcall(function()
			if equipped == true and hasBayonet == false then
				equipped = false
				reloading = false
				local animationlength = loadanimations[2].Length
				loadanimations[2]:Play()
				client.CameraMode = Enum.CameraMode.Classic
				cursor.Icon = "rbxassetid://0"; 
				if client.PlayerGui:FindFirstChild("ToolGUI") ~= nil then
					local newgui = client.PlayerGui:FindFirstChild("ToolGUI")
					newgui:Destroy()
				else
					local newgui = client.PlayerGui:WaitForChild("ToolGUI")
					newgui:Destroy()
				end
				wait(animationlength)
				loadanimations[2]:Stop()
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
						if ammo.Value <= clipsize.Value then
							
							local animationlength = loadanimations[3].Length
							loadanimations[3]:Play()
							reloading = true 
							local newgui = client.PlayerGui:WaitForChild("ToolGUI")
							
							if newgui then
								newgui.Frame.Ammo.Text = "Reloading..."
								onreload:FireServer() 
								wait(animationlength)
								wait(1) -- temp until animation
								newgui.Frame.Ammo.Text = clipsize.Value.."/"..clipsize.Value
							end
						
							if jammed == true then
								jammed = false
							end
							
							reloading = false
							loadanimations[3]:Stop()
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
	
	local function knife(input, gameproccessed)
		
		local success, errormessage = pcall(function()
			if input ~= nil then
				if input.KeyCode == Enum.KeyCode.B then
					if reloading == false and equipped == true and hasBayonet == false then
						hasBayonet = true
						local animationlength = loadanimations[5].Length
						loadanimations[5]:Play()
						wait(animationlength)
						
						onknife:FireServer(hasBayonet)
						local newgui = client.PlayerGui:WaitForChild("ToolGUI")
						newgui.Frame.Ammo.Text = "Using Bayonet"
						
					elseif hasBayonet == true and reloading == false and equipped == true then 
						hasBayonet = false
						local animationlength2 = loadanimations[6].Length
						loadanimations[6]:Play()
						wait(animationlength2)
						
						onknife:FireServer(hasBayonet)
						
						local newgui = client.PlayerGui:WaitForChild("ToolGUI")
						newgui.Frame.Ammo.Text = ammo.Value.."/"..clipsize.Value
						
						Humanoid:UnequipTools()
						Humanoid:EquipTool(tool)
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
			if reloading == false and equipped == true and hasBayonet == false and jammed == false then 
				
				loadanimations[4]:Play()
				onshoot:FireServer(cursor.Hit.Position)
				heatvalue += 1
				loadanimations[4]:Stop()
				if heatvalue >= 100 then
				
					local explosion = Instance.new("Explosion")
					explosion.BlastRadius = 10
					explosion.ExplosionType = "NoCraters"
					explosion.BlastPressure = 1000000
					explosion.Parent = client.Character.Head
					
					for i, v in pairs(client.Character:GetChildren()) do
						if v:IsA("MeshPart") or v:IsA("Part") then
							local fire = Instance.new("Fire")
							fire.Heat = 10
							fire.Size = 10
							fire.Parent = v
						end
					end
					
					heatvalue = 0
					client.CameraMode = Enum.CameraMode.Classic
					local newheat = tool.Body:WaitForChild("HeatBar")
					newheat:Destroy()
					cursor.Icon = "rbxassetid://0";  
					
					onheat:FireServer(client.Character)
					
				end
				
				local num = math.random(1, 100)
				if num == 57 then
					if jammed == false then
						jammed = true
					end
				end
				
			else
				print("Not Reloading...")
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
						onzoom:FireServer(zoomed)
						cam.FieldOfView = 30
					elseif zoomed == true then
						zoomed = false
						onzoom:FireServer(zoomed)
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

			if Character:FindFirstChild("UpperTorso") and Character:FindFirstChild("Head") then
				local TorsoLookVector = Torso.CFrame.LookVector
				local HeadPosition = Head.CFrame.p

				if Neck and Waist then
					if Camera.CameraSubject:IsDescendantOf(Character) or Camera.CameraSubject:IsDescendantOf(client) then
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
					loadanimations[7]:Play()
					if sprinting == false then
						sprinting = true
						onsprint:FireServer(sprinting)
					elseif sprinting == true then
						sprinting = false  
						onsprint:FireServer(sprinting)
						loadanimations[7]:Stop() 
					end
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	
	local function crouch(input, gameproccessed)
		local success, errormessage = pcall(function()
			if input then
				if input.KeyCode == Enum.KeyCode.C then
					if prone == false then
						if crouching == false then
							crouching = true
							
							oncrouch:FireServer(crouching, prone)
							loadanimations[8]:Play()
						elseif crouching == true then
							crouching = false
							prone = true
							
							oncrouch:FireServer(crouching, prone)
							loadanimations[8]:Stop()
							wait(1)
							loadanimations[9]:Play()
						end
					elseif prone == true and crouching == false then
						prone = false
						
						oncrouch:FireServer(crouching, prone)
						loadanimations[9]:Stop()
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
			
			cursor.Icon = "rbxassetid://0"; 
			client.CameraMode = Enum.CameraMode.Classic 
			
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	
	tool.Activated:Connect(shoot)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	userinputservice.InputBegan:Connect(reload)
	userinputservice.InputBegan:Connect(knife)
	userinputservice.InputBegan:Connect(zoom)
	userinputservice.InputBegan:Connect(sprint)
	userinputservice.InputBegan:Connect(crouch)
	runservice.RenderStepped:Connect(look)
	client.Character.Humanoid.Died:Connect(died)
end

print("Starting up client-sided script(From AK-47)")
mainclass()
