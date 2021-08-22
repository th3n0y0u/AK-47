game.Players.PlayerAdded:Connect(function(player)			
	player.CharacterAdded:Connect(function(char)		
		local toolgrip = Instance.new("Motor6D", char.UpperTorso)
		toolgrip.Name = "ToolGrip"
	end)
end)

game.ReplicatedStorage.ConnectM6D.OnServerEvent:Connect(function(player, location)
	local char = player.Character
	char.UpperTorso.ToolGrip.Part0 = char.UpperTorso
	char.UpperTorso.ToolGrip.Part1 = location
end) 

game.ReplicatedStorage.DisconnectM6D.OnServerEvent:Connect(function(player)
	player.Character.UpperTorso.ToolGrip.Part1 = nil
end) 
