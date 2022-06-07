local Players = game:GetService('Players')
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules
local ServerModules = ServerStorage.Modules.ServerModules

local DataStoreService = require(Services.DataStoreService)
local ReplicaService = require(ServerModules.ReplicaService)


local BoostService = {}
BoostService.ActiveBoosts = {}

-- Types = CoinBoost,XPBoost,LuckBoost

function BoostService:CreateNewBoost(Player,Type,Duration)
	if not BoostService.ActiveBoosts[Player] then
		BoostService.ActiveBoosts[Player] = {}
	end
	local BoostInfo = {
		Type = Type;
		Duration = Duration; -- Duration is not used;
		EndingTime = workspace:GetServerTimeNow() + Duration;
	}
	table.insert(BoostService.ActiveBoosts[Player],BoostInfo)
	ReplicatedStorage.RemoteEvents.BoostEvents.RedrawBoosts:FireClient(Player,BoostService.ActiveBoosts[Player])
	return BoostService.ActiveBoosts[Player]
end

function BoostService:FindBoostWithType(Player,Type)
	if self.ActiveBoosts[Player] then
		for BoostIndex,BoostInfo in pairs(self.ActiveBoosts[Player]) do
			local CurrentTime = workspace:GetServerTimeNow()		
			if BoostInfo.EndingTime - CurrentTime < 0 then -- Boost is finished
				table.remove(self.ActiveBoosts[Player],BoostIndex) -- Clean up :)
			else
				if BoostInfo.Type == Type then
					return BoostInfo
				end
			end
		end
	end
end

function BoostService:AddTimeToBoost(Player,Type,AdditonalTime)
	local PlayersBoost = self:FindBoostWithType(Player,Type)
	if PlayersBoost then
		PlayersBoost.Duration += AdditonalTime
		PlayersBoost.EndingTime += AdditonalTime
		ReplicatedStorage.RemoteEvents.BoostEvents.RedrawBoosts:FireClient(Player,BoostService.ActiveBoosts[Player])
	else
		self:CreateNewBoost(Player,Type,AdditonalTime)
	end
end

function BoostService:CalculateTimeLeft(Player,Type)
	local PlayersBoost = BoostService.ActiveBoosts[Player] 
	if PlayersBoost then
		local TimeLeft = workspace:GetServerTimeNow() - PlayersBoost.EndingTime -- Subtract the current time from the ending time getting how much time is left 
		return math.max(TimeLeft,0) -- Lower limit is 0
	end
end

function BoostService:GetSterilizedBoost(Player)
	local PlayersBoost = self.ActiveBoosts[Player]
	if PlayersBoost then
		local SterilizedTable = {}
		for Key,BoostInfo in pairs(PlayersBoost) do
			local TimeLeft = BoostInfo.EndingTime - workspace:GetServerTimeNow()
			if TimeLeft >= 0 then
				local Tmp = {Type = BoostInfo.Type,TimeLeft = TimeLeft}
				table.insert(SterilizedTable,Tmp)
			end
		end
		return SterilizedTable
	end
end

function BoostService:SavePlayersBoosts(Player)
	local SterilizedBoosts = BoostService:GetSterilizedBoost(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		PlayersProfile.Replica:SetValue({"PlayerData","Boosts"},SterilizedBoosts)
	end
end

function BoostService:PlayerAdded(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local SterilizedData = PlayersProfile.Profile.Data.PlayerData.Boosts
		if SterilizedData then
			print("Old Data",SterilizedData)
			for BoostIndex,BoostInfo in pairs(SterilizedData) do
				self:CreateNewBoost(Player,BoostInfo.Type,BoostInfo.TimeLeft)
			end
		end
	end
end

function BoostService:PlayerRemoving(Player)
	local PlayersBoost = self.ActiveBoosts[Player]
	if PlayersBoost then
		self:SavePlayersBoosts(Player)
		self.ActiveBoosts[Player] = nil;
	end
end

return BoostService