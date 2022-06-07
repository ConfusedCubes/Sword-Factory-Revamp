local DataStore = {}

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MarketPlaceService = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")

local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules
local ServerModules = ServerStorage.Modules.ServerModules



local ProfileService = require(SharedModules.ProfileService.ProfileService)
local ReplicaService = require(ServerModules.ReplicaService)
local SettingsLib = ReplicatedStorage.Modules.WriteLibs.SettingsLib

DataStore.GamepassIDs = {
	[29794542] = "More Cash";
	[26174000] = "More Cash";
	[29794610] = "More XP";
	[26174045] = "More XP";

	
	[29794445] = "More Health";
	[26174519] = "More Health";

	
	[29794791] = "Faster Ascender";
	[26174380] = "Faster Ascender";

	[29844343] = "Faster Machine";
	[26174211] = "Faster Machine";
	
	
}

DataStore.BadgeIds = {
	[2124975664] = "First Money";
	[2124975668] = "First Grand";
	[2124975670] = "Millionare";
	[2124975675] = "Billionare";
	[2124975683] = "Trillionare";
	[2124975694] = "AlotOfMoneyonare"
}


local Template = {
	PlayerData = {
		PlayTutorial = false;
		Money = 0;
		BossCoins = 0;
		Level = 1;
		XP = 1;
		SwordsInBank_1 = {};
		MiscStats = {
			NetWorth = 0;
			["Total Upgrades"] = 0;
			["Noobs Klled"] = 0;
		};
		GamePassInfo = {
			
		};
		BadgeInfo = {
			
		};
		Settings = {
			CurrrentBulkUpgrade =  1;
			AllowVistors = true;
			TradingPrivacy = "All"; -- Allowed: All, Friends, Disabled
			MuteMusic = false;
			AutoBank = false;
			AutoBankLimit = 10_000;
			AutoBankMode = "Mold"
		};
		Boosts = {
			
		}
	};
	FactoryInfo = { -- Information About the factory
		MachineInformation_1 = {
			["Molder"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
			["Polisher"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
			["Classifier"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
			["Upgrader"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
			["Enchanter"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
			["Appraiser"] = {
				Multiplier = 1;
				Level = 1;
				Prestige  =  1;
			};
		};
		AscenderMode = nil;
		SwordInAscender = nil;
	}
}
local PlayerDataStore = ProfileService.GetProfileStore("PlayerData_3",Template)
local PlayerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")
local SwordReplicaClassToken = ReplicaService.NewClassToken("PlayerSwords")


local Players = game:GetService("Players")

DataStore.PlayerProfiles = {}
DataStore.SwordReplica = {}



ProfileService.CorruptionSignal:Connect(function(...)
	warn("Invalid type saved")
	warn(...)
end)

ProfileService.IssueSignal:Connect(function(...)
	warn("Invalid type saved")
	warn(...)
end)



function DataStore.ReturnPlayersProfile(Player)
	for i,v in pairs(DataStore.PlayerProfiles) do
		if v._Player == Player then
			return v;
		end
	end
end



function DataStore.ReturnPlayersData(Player)
	for i,v in pairs(DataStore.PlayerProfiles) do
		if v._Player == Player then
			return v.Profile.Data
		end
	end
end



function DataStore.PlayerAdded(Player)
	local RandomService = require(Services.RandomService)
	local PlayersProfile = PlayerDataStore:LoadProfileAsync("Data" .. Player.UserId)
	if PlayersProfile ~= nil then
		PlayersProfile:AddUserId(Player.UserId) -- GDPR compliance
		PlayersProfile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		PlayersProfile:ListenToRelease(function()
			DataStore.PlayerProfiles[Player] = nil
			Player:Kick("Error Code 500")
		end)
		if Player:IsDescendantOf(Players) == true then
			local NewProfile = {
				Profile = PlayersProfile,
				Replica = ReplicaService.NewReplica({
					ClassToken = PlayerProfileClassToken,
					Tags = {Player = Player},
					Data = PlayersProfile.Data,
					Replication = Player,
					WriteLib = SettingsLib;
				}),
				SwordReplica = ReplicaService.NewReplica({
					ClassToken = SwordReplicaClassToken,
					Tags = {Player = Player},
					Data = {SellSwords = {}};
					Replication = Player
				}),
				_Player = Player;
				PlayersGamepasses = {
				}
			}
			
			DataStore:SetUpLeaderstats(Player,NewProfile)
			DataStore:InitPlayersBadges(Player,NewProfile)
			DataStore:InitPlayersGamepasses(Player,NewProfile)
			NewProfile.Replica:Write("ChangeUpgradeBulkMode")
			DataStore.PlayerProfiles[Player] = NewProfile
			RandomService:CalculateServerLuck()
		else
			PlayersProfile:Release()
		end
	else
		Player:Kick("Data failed to load.") 
	end
end


function DataStore:SetUpLeaderstats(Player,Profile)
	local Leaderstats = Instance.new("Folder")
	Leaderstats.Name = "leaderstats"
	Leaderstats.Parent = Player
	local Networth = Instance.new("NumberValue")
	Networth.Value = Profile.Profile.Data.PlayerData.MiscStats.NetWorth
	Networth.Name = "NetWorth"
	Networth.Parent = Leaderstats
	local Level = Instance.new("NumberValue")
	Level.Value = Profile.Profile.Data.PlayerData.Level
	Level.Name = "Level"
	Level.Parent = Leaderstats
end


function DataStore:InitPlayersGamepasses(Player,Profile)
	for GamepassId,GamepassName in pairs(self.GamepassIDs) do
		local Success,data = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,Player.UserId,GamepassId)
		print(Success)
		Profile.PlayersGamepasses[GamepassName] = data or false
	end
end

function DataStore:InitPlayersBadges(Player,Profile)
	for BadgeID,BadgeName in pairs(self.GamepassIDs) do
		local Success,data = pcall(BadgeService.UserHasBadgeAsync,BadgeService,Player.UserId,BadgeID)
		Profile.PlayersGamepasses[BadgeName] = data or false
	end
end

function DataStore.ReleasePlayersProfile(Player) -- This might be removed
	local PlayersProfile = DataStore.PlayerProfiles[Player]
	if PlayersProfile then
		PlayersProfile.Replica:Destroy()
		PlayersProfile.SwordReplica:Destroy()
		PlayersProfile.Profile:Release()
	end
end

function DataStore.LoadPlayersData(Player)
	DataStore.PlayerAdded(Player)
end

return DataStore
