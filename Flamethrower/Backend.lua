local tool = script.Parent
local events = tool:WaitForChild("Events")
local values = tool:WaitForChild("Values")
local onshoot = events:WaitForChild("OnShoot")
local ondeactivate = events:WaitForChild("OnDeactivate")
local ammo = values:WaitForChild("Ammo")
local reserveammo = values:WaitForChild("ReserveAmmo")
local clipsize = values:WaitForChild("ClipSize")
local damage = values:WaitForChild("Damage")
local shooting = false 

local function reload()
	if ammo <= 0 then
		if shooting == false then
			
			reserveammo.Value -= ammo.Value
			ammo.Value = clipsize.Value
			
		end
	end
end

local function shoot(player, position)
	
	if shooting == false and ammo.Value > 0 then
	shooting = true

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
		end 
		
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
	
		shootsound()
		ammo.Value -= 1
	end
end

local function deactiviate()
	if shooting == true then
		shooting = false
		local fire = tool.ShootPart:FindFirstChild("ParticleEmitter")
		local sound = tool:FindFirstChild("ShootSound") 
		
		if fire then
			
			if sound then
				game:GetService("Debris"):AddItem(sound, 1)
				game:GetService("Debris"):AddItem(fire, 1) 
			end
			
		end
		
	end
	
end

local function equip()
	
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
end

local function unequip()
	
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

onshoot.OnServerEvent:Connect(shoot)
ondeactivate.OnServerEvent:Connect(deactiviate)
tool.Equipped:Connect(equip)
tool.Unequipped:Connect(unequip)
