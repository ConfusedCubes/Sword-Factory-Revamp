local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local LeaderboardController = {}


function ClearChildrenOfType(Parent,Type)
	for Index,Instance in pairs(Parent:GetChildren()) do
		if Instance:IsA(Type) then
			Instance:Destroy()
		end
	end
end

function LeaderboardController:UpdateLeaderboard()
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	if PlayersBase then
		local Leaderboard = PlayersBase:WaitForChild("Structures"):WaitForChild("LeaderBoard"):WaitForChild("Main")
		local LeaderboardList = Leaderboard.Gui.List
		local Top100Players = ReplicatedStorage.RemoteFunction.GetLeaderboardData:InvokeServer()
		ClearChildrenOfType(LeaderboardList,"Frame")
		for PlayerIndex,PlayerData in pairs(Top100Players) do
			local Template = script.Template:Clone()
			Template.LayoutOrder = PlayerIndex
			local Success,PlayersInformation = pcall(Players.GetNameFromUserIdAsync,Players,PlayerData.key)
			if Success and PlayersInformation then
				Template.Rank.Text = PlayerIndex
				Template.PlayersName.Text = PlayersInformation
				Template.Money.Text = Short(PlayerData.value,2)
				Template.Parent = LeaderboardList
			end
		end
	end
end


function LeaderboardController:Init()
	task.spawn(LeaderboardController.UpdateLeaderboard,LeaderboardController)
	local EndTime = workspace:GetServerTimeNow() + 10 
	RunService.Heartbeat:Connect(function()
		local TimeLeft = EndTime - workspace:GetServerTimeNow()
		if TimeLeft < 0 then
			EndTime = workspace:GetServerTimeNow() + 60
			task.spawn(LeaderboardController.UpdateLeaderboard,LeaderboardController)
		end
	end)
end



return LeaderboardController
