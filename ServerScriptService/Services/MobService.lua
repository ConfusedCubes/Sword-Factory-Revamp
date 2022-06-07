local MobService = {}

-- THis module is really ugly sorry.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local SharedModules = ReplicatedStorage.Modules.SharedModules
local SwordStats = require(SharedModules.SwordStats)
local SwordService = require(game.ServerScriptService.Services.SwordService)
local DataStoreService  = require(game.ServerScriptService.Services.DataStoreService)
local RandomService = require(game.ServerScriptService.Services.RandomService)

local Short = require(SharedModules.Short)

MobService.RandomGenerator = Random.new()


MobService.LocationModifers = {
	["Island1"] = {
		Level = .3; -- 70% reduction
		Luck = 1; -- 0% Reduction (** A HIGHER LUCK MEANS HIGHER RARITY ** )
	},
	["Island2"] = {
		Level = 0.5; -- 50% reduction
		Luck = 1000; -- 0% Reduction (** A HIGHER LUCK MEANS HIGHER RARITY ** )
	},
	["Island3"] = {
		Level = 0.85; -- 25% reduction
		Luck = 10_000; -- 0% Reduction (** A HIGHER LUCK MEANS HIGHER RARITY ** )
	};
	["Island4"] = {
		Level = 0.95; -- 25% reduction
		Luck = 30_000; -- 0% Reduction (** A HIGHER LUCK MEANS HIGHER RARITY ** )
	};
	["Island5"] = {
		Level = 1; -- 25% reduction
		Luck = 50_000; -- 0% Reduction (** A HIGHER LUCK MEANS HIGHER RARITY ** )
	}
}

function MobService:GenerateMobConfig(CalculatedLuck,ModifierTable,isBoss)
	local Config = {}
	local IsBossModifer = if isBoss then 5000 else 1
	CalculatedLuck /= IsBossModifer
	for StatName,StatTable in pairs(SwordStats) do
		if typeof(StatTable) == "table" then
			for _, Stat in ipairs(StatTable) do				
				if (CalculatedLuck/ModifierTable.Luck) <= 1/Stat.Chance then
					Config[StatName] = Stat.Identifier
					break;
				end
			end
		end
	end
	Config.Level = math.round(MobService.CalculateAverageOfAllPlayersLuck() * self.RandomGenerator:NextNumber(90,105)/100 * ModifierTable.Level) -- The level is 90-105% of the Average of every players level Multiplied by the Level Modifier 
	return Config
end

function MobService.CalculateAverageOfAllPlayersLuck()
	local PlayerList = Players:GetPlayers() 
	local Temp = 0;
	local Count = 0; -- Needed because not every player will have their profile loaded causing the average to be incorrectly calculated;
	for _, Player in pairs(PlayerList) do
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			local PlayersLevel = PlayersProfile.Profile.Data.PlayerData.Level
			if PlayersLevel then
				Temp += PlayersLevel
				Count += 1;
			end
		end
	end
	
	local AverageLuck = Temp/Count
	if AverageLuck ~= AverageLuck then
		AverageLuck = 50
	end
	return AverageLuck
end

function MobService.FindNearestCharacter(NPC)
	for _,Player in pairs(Players:GetPlayers()) do
		local PlayersCharacter = Player.Character
		if PlayersCharacter then
			local HumanoidRootPart = PlayersCharacter:FindFirstChild("HumanoidRootPart")
			if HumanoidRootPart then
				local DistanceBetween = (HumanoidRootPart.Position - NPC.HumanoidRootPart.Position).Magnitude
				if DistanceBetween < 50 then
					return PlayersCharacter
				end
			end
		end
	end
end


function MobService:UpdateMobHealthLabel(MobInstance)
	local MobTitleTag = MobInstance.Head.TitleTag
	local HealthTextLabel = MobTitleTag.Health
	local MobHumanoid = MobInstance.Humanoid


	local Health = math.max(MobHumanoid.Health,0)
	local MaxHealth = math.max(MobHumanoid.MaxHealth,0)
	local HealthColor = Color3.new(1, 0, 0.133333):Lerp(Color3.new(0.0784314, 0.729412, 0.0313725), Health/MaxHealth)
	HealthTextLabel.TextColor3 = HealthColor
	HealthTextLabel.Text =  Short(Health) .. "/" ..Short(MaxHealth).. "HP"
end



function MobService.MoveNPCToPosition(NPC,Position)
	local Humanoid = NPC:FindFirstChild("Humanoid")
	if Humanoid then
		Humanoid:MoveTo(Position)
	end
end

function MobService:InitAI(Mob)
	local Event; Event = RunService.Heartbeat:Connect(function()
		local NearestCharacer = MobService.FindNearestCharacter(Mob)
		if NearestCharacer then
			MobService.MoveNPCToPosition(Mob,NearestCharacer.HumanoidRootPart.Position)
		end
	end)
	local Humanoid = Mob:FindFirstChild("Humanoid")
	local DiedEvent; DiedEvent = Humanoid.Died:Connect(function()
		Event:Disconnect()
		DiedEvent:Disconnect()
		task.delay(5,Mob.Destroy,Mob)
	end)
