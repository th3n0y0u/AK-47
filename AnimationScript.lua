local function mainclass()
	local function playeraddedtoserver(player)		
		if player then
			player.CharacterAdded:Connect(function(char)	
				if char then
					local success, errormessage = pcall(function()
						local torso = char.UpperTorso or char.Torso
						local toolgrip = Instance.new("Motor6D", torso) 
						toolgrip.Name = "ToolGrip" 
					end)

					if not success then
						warn(errormessage)
						char:BreakJoints()
					end 
					
				end
			end) 
		end
	end

	local function connectM6D(player, location, tool)
		local success, errormessage = pcall(function()
			if player and location and tool then
				local realtool = player.Backpack:FindFirstChild(tool.Name) or player.Character:FindFirstChild(tool.Name)
				if location == realtool:FindFirstChild("BodyAttach") then
					local char = player.Character
					local torso = char.UpperTorso or char.Torso
					torso.ToolGrip.Part0 = torso
					torso.ToolGrip.Part1 = location
				end
			end
		end)

		if not success then
			warn(errormessage)
			player.Character:BreakJoints() 
		end
	end

	local function disconnectM6D(player, tool)
		local success, errormessage = pcall(function()
			if player and tool then
				local realtool = player.Backpack:FindFirstChild(tool.Name) or player.Character:FindFirstChild(tool.Name)
				if realtool then
					local torso = player.Character.UpperTorso or player.Character.Torso
					torso.ToolGrip.Part1 = nil
				end
			end
		end)

		if not success then
			warn(errormessage)
			player.Character:BreakJoints() 
		end
	end

	game.Players.PlayerAdded:Connect(playeraddedtoserver)
	game.ReplicatedStorage.ConnectM6D.OnServerEvent:Connect(connectM6D)
	game.ReplicatedStorage.DisconnectM6D.OnServerEvent:Connect(disconnectM6D)
end

mainclass() 
