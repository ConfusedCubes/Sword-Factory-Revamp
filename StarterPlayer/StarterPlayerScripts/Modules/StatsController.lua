
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local Player = Players.LocalPlayer
local StatsController = {}
local PlayerGui = Player.PlayerGui
local GameGUI = PlayerGui:WaitForChild("GameUI")
local StatsGUI = GameGUI.Stats


local StatsPatterns = {
	["NetWorth"] = ""	

}


function StatsController.InitStatsFrame()
	local Success,Thumbnail = pcall(Players.GetUserThumbnailAsync,Players,Player.UserId,Enum.ThumbnailType.AvatarThumbnail,Enum.ThumbnailSize.Size420x420)
	if Thumbnail then
		StatsGUI.ImageLabel.ImageLabel.Image = Thumbnail
	end
end


function StatsController.UpdateStatsFrame(Stat,NewValue)
	for _,StatFrame in pairs(StatsGUI.ImageLabel.Frame:GetChildren()) do
		local LinkedConfig = StatFrame:GetAttribute("LinkedConfig")
		if LinkedConfig then
			if LinkedConfig == Stat then
				StatFrame.TextLabel.Text = Stat .. ": " .. Short(NewValue,3)
			end
		end
	end
end


function StatsController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		for StatName,Stat in pairs(Replica.Data.PlayerData.MiscStats) do
			StatsController.UpdateStatsFrame(StatName,Stat)
		end
		Replica:ListenToRaw(function(_,Path,NewValue)
			if Path[1] == "PlayerData" and Path[2] and Path[2] == "MiscStats" and Path[3] then
				StatsController.UpdateStatsFrame(Path[3],NewValue)
			end
		end)
		StatsController.InitStatsFrame()
	end)
end


return StatsController
