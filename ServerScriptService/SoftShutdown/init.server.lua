--[[
	SoftShutdown 1.2 || Edit 1.0
	Author: Merely
	Edited by: iGottic
	
	This system lets you shut down servers without losing a bunch of players.
	When game.OnClose is called, the script teleports everyone in the server
	into a reserved server.
	
	When the reserved servers start up, they wait a few seconds, and then
	send everyone back into the main place.
	
	I added wait() in a couple of places because if you don't, everyone will spawn into
	their own servers with only 1 player.
--]]

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local function AddUI(pl)
	script.UpdateUI:Clone().Parent = pl:WaitForChild("PlayerGui")
end

if (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then
	-- this is a reserved server without a VIP server owner
	local m = Instance.new("Message")
	m.Text = "The game is currently updating. Please allow up to 30 seconds!"
	m.Parent = workspace
	
	local waitTime = 30

	Players.PlayerAdded:connect(function(player)
		wait(waitTime)
		waitTime = waitTime / 2
		TeleportService:Teleport(game.PlaceId, player)
	end)
	
	for _,player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(game.PlaceId, player)
		wait(waitTime)
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		local con
		
		if (#Players:GetPlayers() == 0) then
			return
		end
		
		if (game:GetService("RunService"):IsStudio()) then
			return
		end
		
		for i,v in pairs(game.Players:GetChildren()) do
			AddUI(v)
		end
		
		con = Players.PlayerAdded:connect(function(v)
			wait(1)
			AddUI(v)
		end)
		
		wait(15) -- How long before the server actually shuts down.
		
		con:Disconnect()
		
		local m = Instance.new("Message")
		m.Text = "Rebooting servers for update. Please wait"
		m.Parent = workspace
		wait(2)
		local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)
		
		for _,player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end)
		while (#Players:GetPlayers() > 0) do
			wait(1)
		end	
		
		-- done
	end)
end