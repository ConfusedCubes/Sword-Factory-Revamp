local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

local PlayerModules = Player.PlayerScripts:WaitForChild("Modules")
local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)

local MainUIController = require(PlayerModules:WaitForChild("MainUIController"))
local SwordController = require(PlayerModules.SwordController)
local BankController = require(PlayerModules.BankController)
local UpgradeController = require(PlayerModules.UpgradeController)
local SideBarController = require(PlayerModules.SideBarController)
local TutorialController = require(PlayerModules.TutorialController)
local StatsController  = require(PlayerModules.StatsController)
local ShopController = require(PlayerModules.ShopController)
local AscenderController = require(PlayerModules.AscenderController)
local SettingsController = require(PlayerModules.SettingsController)
local TradeController = require(PlayerModules.TradeController)
local BoostController = require(PlayerModules.BoostController)
local LeaderboardController = require(PlayerModules.LeaderboardController)
local MusicController = require(PlayerModules.MusicController)
local RarityBoardController = require(PlayerModules.RarityBoardController)



MainUIController.Init() -- After everything has been initazlied then request data
SwordController.Init() -- VV why are these all using . instead of : lol
BankController.Init()
UpgradeController.Init()
SideBarController.Init()
TutorialController.Init()
StatsController.Init()
ShopController.Init()
AscenderController.Init()
SettingsController.Init()
TradeController.Init()
BoostController.Init()
LeaderboardController:Init()
MusicController:Init()
RarityBoardController:Init()



ReplicaController.RequestData()