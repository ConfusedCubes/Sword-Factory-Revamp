
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Services
local Players = game:GetService("Players")


local DataStoreService = require(Services.DataStoreService)
local BaseService = require(Services.BaseService)
local SwordService = require(Services.SwordService)
local SwordSavingService = require(Services.SwordService.SwordSavingService)
local RandomService = require(Services.RandomService)
local MobService = require(Services.MobService)
local SwordToolService = require(Services.SwordToolService)
local BoostService = require(Services.BoostService)
local MonetizationService = require(Services.MonetizationService) 
local TradeService = require(Services.TradeService)
local AscenderService = require(Services.AscenderService)
local LeaderboardService = require(Services.LeaderboardService)

function PlayerAdded(Player)
	DataStoreService.LoadPlayersData(Player) -- Loads the players data. Strict load order is required here
	BoostService:PlayerAdded(Player)
	RandomService:AwardBadge(Player,2124975658)
	BaseService.CreateBase(Player)	
	SwordService.LoadPlayersSwords(Player)
	AscenderService:PlayerJoined(Player)
	LeaderboardService:PlayerAdded(Player)
end

function PlayerLeaving(Player)
	BoostService:PlayerRemoving(Player)
	DataStoreService.ReleasePlayersProfile(Player)
	BaseService.DestroyBase(Player)
	TradeService:PlayerLeft(Player)
	AscenderService:PlayerLeft(Player)
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerLeaving)

SwordToolService.Init()
MobService.Init()
LeaderboardService:Init()



