local function mainclass()
	local tool = script.Parent
	local values = tool:WaitForChild("Settings")
	local events = tool:WaitForChild("Events")
	local damage = values:WaitForChild("Damage")
	local ammo = values:WaitForChild("Ammo")
	local reserveammo = values:WaitForChild("ReserveAmmo")
	local clipsize = values:WaitForChild("ClipSize")
	local headshotmultiplier = values:WaitForChild("HeadShotMultiplier")
	local torsoshotmultiplier = values:WaitForChild("TorsoShotMultiplier")
	local onshoot = events:WaitForChild("OnShoot")
	local onreload = events:WaitForChild("OnReload")
	local onbayonet = events:WaitForChild("OnBayonet")
	local onstab = events:WaitForChild("OnStab")
	local onsprint = events:WaitForChild("OnSprint")
	local shootpart = tool:WaitForChild("ShootPart")
	local bolt = tool:WaitForChild("Bolt")
	local chamber = tool:WaitForChild("Bullet Chamber")
	local debounce = false

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
			reserveammo.Value -= clipsize.Value - ammo.Value
			if ammo.Value == clipsize.Value then
				ammo.Value = clipsize.Value + 1
			elseif ammo.Value >= 0 then
				ammo.Value = clipsize.Value 
			end

			local mag = tool:WaitForChild("Mag")
			local clone = mag:Clone()
			mag.Transparency = 1 
			
			for i, v in pairs(clone:GetChildren()) do
				v:Destroy()
			end
			
			clone.Parent = game.Workspace
			
			mag.Transparency = 0
		end)
		
		if not success then
			warn(errormessage)
		end
	end
	 
	local function shoot(player, position)
		
		if ammo.Value >= 1 and reserveammo.Value >= 1 then
			if debounce == false then
				debounce = true
				
				local success, errormessage = pcall(function()
					
					local function shootsound()
						local sound = Instance.new("Sound", tool)
						sound.SoundId = "rbxassetid://335711481"
						sound.Volume = 1
						sound.PlaybackSpeed = 1
						sound:Play()
						coroutine.resume(coroutine.create(function()
							wait(sound.TimeLength)
							sound:Destroy()
						end))

						local sound2 = Instance.new("Sound", tool)
						sound2.SoundId = "rbxassetid://6129190959" 
						sound2.Volume = 1
						sound2.PlaybackSpeed = 1
						sound2:Play()
						coroutine.resume(coroutine.create(function()
							wait(sound2.TimeLength)
							sound2:Destroy()
						end))
					end
					
					local raycastParams = RaycastParams.new()

					raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

					local origin = shootpart.Position

					local direction = (position - origin).Unit*300

					local bullet_clone = Instance.new("Part")
					local shell = tool:WaitForChild("Shell"):Clone()
					shell.Transparency = 0 
					for i, v in pairs(shell:GetChildren()) do
						v:Destroy()
					end
					shell.CFrame = CFrame.new(tool.Ejection.Position)

					raycastParams.FilterDescendantsInstances = {
						tool.Shell,
						tool["Back Piece"],
						tool.Barrel,
						tool.Blade,
						tool.Body,
						tool.Bolt,
						tool.Connection,
						tool.Decor,
						tool.BladeDecor,
						tool.Goal,
						tool.Mag,
						tool.Rod,
						tool.Sight,
						tool.Stock,
						tool.TopPiece,
						tool.Trigger,
						tool["Bullet Chamber"],
						tool.Ejection,
						tool.Handle,
						tool.Holder,
						tool.Insert,
						tool.ShootPart
					}

					local result = workspace:Raycast(origin, direction, raycastParams) 
					shootsound()
					
					local intersection = result and result.Position or origin + direction
					local distance = (origin - intersection).Magnitude
					bullet_clone.Name = "Bullet"
					bullet_clone.Anchored = true
					bullet_clone.Size = Vector3.new(0.05, 0.05, distance/2)
					bullet_clone.CanCollide = false
					bullet_clone.BrickColor = BrickColor.new("New Yeller")
					bullet_clone.CFrame = CFrame.new(origin, intersection)*CFrame.new(0, 0, -distance/2)  
					bullet_clone.Parent = game.Workspace
					shell.Parent = game.Workspace 

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

						elseif not humanoid then

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
					
					ammo.Value -= 1
					shell.Touched:Connect(drop)
					wait(1)
					debounce = false
					bullet_clone:Destroy()
					wait(5)
				end)
				
				if not success then
					warn(errormessage)
				end
			end
		end
	end

	local function bayonet(player, hasBayonet)
		
		local success, errormessage = pcall(function()
			if hasBayonet == true then	
				tool.Blade.CanTouch = true
				tool.TopPiece.Transparency = 0
				tool.Blade.Transparency = 0
				tool.Connection.Transparency = 0
				tool.BladeDecor.Transparency = 0
			elseif hasBayonet == false then 
				tool.Blade.CanTouch = false 
				tool.TopPiece.Transparency = 1
				tool.Blade.Transparency = 1
				tool.Connection.Transparency = 1
				tool.BladeDecor.Transparency = 1
			end
		end)
		
		if not success then
			warn(errormessage)
		end
	end

	local function stab()
		
		local success, errormessage = pcall(function()
			local activiated = false
			
			local function activation()
				activiated = true
				
				local function touch(otherPart)
					if activiated == true then
						if otherPart then
							local char = otherPart.Parent
							local humanoid = char:WaitForChild("Humanoid")
							if char and humanoid then
								local damage = 25
								
								if otherPart.Name == "Head" then
									humanoid:TakeDamage(damage * 4)
								elseif otherPart.Name == "Torso" then
									humanoid:TakeDamage(damage * 2)
								else
									humanoid:TakeDamage(damage)
								end
								
							end
						end
					end
				end
				
				tool.Blade.Touched:Connect(touch)
			end
			
			local function deactivation()
				activiated = false
			end
			
			tool.Activated:Connect(activation)
			tool.Deactivated:Connect(deactivation)
			
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
	onbayonet.OnServerEvent:Connect(bayonet)
	onstab.OnServerEvent:Connect(stab)
	onsprint.OnServerEvent:Connect(sprinting)
	tool.Equipped:Connect(equip)
	tool.Unequipped:Connect(unequip)
end

script.Parent.Instructions:Destroy()
print("Server-Sided Script loading - From Kar98k") 
mainclass()
