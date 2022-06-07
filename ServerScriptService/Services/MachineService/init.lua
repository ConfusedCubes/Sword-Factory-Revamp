
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local Services = ServerScriptService.Services
local RemoteEvents = ReplicatedStorage.RemoteEvents

local DataStoreService = require(Services.DataStoreService)
local MachineClass = require(script.MachineClass)
local BoostService = require(Services.BoostService)

local MachineService = {}
MachineService.PlayerCache = {}

local AllowedMulti = {1,2,4,6,8,16,32}

function MachineService.GenerateUpgradeWorth(MachineObject)
	local X = 2.5+math.max((0.0005+(0.0004*MachineObject.Level/100))*((MachineObject.Level)),0)
	return math.round( 9+(10*((X-2.5)*20) + MachineObject.Level^X))
end


function MachineService.Init(Base,Player)
	local Test = MachineClass.new(Base,Player)
	Test:CreateBlankSword()
	Test.Machines[1].MachineFinished.Event:Connect(function()
		Test:CreateBlankSword()
	end)
	MachineService.PlayerCache[Player] = Test
end


function MachineService.CalculateMachineLuck(Player,MachineName)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineInformation_1 = Data.FactoryInfo.MachineInformation_1[MachineName]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local PlayerLevel = Data.PlayerData.Level
			local ExtraLuckGamepass = if PlayersProfile.PlayersGamepasses["More Luck"] then 5 else 1
			local ExtraLuckBoost = if BoostService:FindBoostWithType(Player,"LuckBoost") then  3 else 1
			local MachinePrestige = MachineInformation_1.Prestige
			return Random.new():NextNumber()/(1+(0.1*PlayerLevel))/(1+(0.5*MachineLevel))/MachineMultiplier/(0.75+(0.25*MachinePrestige))/ExtraLuckGamepass/ExtraLuckBoost
		end
	end
end


function MachineService.UpgradeMachine(Player,Machine)
	local Profile = DataStoreService.ReturnPlayersProfile(Player)
	if Profile then 
		local MachineInformation_1 = Profile.Replica.Data.FactoryInfo.MachineInformation_1[Machine]
		if MachineInformation_1 then
			local CurrentMultiplier = Profile.Replica.Data.PlayerData.Settings.CurrrentBulkUpgrade
			for Repeat = 1, CurrentMultiplier do
				local UpgradeCost = MachineService.GenerateUpgradeWorth(MachineInformation_1)
				local PlayersMoney = Profile.Replica.Data.PlayerData.Money
				if PlayersMoney >= UpgradeCost then
					MachineInformation_1.Level += 1
					Profile.Replica:SetValue({"PlayerData","Money"},PlayersMoney - UpgradeCost)
					local Path = {"FactoryInfo","MachineInformation_1",Machine}
					Profile.Replica:SetValue(Path,MachineInformation_1)
				else
					break; -- If they are broke don't keep repeating the loop
				end
			end	
		end
	end
end


function MachineService.UpdateMachinesMulti(Player,MachineStat,NewMulti)
	if table.find(AllowedMulti,NewMulti) then
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			local MachineInformation_1 = PlayersProfile.Profile.Data.FactoryInfo.MachineInformation_1[MachineStat]
			if MachineInformation_1 then
				MachineInformation_1.Multiplier = NewMulti
				PlayersProfile.Replica:SetValue({"FactoryInfo","MachineInformation_1",MachineStat},MachineInformation_1)
			end
		end	
	end
end

function MachineService.ChangeCurrentUpgradeBulk(Player,NewBulkNumber)
	local AllowedBulks = {1,5,50}
	if table.find(AllowedBulks,NewBulkNumber) then
		local Profile = DataStoreService.ReturnPlayersProfile(Player)
		if Profile then
			Profile.Replica:SetValue({"PlayerData","Settings","CurrrentBulkUpgrade"},NewBulkNumber)
		end
	end
end

function MachineService.GetMachineInfo(Player,MachineName)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		return PlayersProfile.Profile.Data.FactoryInfo.MachineInformation_1[MachineName]
	end
end

Players.PlayerRemoving:Connect(function(Player)
	if MachineService.PlayerCache[Player] then
		MachineService.PlayerCache[Player]:CleanUp()
	end
end)

ReplicatedStorage.RemoteEvents.UpgradeMachine.OnServerEvent:Connect(MachineService.UpgradeMachine)
ReplicatedStorage.RemoteEvents.ChangeMachineMulti.OnServerEvent:Connect(MachineService.UpdateMachinesMulti)
ReplicatedStorage.RemoteFunction.GetCurrentMachineMulti.OnServerInvoke = MachineService.GetMachineInfo
ReplicatedStorage.RemoteEvents.SettingsEvent.ChageBulkBuyMode.OnServerEvent:Connect(MachineService.ChangeCurrentUpgradeBulk)
ReplicatedStorage.RemoteFunction.GetMachineLuck.OnServerInvoke = MachineService.CalculateMachineLuck

return MachineService
