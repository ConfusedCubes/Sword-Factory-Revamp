
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules
local SwordStats = require(SharedModules.SwordStats)
local Short = require(SharedModules.Short)

local RandomService = require(Services.RandomService)
local DataStoreService = require(Services.DataStoreService)

local DefaultSwordTemplate = {
	Mold = 0;
	Level = 1;
	Quality = 0;
	Rarity = 0;
	Class = 0;
	Sharpness = 0;
	Resistance = 0;
	Worth = 0;
}

local SwordService = {}
SwordService.Swords = {}


function SwordService.GetSwordInfo(SwordID)
	return SwordService.Swords[SwordID]
end

function SwordService.CreateSwordModel(Config,ID)
	local NewSwordModel = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,Config.Mold).Model:Clone()	
	NewSwordModel:SetAttribute("SwordID",ID)
	return NewSwordModel
end

function SwordService.NewSword(Player,Config,OptionalID)
	local RandomID = OptionalID or HttpService:GenerateGUID(false)
	local NewSwordModel = SwordService.CreateSwordModel(Config,RandomID)
	local NewConfig = {}
	local StatInfo = {}
	for DefaultIndex,DefaultValue in pairs(DefaultSwordTemplate) do
		if Config[DefaultIndex] then
			NewConfig[DefaultIndex] = Config[DefaultIndex];
		else
			NewConfig[DefaultIndex] = DefaultValue;
		end
	end

	
	SwordService.Swords[RandomID] = {
		Owner = Player;
		Model = NewSwordModel;
		Config = NewConfig;
		_ID = RandomID;
	}
	
	return NewSwordModel,NewConfig
end

function SwordService.CleanUpSword(SwordID) -- Removes a sword from SwordService.Swords NOT from the datastore
	local Sword = SwordService.Swords[SwordID]
	if Sword then
		if Sword.Model then
			Sword.Model:Destroy()
		end
		SwordService.Swords[SwordID] = nil;
	end
end

function SwordService.FindSwordInArrary(ID,Path)
	for i,v in pairs(Path) do
		if v.ID == ID then
			return i,v
		end
	end
end

function SwordService.SellSword(Player,ID)
	if ID and assert(typeof(ID) ~= string) then
		local Sword = SwordService.GetSwordInfo(ID)
		if Sword then
			if Sword.Owner == Player then --
				if Sword.Model then
					Sword.Model:Destroy()
				end
				local SwordsWorth = SwordService.CalculateSwordsWorth(ID)
				local Profile = DataStoreService.ReturnPlayersProfile(Sword.Owner)
				if Profile then -- // TODO add a check to make sure that the sword is actually sellable
					local FoundSwordIndex = SwordService.FindSwordInArrary(ID,Profile.SwordReplica.Data.SellSwords) -- Checks to make sure the sword is currently being sold;
					local SwordInAscender = Profile.Profile.Data.FactoryInfo.SwordInAscender
					if FoundSwordIndex and SwordInAscender ~= ID then
						RandomService:AddMoneyToProfile(SwordsWorth,Profile)
						Profile.SwordReplica:ArrayRemove({"SellSwords"},FoundSwordIndex) -- This technically won't do anything.
						SwordService.CleanUpSword(ID)
					end
				end
			end
		end
	end
end

function SwordService.CalculateSwordsWorth(SwordID)
	local ObjectInformation = SwordService.GetSwordInfo(SwordID)
	local ValueToMultiply = 1;
	for StatName,Stat in pairs(ObjectInformation.Config) do
		if SwordStats[StatName] then
			local Information = SwordStats.FindObjectFromIdentifier(SwordStats[StatName],Stat)
			if Information.Multiplier then
				ValueToMultiply *= Information.Multiplier
			end
		end
	end
	return 10*(1.01^ObjectInformation.Config.Level) * ValueToMultiply
end

function SwordService:RemoveSwordFromDataStore(Player,SwordID)
	local ObjectInformation = SwordService.GetSwordInfo(SwordID)
	if ObjectInformation then
		if Player == ObjectInformation.Owner then
			local Profile = DataStoreService.ReturnPlayersProfile(ObjectInformation.Owner)
			if Profile then 
				local FoundSwordIndex = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
				if FoundSwordIndex then
					self:CleanUpSword(SwordID)
					Profile.Replica:ArrayRemove({"PlayerData","SwordsInBank_1"},FoundSwordIndex) -- Removes the sword from the bank;
				end
			end
		end
	end
