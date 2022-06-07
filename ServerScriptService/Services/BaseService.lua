
local BaseService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Players = game:GetService("Players")

local Services = ServerScriptService.Services

local MachineService = require(Services.MachineService)
local DataStoreService = require(Services.DataStoreService)
local BoostService = require(Services.BoostService)

local BaseCreated = ReplicatedStorage.RemoteEvents.BaseCreated
BaseService.PlayerBases = {}
BaseService.PlayerLocations = {
	{Occupied = false, CFrame = CFrame.new(5000,-45000,5000)};
	{Occupied = false, CFrame = CFrame.new(5000,-45000,10000)};
	{Occupied = false, CFrame = CFrame.new(10000,-45000,5000)};
	{Occupied = false, CFrame = CFrame.new(10000,-45000,10000)};
	{Occupied = false, CFrame = CFrame.new(15000,-45000,5000)};
	{Occupied = false, CFrame = CFrame.new(15000,-45000,10000)};
	{Occupied = false, CFrame = CFrame.new(20000,-45000,5000)};
	{Occupied = false, CFrame = CFrame.new(20000,-45000,10000)};
	{Occupied = false, CFrame = CFrame.new(25000,-45000,5000)};
	{Occupied = false, CFrame = CFrame.new(25000,-45000,10000)};
}



function BaseService.GetBaseFromPlayer(Player)		
	return BaseService.PlayerBases[Player]
end

function BaseService:FindUnoccupiedLocation()
	for Index,Location in pairs(self.PlayerLocations) do
		if not Location.Occupied then
			return Location
		end
	end
end

function BaseService.CreateBase(Player)
	local NewBase = ReplicatedStorage.Assets.Base:Clone()
	NewBase.Name = Player.Name .. "'s Base"
	BaseService.PlayerBases[Player] = NewBase
	local NewLocationObject = BaseService:FindUnoccupiedLocation()
	if not NewLocationObject then Player:Kick("Can't find a unoccupied Location, You should never see this") end
	NewLocationObject.Occupied = Player;
	NewBase:PivotTo(NewLocationObject.CFrame) -- TODO CHANGE THIS
	NewBase.Parent = workspace

	local Character = Player.Character
	if Character then
		task.wait()
		Character:PivotTo(NewBase:WaitForChild("Spawn"):GetPivot())
	end
	Player.CharacterAdded:Connect(function(NewCharacter)
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			if PlayersProfile.PlayersGamepasses["More Health"] then
				NewCharacter.Humanoid.MaxHealth += 50
				NewCharacter.Humanoid.Health += 50
				NewCharacter.Humanoid:SetAttribute("ExtraHealthPercentage",50)
			end
			if BoostService:FindBoostWithType(Player,"HealthBoost") then
				NewCharacter.Humanoid.MaxHealth *= 3
				NewCharacter.Humanoid.Health *= 3
			end
		end
		RunService.Heartbeat:Wait()
		NewCharacter:PivotTo(NewBase:WaitForChild("Spawn"):GetPivot())
	end)

	MachineService.Init(NewBase,Player)
	BaseCreated:FireClient(Player,NewBase)
	ReplicatedStorage.RemoteEvents.TeleportBaseChanged:FireAllClients(Player,true)
	BaseService:StartBaseEffects(NewBase)
	return NewBase
end

function BaseService:StartBaseEffects(Base)
	local Drill = Base.Structures.FactoryLine.Drill.Drill.Machine.MainDrill
	local CFrameValue = Instance.new("CFrameValue")
	CFrameValue.Value = Drill.TweenThingy:GetPivot()
	CFrameValue.Changed:Connect(function(NewValue)
		if Drill and Drill:FindFirstChild("TweenThingy") then
			Drill.TweenThingy:PivotTo(CFrameValue.Value)
		end
	end)
	local Tween = TweenService:Create(Drill.Drill,TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1,true),{Orientation = Vector3.new(0,400,0),Position = Drill.Drill.Position - Vector3.new(0,8,0)})
	local LowerTween = TweenService:Create(CFrameValue,TweenInfo.new(5,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1,true),{Value =  Drill.TweenThingy:GetPivot() - Vector3.new(0,8,0)})
	
	LowerTween:Play()
	Tween:Play()
end

function BaseService.DestroyBase(Player)
	if BaseService.PlayerBases[Player] then
		BaseService.PlayerBases[Player]:Destroy()
		BaseService.PlayerBases[Player] = nil;
		for i,v in pairs(BaseService.PlayerLocations) do
			if v.Occupied == Player then
				v.Occupied = nil;
			end
		end
	end
end

