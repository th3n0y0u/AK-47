local function mainclass()
	local tool = script.Parent
	local events = tool:WaitForChild("Events")
	local values = tool:WaitForChild("Settings")
	local onshoot = events:WaitForChild("OnShoot")
	local ondeactivate = events:WaitForChild("OnDeactivate")
	local onreload = events:WaitForChild("OnReload")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local damage = values:WaitForChild("Damage")
	local mag = tool:WaitForChild("Mag")
	local shooting = false 

	local function reload()
		
		local success, errormessage = pcall(function()
			if ammo.Value <= 0 then
				if shooting == false then
					
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
					
					reserveammo.Value -= clipsize.Value - ammo.Value
					ammo.Value = clipsize.Value
					
					mag.Transparency = 1
					local clone = mag:Clone()
					clone.Transparency = 0
					for i, v in pairs(clone:GetChildren()) do 
						v:Destroy() 
					end
					clone.CFrame = CFrame.new(mag.Position) 
					clone.CanCollide = true
					clone.Parent = game.Workspace
					mag.Transparency = 0
					reloadsound() 
					wait(10)
					game:GetService("Debris"):AddItem(clone, 1) 
					 
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function deactiviate()
		
		local success, errormessage = pcall(function()
			if shooting == true then
				shooting = false
				tool.HitBox.CanTouch = false 
				local fire = tool.ShootPart:GetChildren()
				local sound = tool:GetChildren()

				if fire then

					if sound then	

						for i, v in pairs(fire) do
							if v:IsA("ParticleEmitter") then
								game:GetService("Debris"):AddItem(v, 1)
							end
						end

						for i, v in pairs(sound) do
							if v:IsA("Sound") and v.Name == "ShootSound" then
								game:GetService("Debris"):AddItem(v, 1)
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

	local function shoot(player, position)
		
		local success, errormessage = pcall(function()
			if shooting == false and ammo.Value > 0 then
				shooting = true
				tool.HitBox.CanTouch = true

				local function shootsound()
					local sound = Instance.new("Sound", tool)
					sound.Name = "ShootSound"
					sound.SoundId = "rbxassetid://6195348115" 
					sound.Volume = 1
					sound.PlaybackSpeed = 1
					sound.Looped = true
					sound:Play()
				end
				
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = {
					tool.Parent:GetChildren(),
					tool.ShootPart
				}
				
				local origin = script.Parent.ShootPart.Position
				local direction = (position - origin).Unit*4
				
				if tool.ShootPart:FindFirstChild("Fire") == nil then
					local fire = script.ParticleEmitter:Clone()
					fire.Enabled = true
					fire.Parent = tool.ShootPart
				
					local raycast = workspace:Raycast(origin, direction, raycastParams)
					
					if raycast then
						
						local part = raycast.Instance
						local char = part.Parent
						
						if char then
							if char:FindFirstChild("Humanoid") then
								
								wait(0.04)
								if char.Head:FindFirstChild("Fire") == nil then
									for i, v in pairs(char:GetChildren()) do
										if v:IsA("MeshPart") or v:IsA("Part") then
											local partfire = Instance.new("Fire")
											partfire.Heat = 5
											partfire.Size = 5
											partfire.Parent = v
										end
									end
									
									local count = 0
									
									while count < 10 and wait() do
										if count <= 3 then
											char.Humanoid:TakeDamage(damage.Value * 2)
										else
											char.Humanoid:TakeDamage(damage.Value / 4)
										end
										
										if count >= 10 then
											
											for i, v in pairs(char:GetChildren()) do
												local destroy = v:WaitForChild("Fire")
												
												if destroy then
													game:GetService("Debris"):AddItem(destroy, 1)
												end
											end
											
											break
											
										else
											continue
										end
									end
								end
								
							end
						end
					end
					
					local function touched(part)
						local char = part.Parent
						if char and part then
							if char:FindFirstChild("Humanoid") then
								wait(0.04)
								if char.Head:FindFirstChild("Fire") == nil then
									for i, v in pairs(char:GetChildren()) do
										if v:IsA("MeshPart") or v:IsA("Part") then
											local partfire = Instance.new("Fire")
											partfire.Heat = 5
											partfire.Size = 5
											partfire.Parent = v
										end
									end

									local count = 0

									while count < 10 and wait() do
										if count <= 3 then
											char.Humanoid:TakeDamage(damage.Value * 2)
										else
											char.Humanoid:TakeDamage(damage.Value / 4)
										end

										if count >= 10 then

											for i, v in pairs(char:GetChildren()) do
												local destroy = v:WaitForChild("Fire")

												if destroy then
													game:GetService("Debris"):AddItem(destroy, 1)
												end
											end

											break

										else
											continue
										end
									end
								end
							end
						end
					end
					
					shootsound()
					
					while shooting == true and wait(0.04) do
						if ammo.Value > 0 then
							ammo.Value -= 1
						else
							deactiviate()
						end
					end
					
					tool.HitBox.Touched:Connect(touched) 
					wait(1)
					shooting = false
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
		
	end

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
		end
		
	end

	onshoot.OnServerEvent:Connect(shoot)
	ondeactivate.OnServerEvent:Connect(deactiviate)
	onreload.OnServerEvent:Connect(reload)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
end

script.Parent.Instructions:Destroy() 
print("Server-Sided Loaded - From Flamethrower")
mainclass()