end

function SwordService.SendSwordToSellingUI(Player,SwordID)
	local ObjectInformation = SwordService.GetSwordInfo(SwordID)
	if ObjectInformation then
		if Player == ObjectInformation.Owner then
			local Profile = DataStoreService.ReturnPlayersProfile(ObjectInformation.Owner)
			if Profile then
				local SwordInAscender = Profile.Profile.Data.FactoryInfo.SwordInAscender
				if SwordID ~= SwordInAscender then
					ObjectInformation.Config.Worth =  Short(SwordService.CalculateSwordsWorth(SwordID),2)
					local SteralizedTable = {Config = ObjectInformation.Config,ID = ObjectInformation._ID,SellTime = workspace:GetServerTimeNow() + 35}
					local FoundSwordIndex = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
					if FoundSwordIndex then -- Prevent selling of Sword that is in the Ascender
						Profile.Replica:ArrayRemove({"PlayerData","SwordsInBank_1"},FoundSwordIndex) -- Removes the sword from the bank;
					end
					warn("adding sword to Selling UI")
					Profile.SwordReplica:ArrayInsert({"SellSwords"},SteralizedTable)
				end
			end
		end
	end
end

function SwordService.BankSword(Player,SwordID)
	local SwordInformation = SwordService.GetSwordInfo(SwordID)
	local Profile = DataStoreService.ReturnPlayersProfile(SwordInformation.Owner)
	if Profile and SwordInformation then 
		local FoundSwordIndex = SwordService.FindSwordInArrary(SwordID,Profile.SwordReplica.Data.SellSwords) -- Checks to make sure the sword is currently being sold;
		if FoundSwordIndex then
			warn("removing sword from selling replica tingy")
			Profile.SwordReplica:ArrayRemove({"SellSwords"},FoundSwordIndex) -- This technically won't do anything.
			if #Profile.Replica.Data.PlayerData.SwordsInBank_1 < 25 then
				Profile.Replica:ArrayInsert({"PlayerData","SwordsInBank_1"},{ID = SwordID, Equipped = false,Config = SwordInformation.Config})	
			else
				SwordService.CleanUpSword(SwordID)
			end
		end
	end
end



function SwordService:_InitSword(Player,PlayersProfile,SwordObject)
	local NewSword = SwordService.NewSword(Player,SwordObject.Config,SwordObject.ID)
	local SwordInformation = SwordService.GetSwordInfo(SwordObject.ID)		
	local FoundSwordIndex = SwordService.FindSwordInArrary(SwordObject.ID,PlayersProfile.Replica.Data.PlayerData.SwordsInBank_1) -- Checks to make sure the sword is currently being sold;
	if FoundSwordIndex then
		local NewTable = {ID = SwordObject.ID, Equipped = SwordObject.Equipped,Config = SwordInformation.Config, InAscender = SwordObject.InAscender}
		PlayersProfile.Replica:ArraySet({"PlayerData","SwordsInBank_1"},FoundSwordIndex,NewTable)
		if SwordObject.Equipped then
			NewSword.Parent = Player.Backpack
		end
	end
end

