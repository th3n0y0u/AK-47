game.Players.PlayerAdded:Connect(function(player)			
	player.CharacterAdded:Connect(function(char)	
		local success, errormessage = pcall(function()
			local toolgrip = Instance.new("Motor6D", char.UpperTorso) 
			toolgrip.Name = "ToolGrip" 
		end)
		
		if not success then
			warn(errormessage)
		end 
	end) 
end)

game.ReplicatedStorage.ConnectM6D.OnServerEvent:Connect(function(player, location)
	local success, errormessage = pcall(function()
		local char = player.Character
		char.UpperTorso.ToolGrip.Part0 = char.UpperTorso
		char.UpperTorso.ToolGrip.Part1 = location
	end)
	
	if not success then
		warn(errormessage)
	end
end) 

game.ReplicatedStorage.DisconnectM6D.OnServerEvent:Connect(function(player)
	local success, errormessage = pcall(function()
		player.Character.UpperTorso.ToolGrip.Part1 = nil
	end)
	
	if not success then
		warn(errormessage)
	end
end) 