end

function MobService:CreateMobSwordInstance(MobInstance,SwordInstance)
	local MobHumanoid = MobInstance:FindFirstChildOfClass("Humanoid")
	if MobHumanoid then
		SwordInstance.HitBox.Size *= Vector3.new(1,1,5) -- Expand the Hitbox 
		SwordInstance.Parent = MobInstance
		MobHumanoid:EquipTool(SwordInstance)
		SwordInstance.HitBox.Position -= Vector3.new(1,0,-5) -- RePosition
	end	
end

function MobService:GenerateMob(Location)
	local Luck = self.RandomGenerator:NextNumber()/(1+RandomService.ServerLuck/5)/1
	local IsBoss = Random.new():NextNumber() < 0.20
	local MobConfig = self:GenerateMobConfig(Luck,self.LocationModifers[Location],IsBoss)
	local MobSwordInstance, SwordConfig = SwordService.NewSword(nil,MobConfig)
	local MobInstance = self:CreateMobInstance(SwordConfig,IsBoss)
	self:PositionMobAtLocation(MobInstance,Location)
	self:CreateMobSwordInstance(MobInstance,MobSwordInstance)
	self:InitAI(MobInstance)
end

function MobService:CreateMobInstance(SwordConfig,IsBoss)
	local MobInstance = ReplicatedStorage.Assets.Noob:Clone()
	local MobTitleTag = MobInstance.Head.TitleTag
	local BossTag = if IsBoss then "[BOSS!]" else ""
	if IsBoss then
		local Sparkles = Instance.new("Sparkles")
		Sparkles.Parent = MobInstance.HumanoidRootPart
	end

	local RarityInformation = SwordStats.FindObjectFromIdentifier(SwordStats.Rarity,SwordConfig.Rarity) -- Sets the Mobs Title
	MobTitleTag.Title.Text = BossTag .. "[Level: " ..tostring(SwordConfig.Level) .. "]" .. RarityInformation.Name
	MobTitleTag.Title.TextColor3  = Color3.fromHex(RarityInformation.Color)
	

	local CalculatedHealth = math.round(3*(1.05^SwordConfig.Rarity)) -- Sets the Mobs Health
	MobInstance.Humanoid.MaxHealth = CalculatedHealth
	MobInstance.Humanoid.Health =  CalculatedHealth
	MobInstance.Humanoid:SetAttribute("IsBoss",IsBoss)
	self:UpdateMobHealthLabel(MobInstance)
	self:SetUpMobEvents(MobInstance)
	return MobInstance
end


function MobService:SetUpMobEvents(MobInstance)
	local Humanoid = MobInstance:FindFirstChildOfClass("Humanoid")
	if Humanoid then
		Humanoid:GetPropertyChangedSignal("Health"):Connect(function(NewValue) -- TODO cleannup this
			if MobInstance.Parent then
				self:UpdateMobHealthLabel(MobInstance)
			end
		end)	
	end
end

function MobService:PositionMobAtLocation(MobInstance,LocationName)
	local LocationInstance = workspace.Islands:FindFirstChild(LocationName)
	if LocationInstance then
		local LocationFloor = LocationInstance.SpawnArea
		local MinX = LocationFloor.Position.X - LocationFloor.Size.X/2
		local MaxX = LocationFloor.Position.X + LocationFloor.Size.X/2

		local MinZ = LocationFloor.Position.Z - LocationFloor.Size.Z/2
		local MaxZ = LocationFloor.Position.Z + LocationFloor.Size.Z/2

		local SpawnPosition = Vector3.new(math.random(MinX,MaxX),  LocationFloor.Position.Y + 5 ,math.random(MinZ,MaxZ))
		MobInstance.Parent = workspace.Mobs
		MobInstance:SetPrimaryPartCFrame(CFrame.new(SpawnPosition))
	else
		warn("Can't find the LinkedLocation, Did you spell it correctly? ")
		warn(LocationName)
	end
end


function MobService.Init()
	local EndTime = os.time() + 5;
	RunService.Heartbeat:Connect(function()
		local TimeLeft = EndTime - os.time()
		if TimeLeft <= 0 then -- Time to generate a boss
			if #workspace.Mobs:GetChildren() < 150 then
				task.spawn(MobService.GenerateMob,MobService,"Island1")
				task.spawn(MobService.GenerateMob,MobService,"Island2")				
				task.spawn(MobService.GenerateMob,MobService,"Island3")
				task.spawn(MobService.GenerateMob,MobService,"Island4")
				task.spawn(MobService.GenerateMob,MobService,"Island5")				
			end
			EndTime = os.time() + 5 -- Rest the Timer
		end
	end)	
end


return MobService
