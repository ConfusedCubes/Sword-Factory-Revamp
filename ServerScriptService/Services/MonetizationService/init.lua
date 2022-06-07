local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services

local DataStoreService = require(Services.DataStoreService)
local RandomService = require(Services.RandomService)
local BoostService = require(Services.BoostService)

local MonetizationService = {}


MonetizationService.DevProductFunctions = {
	[1240168881] = function(Reciept)
		return MonetizationService:GiveCash(Reciept,function(PlayerLevel)
			return 90+(10*(1.06^PlayerLevel)*1)
		end)
	end,
	[1240168928] = function(Reciept)
		return MonetizationService:GiveCash(Reciept,function(PlayerLevel)
			return 400+(10*(1.06^PlayerLevel)*10)
		end)
	end,
	[1240168973] = function(Reciept)
		return MonetizationService:GiveCash(Reciept,function(PlayerLevel)
			return 1700+(10*(1.06^PlayerLevel)*30)		
		end)
	end,
	[1240169028] = function(Reciept)
		return MonetizationService:GiveCash(Reciept,function(PlayerLevel)
			return 8500+(10*(1.06^PlayerLevel)*150)
		end)
	end,
	[1240169123] = function(Reciept)
		return MonetizationService:GiveCash(Reciept,function(PlayerLevel)
			return 30000+(10*(1.06^PlayerLevel)*500)
		end)
	end,
	[1247875338] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"HealthBoost",15 * 60) -- 15 
	end,
	[1247875729] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"HealthBoost",60 * 60) -- 1 hour
	end,
	[1247875793] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"HealthBoost",5 * 60 * 60) -- 5 hours
	end,
	[1247875845] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"LuckBoost",15 * 60) -- 15 
	end,
	[1247875889] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"LuckBoost",60 * 60) -- 1 hour
	end,
	[1247875938] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"LuckBoost",5 * 60 * 60) -- 5 hours
	end,
	[1247874971] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"CashBoost",15 * 60) -- 15 
	end,
	[1247874999] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"CashBoost",60 * 60) -- 1 hour
	end,
	[1247875062] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"CashBoost",5 * 60 * 60) -- 5 hours
	end,
	[1247875142] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"XPBoost",15 * 60) -- 15 
	end,
	[1247875217] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"XPBoost",60 * 60) -- 1 hour
	end,
	[1247875276] = function(Reciept)
		return MonetizationService:GiveBoost(Reciept,"XPBoost",5 * 60 * 60) -- 5 hours
	end,

}
MonetizationService.BoostsInformation = {
	["CashBoost15"] = {Cost = 200,Duration = 15 * 60,Type = "CashBoost"}; -- 15 Minutes
	["CashBoost60"] = {Cost = 350,Duration = 60 * 60,Type = "CashBoost"}; -- 1 hour
	["CashBoost300"] = {Cost = 800,Duration = 5 * 60 * 60,Type = "CashBoost"};
	["HealthBoost15"] = {Cost = 200,Duration = 15 * 60,Type = "HealthBoost"}; -- 15 Minutes
	["HealthBoost60"] = {Cost = 350,Duration = 60 * 60,Type = "HealthBoost"}; -- 1 hour
	["HealthBoost300"] = {Cost = 800,Duration = 5 * 60 * 60,Type = "HealthBoost"};
	["LuckBoost15"] = {Cost = 200,Duration = 15 * 60,Type = "LuckBoost"}; -- 15 Minutes
	["LuckBoost60"] = {Cost = 350,Duration = 60 * 60,Type = "LuckBoost"}; -- 1 hour
	["LuckBoost300"] = {Cost = 800,Duration = 5 * 60 * 60,Type = "LuckBoost"};
	["XPBoost15"] = {Cost = 200,Duration = 15 * 60,Type = "XPBoost"}; -- 15 Minutes
	["XPBoost60"] = {Cost = 350,Duration = 60 * 60,Type = "XPBoost"}; -- 1 hour
	["XPBoost300"] = {Cost = 800,Duration = 5 * 60 * 60,Type = "XPBoost"};
}


function MonetizationService:GiveBoost(Reciept,Type,Duration,Player)
	local User;
	if Reciept then
		User = Players:GetPlayerByUserId(Reciept.PlayerId)
	else
		User = Player
	end
	if User then
		BoostService:AddTimeToBoost(User,Type,Duration)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function MonetizationService:GiveCash(Reciept,Formula)
	local Player = Players:GetPlayerByUserId(Reciept.PlayerId)
	if Player then
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			local PlayersLevel = PlayersProfile.Profile.Data.PlayerData.Level
			local CashGiven = Formula(PlayersLevel)
			if CashGiven then
				RandomService:AddMoneyToProfile(CashGiven,PlayersProfile)
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
	end
end

function MonetizationService.BuyBoostWithBossCoins(Player,BoostID)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local BoostInformation = MonetizationService.BoostsInformation[BoostID]
		if BoostInformation then
			if PlayersProfile.Profile.Data.PlayerData.BossCoins >= BoostInformation.Cost then
				PlayersProfile.Replica:SetValue({"PlayerData","BossCoins"}, PlayersProfile.Profile.Data.PlayerData.BossCoins - BoostInformation.Cost)
				MonetizationService:GiveBoost(nil,BoostInformation.Type,BoostInformation.Duration,Player)
			end
		end
	end	
end

function MonetizationService.ProcessReceiept(Reciept)
	local DevProductFunction = MonetizationService.DevProductFunctions[Reciept.ProductId]
	if DevProductFunction then
		local Success = if DevProductFunction(Reciept) == Enum.ProductPurchaseDecision.PurchaseGranted then Enum.ProductPurchaseDecision.PurchaseGranted  else Enum.ProductPurchaseDecision.NotProcessedYet
		return Success	
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

MarketPlaceService.ProcessReceipt = MonetizationService.ProcessReceiept
ReplicatedStorage.RemoteEvents.BuyBoostWithBossCoins.OnServerEvent:Connect(MonetizationService.BuyBoostWithBossCoins)

return MonetizationService
