local function mainclass()
	local tool = script.Parent
	local values = tool:WaitForChild("Settings")
	local events = tool:WaitForChild("Events")
	local ammo = values:WaitForChild("Ammo")
	local clipsize = values:WaitForChild("ClipSize")
	local firerate = values:WaitForChild("FireRate")
	local damage = values:WaitForChild("Damage")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local spread = values:WaitForChild("Spread")
	local headshotmultiplier = values:WaitForChild("HeadShotMultiplier")
	local torsoshotmultiplier = values:WaitForChild("TorsoShotMultiplier")
	local money = values:WaitForChild("PerKill")
	local shoot_part = tool:WaitForChild("ShootPart")
	local body = tool:WaitForChild("Body")
	local ejection = tool:WaitForChild("EjectionPart")
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local onknife = events:WaitForChild("OnKnife")
	local onzoom = events:WaitForChild("OnZoom")
	local onkill = events:WaitForChild("OnKill")
	local oncrouch = events:WaitForChild("OnCrouch")
	local onsprint = events:WaitForChild("OnSprint")
	local gui = tool:WaitForChild("ToolGUI")
	
	local deathsounds = {
		"rbxassetid://358435412",
		"rbxassetid://358435460",
		"rbxassetid://178646271",
		"rbxassetid://4593020878",
		"rbxassetid://400113067",
		"rbxassetid://5300002922"
	}
	
	local Workspace = game:GetService("Workspace")
	local ServerStorage = game:GetService("ServerStorage")
	local runservice = game:GetService("RunService")
	local player = game.Players:GetPlayerFromCharacter(script.Parent.Parent) or script.Parent.Parent.Parent
	local character
	local method
	local bayonet = false
	local debounce = false
	local reloading = false
	local equipped = false

	local function equip()
		local success, errormessage = pcall(function()
			if equipped == false then
				equipped = true

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
				local newgui = gui:Clone()
				newgui.Parent = player.PlayerGui
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function unequip()
		local success, errormessage = pcall(function()
			if equipped == true and bayonet == false then
				equipped = false
				reloading = false

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
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function reload()
		
		local success, errormessage = pcall(function()
			local function reloadsuccesssound()
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

			local function reloadfailuresound()
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
			
			if reloading == false and equipped == true and bayonet == false then
				if reserveammo.Value > 0 then
					reloading = true

					if ammo.Value == 0 then
						ammo.Value = clipsize.Value
						reserveammo.Value -= clipsize.Value 
					elseif ammo.Value == clipsize.Value then
						ammo.Value += 1
						reserveammo.Value -= 1
					else
						reserveammo.Value -= clipsize.Value - ammo.Value
						ammo.Value = clipsize.Value 
					end
					reloadsuccesssound()
					local clip = tool.Mag:Clone()
					clip.CFrame = CFrame.new(body.Position)
					clip.Transparency = 0
					clip.Weld:Destroy()
					clip.Parent = game.Workspace
					wait(1)
					reloading = false
				elseif ammo > 0 and ammo < clipsize + 1 then 
					print("Not out of Ammo!")
				else
					ammo.Value = 0
					print("Returned to 0 ammo.")
				end
			else
				reloadfailuresound()
			end
		end)
		
		if not success then 
			warn(errormessage)
		end
	end

	local function shoot(player, position)
		local success, errormessage = pcall(function()
			if debounce == false and reloading == false and equipped == true and bayonet == false then
				if ammo.Value >= 1 then

					debounce = true

					local function sound()
						local sound = Instance.new("Sound", tool)
						sound.SoundId = "rbxassetid://168436671" 
						sound.Volume = 0.5
						sound.PlaybackSpeed = 1
						sound:Play()
						coroutine.resume(coroutine.create(function()
							wait(1.358)
							sound:Destroy()
						end))
					end

					ammo.Value -= 1
					sound()
					local origin = shoot_part.Position
					
					local direction = (position - origin).Unit*300
					
					local spreadPosition = Vector3.new(
						origin.X + math.random(-spread.Value, spread.Value) / spread.Value,
						origin.Y + math.random(-spread.Value, spread.Value) / spread.Value,
						origin.Z + math.random(-spread.Value, spread.Value) / spread.Value
					)
					
					local result = Workspace:Raycast(spreadPosition, direction) 

					local intersection = result and result.Position or origin + direction
					local distance = (origin - intersection).Magnitude
					
					local bullet_clone = Instance.new("Part")
					local bodyvelocity = Instance.new("BodyPosition", bullet_clone) 
					local beam = Instance.new("Beam", bullet_clone)
					local attachment1 = Instance.new("Attachment", shoot_part)
					local attachment2 = Instance.new("Attachment", bullet_clone)
					attachment1.Name = "Attachment0"
					attachment2.Name = "Attachment1"
					bullet_clone.Name = "Bullet"
					bullet_clone.Anchored = false
					bullet_clone.Size = Vector3.new(0.05, 0.05, 0.5)
					bullet_clone.Transparency = 1
					bullet_clone.CanCollide = false
					bullet_clone.BrickColor = BrickColor.new("New Yeller")
					bullet_clone.CFrame = CFrame.new(origin, intersection)*CFrame.new(0, 0, -distance/2)  
					attachment1.Position = Vector3.new(bullet_clone.Position)
					attachment2.Position = Vector3.new(bullet_clone.Position)
					beam.Width0 = 0.05
					beam.Width1 = 0.05
					beam.Attachment0 = attachment1
					beam.Attachment1 = attachment2
					bullet_clone.Parent = Workspace
					bodyvelocity.P = 100000
					bodyvelocity.D = 10000
					bodyvelocity.MaxForce = Vector3.new(10000, 10000, 10000)
					if result then
						bodyvelocity.Position = shoot_part.Position
						wait(0.04)
						bodyvelocity.Position = result.Position
					end
					
					local shell = tool.Shell:Clone()
					for i, v in pairs(shell:GetChildren()) do
						v:Destroy()
					end
					shell.Parent = game.Workspace
					shell.CFrame = CFrame.new(ejection.Position)
					shell.Velocity = shell.Velocity + Vector3.new(0, 20, 0)
					
					if result then
						local part = result.Instance
						local humanoid = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
						if humanoid then
							if humanoid.Parent ~= script.Parent.Parent then
								if part.Name == "Head" then
									humanoid:TakeDamage(damage.Value * headshotmultiplier.Value)
								elseif part.Name == "Torso" then
									humanoid:TakeDamage(damage.Value * torsoshotmultiplier.Value)
								else
									humanoid:TakeDamage(damage.Value) 
								end		
								
								--[[
								if humanoid.Health <= 0 then
									method = "Bullets"
									player.leaderstats.[leaderstatsvalue].Value += money
									local killbar = player.PlayerGui.ToolGUI.KillBar
									local clone = script.Sample:Clone()
									local name = part.Parent:WaitForChild("Humanoid").Parent.Name
									clone.Parent = killbar 
									clone:FindFirstChild("Name").Text = "Killed "..name.." via "..method
									clone.Position = UDim2.new(0, 0, (0.8 * #killbar:GetChildren()), 0)
									wait(1)
									clone:Destroy()
								end
								--]]
								
							end 
						end
					end

					wait(firerate.Value)
					debounce = false
					bullet_clone:Destroy()
					wait(5)
					shell:Destroy()
				end
			end
		end)
		
		if not success then 
			warn(errormessage)
		end
	end
	
	local function knife(player, hasBayonet)
		local success, errormessage = pcall(function()
			bayonet = hasBayonet
			local activiated = false
			local knifedebounce = false
			local knifedebounce2 = false
			if bayonet == true then
				tool.Blade.Transparency = 0
				tool.Blade.CanTouch = true
				
				local function knifesound()
					local sound = Instance.new("Sound", tool)
					sound.SoundId = "rbxassetid://6400852636" 
					sound.Volume = 0.5
					sound.PlaybackSpeed = 1
					sound:Play()
					coroutine.resume(coroutine.create(function()
						wait(1.358)
						sound:Destroy()
					end))
				end
				
				local function activiation()
					
					activiated = true
					if bayonet == false then return end
					if equipped == true then
						if knifedebounce == false then
							knifedebounce = true 
							knifesound()
							wait(1)
							knifedebounce = false
						end
					end
				end
				
				local function onTouched(hit)

					if activiated == true then
						local function hitsound()
							local sound = Instance.new("Sound", tool)
							sound.SoundId = "rbxassetid://5955549918" 
							sound.Volume = 0.5
							sound.PlaybackSpeed = 1
							sound:Play()
							coroutine.resume(coroutine.create(function()
								wait(1.358)
								sound:Destroy()
							end))
						end

						if hit then
							if knifedebounce == false then
								knifedebounce2 = true
								if hit.Parent:FindFirstChild("Humanoid") then
									hitsound()
									if hit.Name == "Head" then
										hit.Parent.Humanoid:TakeDamage(100)
									elseif hit.Name == "Torso" then
										hit.Parent.Humanoid:TakeDamage(50)
									else
										hit.Parent.Humanoid:TakeDamage(10)
									end
									
									--[[
									if humanoid.Health <= 0 then
										method = "Bayonet"
										player.leaderstats.[leaderstatsvalue].Value += money
										local killbar = player.PlayerGui.ToolGUI.KillBar
										local clone = script.Sample:Clone()
										local name = part.Parent:WaitForChild("Humanoid").Parent.Name
										clone.Parent = killbar 
										clone:FindFirstChild("Name").Text = "Killed "..name.." via "..method
										clone.Position = UDim2.new(0, 0, (0.8 * #killbar:GetChildren()), 0)
										wait(1)
										clone:Destroy()
									end
									--]]
									
									wait(1)
									knifedebounce2 = false
									activiated = false
								end
							end
						end
					end
				end

				tool.Blade.Touched:Connect(onTouched)
				tool.Activated:Connect(activiation)
				
			elseif bayonet == false then
				tool.Blade.Transparency = 1
				tool.Blade.CanTouch = false
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	
	local function crouch(player, crouching, prone)
		
		local success, errormessage = pcall(function()
			if equipped == true then
				if prone == false then
					if crouching == false then
						player.Character.Humanoid.WalkSpeed = 0
					elseif crouching == true then
						player.Character.Humanoid.WalkSpeed = 16
					end
				elseif prone == true then
					player.Character.Humanoid.WalkSpeed = 16
				end
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	
	local function death()
		local success, errormessage = pcall(function()
			if equipped == true then
				local waittime = 1000
				local character = script.Parent.Parent

				local function died()

					if character then

						local function deathsound()
							local sound = Instance.new("Sound")
							sound.SoundId = deathsounds[math.random(1, #deathsounds)] 
							sound.Volume = 0.5
							sound.PlaybackSpeed = 1
							sound.Parent = game.Workspace
							sound:Play()
							coroutine.resume(coroutine.create(function()
								wait(1.358)
								sound:Destroy()
							end))
						end

						local function model()
							deathsound()

							local model = Instance.new("Model", workspace)
							for i, v in pairs(script.Parent:GetChildren()) do
								if v ~= script and (v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Folder") or v:IsA("ScreenGui")) then
									v:Destroy()
								end
							end

							for i, v in pairs(script.Parent:GetChildren()) do
								v.Parent = model
								if v ~= script and (v:IsA("Part") or v:IsA("MeshPart") or v:IsA("UnionOperation")) then
									v.CanCollide = true
								end
							end
							wait(waittime)
							game:GetService("Debris"):AddItem(model, 0.5)
						end

						model()
					end
				end
				died()
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	
	local function zoom(player, isZoomed)
		local success, errormessage = pcall(function()
			if isZoomed == true then
				spread.Value /= 2
			elseif isZoomed == false then
				spread.Value *= 2
			end
		end)
	
		if not success then
			warn(errormessage)
		end
	end
	
	local function sprinting(player, isSprinting)
		local success, errormessage = pcall(function()
			if isSprinting == true then
				player.Character.Humanoid.WalkSpeed = 32
			elseif isSprinting == false then
				player.Character.Humanoid.WalkSpeed = 16
			end 
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	onshoot.OnServerEvent:Connect(shoot)
	onreload.OnServerEvent:Connect(reload)
	onknife.OnServerEvent:Connect(knife)
	onzoom.OnServerEvent:Connect(zoom)
	onsprint.OnServerEvent:Connect(sprinting)
	oncrouch.OnServerEvent:Connect(crouch)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
	player.Character.Humanoid.Died:Connect(death)
end

script.Parent.Instructions:Destroy() 
print("Starting up server-sided script(From AK-47)")
mainclass()
