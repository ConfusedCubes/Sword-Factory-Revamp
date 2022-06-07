local RandomService = {} -- Im not sure where to put the following stuff

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketPlaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")
local Players = game:GetService("Players")
local Services = ServerScriptService.Services
local DataStoreService = require(Services.DataStoreService)

local BoostService = require(Services.BoostService)

RandomService.ServerLuck = 1; -- ServerLuck is just the every players level added up with a formula
RandomService.ServerLuckChangedEvent = ReplicatedStorage.RemoteEvents.ServerluckChanged

local DevProducts = {
	[1240168881] = function(PlayerLevel)
		return 90+(10*(1.06^PlayerLevel)*1)
	end,
	[1240168928] = function(PlayerLevel)
		return 400+(10*(1.06^PlayerLevel)*10)
	end,
	[1240168973] = function(PlayerLevel)
		return 1700+(10*(1.06^PlayerLevel)*30)
	end,
	[1240169028] = function(PlayerLevel)
		return 8500+(10*(1.06^PlayerLevel)*150)
	end,
	[1240169123] = function(PlayerLevel)
		return 30000+(10*(1.06^PlayerLevel)*500)
	end,
}


local BadgeAmmounts = {
	[2124975664] = 0;
	[2124975668] = 1000;
	[2124975670] = 1_000_000;
	[2124975675] = 1_000_000_000;
	[2124975683] = 1_000_000_000_000;
	[2124975694] = 1_000_000_000_000_000	
}

function RandomService:AwardBadge(Player,BadgeID)
	local success, result = pcall(function()
		return BadgeService:AwardBadge(Player.UserId, BadgeID)
	end)
end

function RandomService:CalculateServerLuck()
	local ServerLuckTmp = 1;
	for _,Player in pairs(Players:GetPlayers()) do
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			local CurrentLevel = PlayersProfile.Profile.Data.PlayerData.Level
			local x = CurrentLevel/100
			local n = math.floor(x/0.5)*0.5
			ServerLuckTmp += math.clamp(n,0.5,4) -- The multiplier
		end
	end
	RandomService.ServerLuckChangedEvent:FireAllClients(ServerLuckTmp)
	self.ServerLuck = ServerLuckTmp
	print("New server luck",self.ServerLuck)
end

function RandomService:UpdateProfilesXP(Profile)
	local PlayersLevel = Profile.Replica.Data.PlayerData.Level
	local CurrentXP = Profile.Replica.Data.PlayerData.XP
	local XpRequiredToLevelUp = 10_000*(1.07^(PlayersLevel-1))
	if CurrentXP > XpRequiredToLevelUp then
		Profile.Replica:SetValue({"PlayerData","XP"},0)
		Profile.Replica:SetValue({"PlayerData","Level"},Profile.Replica.Data.PlayerData.Level + 1) -- Level Changed
		RandomService:CalculateServerLuck()
	end
end


function RandomService:AddMoneyToProfile(Amount,Profile)
	
	local CashBoostMulti = if BoostService:FindBoostWithType(Profile._Player,"CashBoost") then 3 else 1
	local GamepassCashBoostAmmount = if Profile.PlayersGamepasses["More Cash"] then (Amount * 0.50) else 0 -- 50% more cash
	local GamepassXpBoostAmmounnt = if Profile.PlayersGamepasses["More XP"] then (Amount * 0.50) else 0 -- 50% more cash
	local XPBoostMulti = if BoostService:FindBoostWithType(Profile._Player,"XPBoost") then 3 else 1
	Amount *= CashBoostMulti
	Amount += GamepassCashBoostAmmount
	Profile.Replica:SetValue({"PlayerData","XP"},Profile.Replica.Data.PlayerData.XP + ((Amount/5) + GamepassXpBoostAmmounnt * XPBoostMulti))
	Profile.Replica:SetValue({"PlayerData","Money"},Profile.Replica.Data.PlayerData.Money + Amount)
	Profile.Replica:SetValue({"PlayerData","MiscStats","NetWorth"},Profile.Replica.Data.PlayerData.MiscStats.NetWorth + Amount)
	
	
	
	for BadgeID,Required_Ammount in BadgeAmmounts do
		if Profile.Replica.Data.PlayerData.Money > Required_Ammount then
			if not Profile.Replica.Data.PlayerData.BadgeInfo[BadgeID] then -- They don't have it 
					RandomService:AwardBadge(Profile._Player,BadgeID)
				end
			end
		end
	
	
	
	
	self:UpdateProfilesXP(Profile)
	self:UpdatePlayersLeaderstat(Profile._Player,Profile)
end


function RandomService:UpdatePlayersLeaderstat(Player,Profile)
	local Leaderstat = Player:FindFirstChild("leaderstats")
	if Leaderstat then
		local Networth = Leaderstat:FindFirstChild("NetWorth")
		local Level = Leaderstat:FindFirstChild("Level")
		if Networth and Level then
			Networth.Value = Profile.Profile.Data.PlayerData.MiscStats.NetWorth
			Level.Value = Profile.Replica.Data.PlayerData.Level
		end
	end
end

function RandomService.MoneyChanged(Player,new_value)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local PlayersLevel = PlayersProfile.Replica.Data.PlayerData.Level
		local CurrentXP = PlayersProfile.Replica.Data.PlayerData.XP
		local XpRequiredToLevelUp = 10_000*(1.07^(PlayersLevel-1))
		if CurrentXP > XpRequiredToLevelUp then
			PlayersProfile.Replica:SetValue({"PlayerData","XP"},0)
			PlayersProfile.Replica:SetValue({"PlayerData","Level"},PlayersProfile.Replica.Data.PlayerData.Level + 1)
		end
	end
end





ReplicatedStorage.RemoteFunction.GetCurrentServerLuck.OnServerInvoke = function()
	return RandomService.ServerLuck
end
ServerScriptService.BindableEvent.MoneyChanged.Event:Connect(RandomService.MoneyChanged)



return RandomService
