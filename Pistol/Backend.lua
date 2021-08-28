local function mainclass()
	
	local tool = script.Parent
	local events = tool:WaitForChild("Events")
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local values = tool:WaitForChild("Settings")
	local shootpart = tool:WaitForChild("ShootPart")
	local damage = values:WaitForChild("Damage")
	local spread = values:WaitForChild("Spread")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local headshotmultiplier = values:WaitForChild("HeadShotMultiplier")
	local torsoshotmultiplier = values:WaitForChild("TorsoShotMultiplier")
	local debounce = false
	local errors = false

	local function equip()
		
		local success, errormessage = pcall(function()
			local function equipsound()
				local sound = Instance.new("Sound", tool)
				sound.SoundId = "rbxassetid://1498950813"
				sound.Volume = 1
				sound.PlaybackSpeed = 1
				sound:Play()
				coroutine.resume(coroutine.create(function()
					wait(1.358)
					sound:Destroy()
				end))
			end
			
			equipsound()
		end)
		
		if not success then
			warn(errormessage)
			errors = true
		end
		
	end

	local function unequip()
		
		local success, errormessage = pcall(function()
			
			local function unequipsound()
				local sound = Instance.new("Sound", tool)
				sound.SoundId = "rbxassetid://5917818749" 
				sound.Volume = 1
				sound.PlaybackSpeed = 1
				sound:Play()
				coroutine.resume(coroutine.create(function()
					wait(1.358)
					sound:Destroy()
				end))
			end 
			
			unequipsound()
			
		end)
		
		if not success then
			warn(errormessage)
			errors = true
		end
		
	end

	local function reload()
		
		local success, errormessage = pcall(function()
			
			local function reloadsound()
				local sound = Instance.new("Sound", tool)
				sound.SoundId = "rbxassetid://5214579647"
				sound.Volume = 1
				sound.PlaybackSpeed = 1
				sound:Play()
				coroutine.resume(coroutine.create(function()
					wait(1.358)
					sound:Destroy()
				end)) 
			end
			
			reloadsound()
			if reserveammo.Value > clipsize.Value then
				reserveammo.Value -= clipsize.Value - ammo.Value 
				if ammo.Value == clipsize.Value then
					ammo.Value = clipsize.Value + 1
				elseif ammo.Value >= 0 then
					ammo.Value = clipsize.Value
				end
			else
				ammo.Value = reserveammo.Value
				reserveammo.Value = 0
			end
			
			local clone = tool.Mag:Clone()
			clone.CanCollide = true
			clone.Transparency = 0 
			clone.Parent = game.Workspace
			
			tool.Mag.Transparency = 1
			
			for i, v in pairs(clone:GetChildren()) do
				v:Destroy()
			end
			
			tool.Mag.Transparency = 0
			
			wait(25)
			clone:Destroy()
		end)
		
		if not success then
			warn(errormessage)
			errors = true
		end
		
	end

	local function shoot(player, position)
		
		local success, errormessage = pcall(function()
			
			if ammo.Value >= 1 and reserveammo.Value >= 1 then
				if debounce == false then
					debounce = true
					
					local function shootsound()
						local sound = Instance.new("Sound", tool)
						sound.SoundId = "rbxassetid://4630604600" 
						sound.Volume = 1
						sound.PlaybackSpeed = 1
						sound:Play()
						coroutine.resume(coroutine.create(function()
							wait(1.358)
							sound:Destroy()
						end))
					end
					
					local raycastParams = RaycastParams.new()
					raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
					raycastParams.FilterDescendantsInstances = {
						tool.ShootPart
					}
					
					local origin = shootpart.Position
					local direction = (position - origin).Unit*150
					
					local spreadposition = Vector3.new(
						origin.X + math.random(-spread.Value, spread.Value) / spread.Value,
						origin.Y + math.random(-spread.Value, spread.Value) / spread.Value,
						origin.Z + math.random(-spread.Value, spread.Value) / spread.Value 
					)
					
					local result = game.Workspace:Raycast(spreadposition, direction, raycastParams)
					local intersection = result and result.Position or origin + direction
					local distance = (origin - intersection).Magnitude
					
					local bulletclone = Instance.new("Part")
					local shell = tool.Shell:Clone()
					bulletclone.CanCollide = false
					shell.CanCollide = true
					bulletclone.Transparency = 1
					shell.Transparency = 0
					bulletclone.Size = Vector3.new(0.01, 0.01, -distance / 2) 
					bulletclone.CFrame = CFrame.new(origin, intersection)*CFrame.new(0, 0, -distance / 2)
					bulletclone.Parent = game.Workspace
					shell.Parent = game.Workspace
					for i, v in pairs(shell:GetChildren()) do
						v:Destroy()
					end
					 
					shootsound()
					
					ammo.Value -= 1
					if result then
						local part = result.Instance
						local char = part.Parent
						if part and char then
							if char:FindFirstChild("Humanoid") then
								if part.Name == "Head" then
									char.Humanoid:TakeDamage(damage.Value * headshotmultiplier.Value)
								elseif part.Name == "Torso" then
									char.Humanoid:TakeDamage(damage.Value * torsoshotmultiplier.Value)
								else
									char.Humanoid:TakeDamage(damage.Value)
								end
							else
								local materialsounds = {
									"rbxassetid://6962155378",
									"rbxassetid://4072627278",
									"rbxassetid://2064193435",
									"rbxassetid://142082167",
									"rbxassetid://5361945710"
									
								}
								
								local function materialsound(num)
									local sound = Instance.new("Sound", tool)
									sound.SoundId = materialsounds[num]
									sound.Volume = 1
									sound.PlaybackSpeed = 1
									sound:Play()
									coroutine.resume(coroutine.create(function()
										wait(1.358)
										sound:Destroy()
									end))
								end
								
								if result.Material then
									
									if result.Material == Enum.Material.Concrete then
										materialsound(1)
									elseif result.Material == Enum.Material.Metal then
										materialsound(2)
									elseif result.Material == Enum.Material.Glass then
										materialsound(4)
									elseif result.Material == Enum.Material.Air then
										materialsound(5)
									else
										materialsound(3)
									end
								end	
								
								local function sound()
									local number = math.random(1, 10) 
									if number == 5 then

										local voices = {
											"rbxassetid://993905304",
											"rbxassetid://998679945",
											"rbxassetid://993908890",
											"rbxassetid://993907407"
										}

										local function voice()
											local sound = Instance.new("Sound", tool)
											sound.SoundId = voices[math.random(1, #voices)] 
											sound.Volume = 1
											sound.PlaybackSpeed = 1
											sound:Play()
											coroutine.resume(coroutine.create(function()
												wait(sound.TimeLength)
												sound:Destroy()
											end))
										end

										voice()
									end
								end 
	 
								sound()
							end
						end
					end
					
					local function dropshell()
						local sound = Instance.new("Sound", tool)
						sound.SoundId = "rbxassetid://5693069131" 
						sound.Volume = 0.2
						sound.PlaybackSpeed = 1
						sound:Play()
						coroutine.resume(coroutine.create(function()
							wait(1.358)
							sound:Destroy()
						end))
					end

					local function drop(hit)

						local dropdebounce = false

						if dropdebounce == false then
							dropdebounce = true
							if hit then
								if hit:IsA("Part") then
									if hit.Parent == game.Workspace["The map"] then
										dropshell()
									end
								end
							end
							wait(1)
							dropdebounce = false
						end

					end
					
					shell.Touched:Connect(drop)
					wait(0.04)
					debounce = false
					bulletclone:Destroy()
					wait(5)
					shell:Destroy()
				end
			end
			
		end)
		
		if not success then
			warn(errormessage)
			errors = true
		end
		
	end

	onshoot.OnServerEvent:Connect(shoot)
	onreload.OnServerEvent:Connect(reload)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	
	return errors
end

local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent) or script.Parent.Parent.Parent
player.CharacterAdded:Connect(function()
	script.Parent:FindFirstChild("Instructions"):Destroy()
	if script.Parent:FindFirstChild("Instructions") == nil then
		local result = mainclass()

		if result == false then
			print("Server-Sided Script loading - From Pistol")  
		elseif result == true then 
			warn("Something failed!")
			script.Parent.Events.OnError:FireClient(player)
		end
	end
end)