function SwordService.LoadPlayersSwords(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		for _,SwordObject in pairs(PlayersProfile.Profile.Data.PlayerData.SwordsInBank_1) do
			SwordService:_InitSword(Player,PlayersProfile,SwordObject)
		end
	end
end

function SwordService.EquipSword(Player,SwordID)
	local SwordInformation = SwordService.GetSwordInfo(SwordID)
	if SwordInformation then
		local Profile = DataStoreService.ReturnPlayersProfile(SwordInformation.Owner)
		if Profile and Player == SwordInformation.Owner then
			local TestIndex = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
			local SwordInAscender = Profile.Profile.Data.FactoryInfo.SwordInAscender
			if TestIndex and SwordInAscender ~= SwordID then
				if Profile.Replica.Data.PlayerData.SwordsInBank_1[TestIndex].Equipped == false then
					if SwordInformation.Model and SwordInformation.Model.Parent then
						SwordInformation.Model.Parent = Player.Backpack
					else
						SwordInformation.Model = SwordService.CreateSwordModel(SwordInformation.Config,SwordInformation._ID)
						SwordInformation.Model.Parent = Player.Backpack
					end
					local CurrentInformation = Profile.Profile.Data.PlayerData.SwordsInBank_1[TestIndex]
					CurrentInformation.Equipped = true;
					Profile.Replica:ArraySet({"PlayerData","SwordsInBank_1"},TestIndex,CurrentInformation)
				end
			end
		end
	end
end


function SwordService.UnEquipSword(Player,SwordID)
	local SwordInformation = SwordService.GetSwordInfo(SwordID)
	if SwordInformation then
		local Profile = DataStoreService.ReturnPlayersProfile(SwordInformation.Owner)
		if Profile and Player == SwordInformation.Owner then
			local TestIndex = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
			if Profile.Replica.Data.PlayerData.SwordsInBank_1[TestIndex].Equipped == true then
				SwordInformation.Model:Destroy()
				local CurrentInformation = Profile.Profile.Data.PlayerData.SwordsInBank_1[TestIndex]
				CurrentInformation.Equipped = false;
				Profile.Replica:ArraySet({"PlayerData","SwordsInBank_1"},TestIndex,CurrentInformation)
			end
		end
	end
end

function SwordService.SelectSwordInAscender(Player,SwordID)
	local AscenderService = require(Services.AscenderService) -- Prevent Recursive Requires
	local SwordInformation = SwordService.GetSwordInfo(SwordID)
	if SwordInformation then
		local Profile = DataStoreService.ReturnPlayersProfile(SwordInformation.Owner)
		if Profile and Player == SwordInformation.Owner then
			local TestIndex,SwordObject = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
			if TestIndex then
				if Profile.Replica.Data.FactoryInfo.SwordInAscender == SwordObject.ID then
					Profile.Replica:SetValue({"FactoryInfo","SwordInAscender"},nil) 
					AscenderService:StopUpgradingSword(Player)
				else
					Profile.Replica:SetValue({"FactoryInfo","SwordInAscender"},SwordObject.ID) 
					AscenderService:StartUpgradingSword(Player,SwordObject)
				end
			end
		end
	end
end

function SwordService:AscendSword(Player,SwordID,CurrentlyAscending)
	local SwordInformation = SwordService.GetSwordInfo(SwordID)
	if SwordInformation then
		local Profile = DataStoreService.ReturnPlayersProfile(SwordInformation.Owner)
		if Profile then
			local TestIndex = SwordService.FindSwordInArrary(SwordID,Profile.Replica.Data.PlayerData.SwordsInBank_1)
			local CurrentInformation = Profile.Profile.Data.PlayerData.SwordsInBank_1[TestIndex]
			print(CurrentlyAscending)
			CurrentInformation.InAscender = CurrentlyAscending
			Profile.Replica:ArraySet({"PlayerData","SwordsInBank_1"},TestIndex,CurrentInformation)
		end
	end
end


ReplicatedStorage.RemoteEvents.BankSword.OnServerEvent:Connect(SwordService.BankSword)
ReplicatedStorage.RemoteEvents.SellSword.OnServerEvent:Connect(SwordService.SellSword)
ReplicatedStorage.RemoteEvents.EquipSword.OnServerEvent:Connect(SwordService.EquipSword)
ReplicatedStorage.RemoteEvents.UnEquipSword.OnServerEvent:Connect(SwordService.UnEquipSword)
ReplicatedStorage.RemoteEvents.SendSwordToSellingUI.OnServerEvent:Connect(SwordService.SendSwordToSellingUI)
ReplicatedStorage.RemoteEvents.UpdateSelectedAscenderItem.OnServerEvent:Connect(SwordService.SelectSwordInAscender)
ReplicatedStorage.RemoteFunction.GetSwordInformation.OnServerInvoke = function(_,ID)
	return SwordService.GetSwordInfo(ID)
end

return SwordService