function BaseService.GetBaseFromPlayerYeildUntilFound(Player)
	if BaseService.PlayerBases[Player] then
		return BaseService.PlayerBases[Player]
	else
		local Base = workspace:WaitForChild(Player.Name .. "'s Base")
		return Base
	end
end

function BaseService.AllowVistorsChanged(Player,NewValue)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Currentvalue = PlayersProfile.Replica.Data.PlayerData.Settings.AllowVistors
		local NewValue = not Currentvalue
		PlayersProfile.Replica:SetValue({"PlayerData","Settings","AllowVistors"},NewValue)
		ReplicatedStorage.RemoteEvents.TeleportBaseChanged:FireAllClients(Player,NewValue)
	end
end


function BaseService.MuteMusicChanged(Player,NewValue)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Currentvalue = PlayersProfile.Replica.Data.PlayerData.Settings.MuteMusic
		local NewValue = not Currentvalue
		PlayersProfile.Replica:SetValue({"PlayerData","Settings","MuteMusic"},NewValue)
	end
end


function BaseService.AutoBankChanged(Player,NewValue)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Currentvalue = PlayersProfile.Replica.Data.PlayerData.Settings.AutoBank
		local NewValue = not Currentvalue
		PlayersProfile.Replica:SetValue({"PlayerData","Settings","AutoBank"},NewValue)
	end
end

function BaseService.AutoBankModeChanged(Player,NewValue)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local AllowedValues = {"Mold","Quality","Class"}
		print(NewValue)
		if table.find(AllowedValues,NewValue) then
			PlayersProfile.Replica:SetValue({"PlayerData","Settings","AutoBankMode"},NewValue)
		else
			warn("Didn't FINd")
		end
	end
end


function BaseService.IncreaseAutobank(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Currentvalue = PlayersProfile.Replica.Data.PlayerData.Settings.AutoBankLimit
		local NewValue = math.min(Currentvalue * 10,10_000_000_000)
		PlayersProfile.Replica:SetValue({"PlayerData","Settings","AutoBankLimit"},NewValue)
	end
end

function BaseService.DecreaseAutoBank(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Currentvalue = PlayersProfile.Replica.Data.PlayerData.Settings.AutoBankLimit
		local NewValue = math.max(Currentvalue/10,100)
		PlayersProfile.Replica:SetValue({"PlayerData","Settings","AutoBankLimit"},NewValue)
	end
end



function BaseService.GetTeleportablePlayerBases(Asker)
	local AllowedBases = {}
	for _,Player in pairs(Players:GetPlayers()) do
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			if PlayersProfile.Profile.Data.PlayerData.Settings.AllowVistors and Player ~= Asker then 
				table.insert(AllowedBases,Player)
			end
		end
	end
	return AllowedBases
end


function BaseService.TeleportToPlayersBase(Player,TeleportToPlayer)
	local PlayersCharacter = Player.Character
	if PlayersCharacter then
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(TeleportToPlayer)
		if PlayersProfile then
			if PlayersProfile.Profile.Data.PlayerData.Settings.AllowVistors then
				local TeleportToPlayerBase = BaseService.PlayerBases[TeleportToPlayer]
				if TeleportToPlayerBase then
					PlayersCharacter:PivotTo(TeleportToPlayerBase.Spawn:GetPivot())
				end
			end
		end
	end
end




ReplicatedStorage.RemoteFunction.GetTeleportableBases.OnServerInvoke = BaseService.GetTeleportablePlayerBases
ReplicatedStorage.RemoteFunction.GetBaseInstance.OnServerInvoke = BaseService.GetBaseFromPlayerYeildUntilFound
ReplicatedStorage.RemoteEvents.SettingsEvent.AllowVistors.OnServerEvent:Connect(BaseService.AllowVistorsChanged)
ReplicatedStorage.RemoteEvents.TeleportTo.OnServerEvent:Connect(BaseService.TeleportToPlayersBase)
ReplicatedStorage.RemoteEvents.SettingsEvent.MuteMusic.OnServerEvent:Connect(BaseService.MuteMusicChanged)
ReplicatedStorage.RemoteEvents.SettingsEvent.AutoBank.OnServerEvent:Connect(BaseService.AutoBankChanged)
ReplicatedStorage.RemoteEvents.SettingsEvent.IncreaseAutoBank.OnServerEvent:Connect(BaseService.IncreaseAutobank)
ReplicatedStorage.RemoteEvents.SettingsEvent.DecreaseAutoBank.OnServerEvent:Connect(BaseService.DecreaseAutoBank)
ReplicatedStorage.RemoteEvents.SettingsEvent.ChangeBankingMode.OnServerEvent:Connect(BaseService.AutoBankModeChanged)

return BaseService
