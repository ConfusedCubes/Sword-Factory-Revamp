local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local LeaderboardOrderedDataStore = DataStoreService:GetOrderedDataStore("Leaderboard_1") 
local LeaderboardService = {}
LeaderboardService.Queue = {}
LeaderboardService.LeaderboardCache = {}
LeaderboardService.LastUpdateTime = 0;

local DataService = require(Services.DataStoreService)

function LeaderboardService:UpdatePlayersLeaderboardData(Player)
	print("Updating " .. Player.Name .. "'s Data")
	local PlayersProfile = DataService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local CurrentNetWorth = PlayersProfile.Profile.Data.PlayerData.MiscStats.NetWorth
		local CurrentLevel = PlayersProfile.Profile.Data.PlayerData.Level
		if CurrentLevel and CurrentNetWorth then
			pcall(function()
				LeaderboardOrderedDataStore:UpdateAsync(Player.UserId,function(CurrentData)
					return math.round(CurrentNetWorth), Player.UserId
				end)
			end)
		end
	end
end

function LeaderboardService:PlayerAdded(Player)
	self.Queue[Player] = workspace:GetServerTimeNow() + 60
end

function LeaderboardService:UpdateCachedLeaderboard()
	local Success, Data = pcall(function()
		local Pages: Pages = LeaderboardOrderedDataStore:GetSortedAsync(false,100)
		return Pages:GetCurrentPage()
	end)
	if Success and Data then
		self.LeaderboardCache = Data
	end
end
	

function LeaderboardService.FetchLeaderboardData(Player)
	if workspace:GetServerTimeNow() - LeaderboardService.LastUpdateTime > 120 then
		LeaderboardService:UpdateCachedLeaderboard()
		LeaderboardService.LastUpdateTime = workspace:GetServerTimeNow()
	end
	return LeaderboardService.LeaderboardCache
end

function LeaderboardService:Init()
	RunService.Heartbeat:Connect(function()
		local CurrentTime = workspace:GetServerTimeNow()
		for Player,EndingTime in pairs(self.Queue) do
			if EndingTime - CurrentTime < 0 then
				task.spawn(LeaderboardService.UpdatePlayersLeaderboardData,self,Player) -- Not sure if this needs to be task.spawned
				self.Queue[Player] = CurrentTime + 60
			end
		end
	end)
	LeaderboardService:UpdateCachedLeaderboard()
end


ReplicatedStorage.RemoteFunction.GetLeaderboardData.OnServerInvoke = LeaderboardService.FetchLeaderboardData



return LeaderboardService
