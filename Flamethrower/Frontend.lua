local tool = script.Parent
local player = game.Players.LocalPlayer 
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = player.Character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")
local mouse = player:GetMouse()
local events = tool:WaitForChild("Events")
local onshoot = events:WaitForChild("OnShoot")
local ondeactivate = events:WaitForChild("OnDeactivate")
local runservice = game:GetService("RunService")

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
	if equipped == true then
		if mouse.Hit then
			onshoot:FireServer(mouse.Hit.Position)
		end
	end
end

local function deactivate()
	if equipped == true then
		ondeactivate:FireServer()
	end
end

local function equip()
	if equipped == false then
		equipped = true
		loadedanimations[1]:Play()
	end
end

local function unequip()
	if equipped == true then
		equipped = false
		loadedanimations[1]:Stop()
		local length = loadedanimations[2].Length
		loadedanimations[2]:Play()
		wait(length)
		loadedanimations[2]:Stop()
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
