local SwordToolService = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SwordService = require(game.ServerScriptService.Services.SwordService)
local DataStoreService = require(game.ServerScriptService.Services.DataStoreService)
local SwordStats = require(game.ReplicatedStorage.Modules.SharedModules.SwordStats)
local MobService = require(game.ServerScriptService.Services.MobService)
local BoostService =require(game.ServerScriptService.Services.BoostService)
local BaseService = require(game.ServerScriptService.Services.BaseService)

local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local ToolDebounce = {}

function SwordToolService.AddSword(Sword)
	ToolDebounce[Sword] = os.clock()
	local HitBox = Sword:FindFirstChild("HitBox")
	if HitBox then
		HitBox.Touched:Connect(function(PartHit)
			SwordToolService.SwordHit(Sword,PartHit)
		end)
	end
	Sword.Activated:Connect(function()
		if ToolDebounce[Sword] - os.clock() <= 0 then
			SwordToolService.SwordActivated(Sword)
		end
	end)
	Sword.Equipped:Connect(function()
		SwordToolService.SwordEquipped(Sword)
	end)
	Sword.Unequipped:Connect(function()
		SwordToolService.SwordUnequipped(Sword)
	end)
end


local Animation = Instance.new("Animation")
Animation.AnimationId = "rbxassetid://522635514"


function SwordToolService.SwordActivated(Sword)
	local Character = Sword.Parent
	if Character then
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			local Animator = Humanoid:FindFirstChildOfClass("Animator")
			if Animator then
				ToolDebounce[Sword] = os.clock() + 0.4
				Animator:LoadAnimation(Animation):Play()
			end
		end
	end
end

function SwordToolService.SwordEquipped(Sword)
	local Character = Sword.Parent
	if Character then
		local Humanoid = Character:FindFirstChild("Humanoid")
		if Humanoid then
			local SwordConfig = SwordService.GetSwordInfo(Sword:GetAttribute("SwordID"))
			if SwordConfig then
				local BossHealthMulti =if Humanoid:GetAttribute("IsBoss") then 5 else 1
				local Rarity = SwordStats.FindObjectFromIdentifier(SwordStats.Rarity,SwordConfig.Config.Rarity)
				local Class = SwordStats.FindObjectFromIdentifier(SwordStats.Class,SwordConfig.Config.Class)
				local CharacterHealth = 100*(1.04^SwordConfig.Config.Level)*Rarity.PowerMultiplier * Class.PowerMultiplier * BossHealthMulti
				local CurrentHealthReduction = Humanoid.Health/Humanoid.MaxHealth
				Humanoid.MaxHealth = CharacterHealth
				Humanoid.Health = CharacterHealth * CurrentHealthReduction
				if not Humanoid:GetAttribute("NPC") then
					local Player = Players:GetPlayerFromCharacter(Humanoid.Parent)  
					if Player then
						local Profile = DataStoreService.ReturnPlayersProfile(Player)
						if Profile then
							if Profile.PlayersGamepasses["More Health"] then
								local BoostedHealth = CharacterHealth + (CharacterHealth * 0.50)
								Humanoid.MaxHealth = BoostedHealth
								Humanoid.Health = BoostedHealth/CurrentHealthReduction
							end
							if  BoostService:FindBoostWithType(Player,"HealthBoost") then
								Humanoid.MaxHealth *= 3
								Humanoid.Health *= 3
							end
						end
					end
				end
			end
		end
	end
end


function SwordToolService.SwordUnequipped(Sword)
	local Backpack = Sword.Parent
	if Backpack then
		local Player = Backpack.Parent
		if Player and Player:IsA("Player") then
			local Character = Player.Character
			if Character then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					local HealthReduction = Humanoid.Health/Humanoid.MaxHealth
					Humanoid.MaxHealth = 100;
					Humanoid.Health = 100 * HealthReduction;
				end
			end
		end
	end
end

function SwordToolService.CalculateSwordDamange(Config)
	local Sharpness = Config.Sharpness
	local Rarity = SwordStats.FindObjectFromIdentifier(SwordStats.Rarity,Config.Rarity)
	local Class = SwordStats.FindObjectFromIdentifier(SwordStats.Class,Config.Class)
	local SwordLevel = Config.Level
	if Sharpness and Rarity and Class and SwordLevel then
		return 1*(1.035^SwordLevel)*(1+0.2*Sharpness)*Rarity.PowerMultiplier*Class.PowerMultiplier
	end
end

local maxX = (ReplicatedStorage.UI.DamageIndicator.AbsoluteSize.X / 6)
local maxY = (ReplicatedStorage.UI.DamageIndicator.AbsoluteSize.Y / 6)


function ClampPosition(CF)
	local screenPosition = workspace.CurrentCamera:WorldToViewportPoint(CF.Position)
	local indicatorX = screenPosition.X
	local indicatorY = screenPosition.Y
	
	indicatorX = math.clamp(indicatorX, maxX, (ReplicatedStorage.UI.DamageIndicator.AbsoluteSize.X - maxX))
	indicatorY = math.clamp(indicatorY, maxY, (ReplicatedStorage.UI.DamageIndicator.AbsoluteSize.Y - maxY))

	return indicatorX, indicatorY
end

function SwordToolService.SwordHit(Sword,PartHit)
	if PartHit.Parent then
		local AttackerHumanoid =  Sword.Parent:FindFirstChildOfClass("Humanoid")
		local VictimHumanoid =  PartHit.Parent:FindFirstChildOfClass("Humanoid")

		if VictimHumanoid and AttackerHumanoid then
			local AttackerNPC = AttackerHumanoid:GetAttribute("NPC")
			local VictimNPC = VictimHumanoid:GetAttribute("NPC")
			
			if AttackerNPC and VictimNPC then return end

			if AttackerHumanoid.Health > 0 then
				if not AttackerNPC and not VictimNPC then
					local VictimPlayer = Players:GetPlayerFromCharacter(VictimHumanoid.Parent)
					if VictimPlayer then
						local VictiumsBase = BaseService.GetBaseFromPlayer(VictimPlayer)
						if VictiumsBase then
							if (VictimHumanoid.Parent.HumanoidRootPart.Position - VictiumsBase.Spawn.Position).Magnitude < 100 then
								return
							end
						end
					end
				end
				local AttackerSwordConfig = SwordService.GetSwordInfo(Sword:GetAttribute("SwordID"))
				local CalculatedDamage = SwordToolService.CalculateSwordDamange(AttackerSwordConfig.Config)		
				VictimHumanoid:TakeDamage(CalculatedDamage)
				if #VictimHumanoid.Parent.Head:GetChildren() < 10 then
					local DamageIndicator = ReplicatedStorage.UI.DamageIndicator:Clone()
					local indicatorX,indicatorY = ClampPosition(VictimHumanoid.Parent.Head.CFrame)
					DamageIndicator.StudsOffset = Vector3.new(0.5 + math.random(0,1),math.random(0,5),0.5 + math.random(0,1))
					DamageIndicator.DamageIndicator.Text = Short(CalculatedDamage,1)
					DamageIndicator.Parent = VictimHumanoid.Parent.Head
					task.delay(0.5,DamageIndicator.Destroy,DamageIndicator)
				end
			end
			if VictimHumanoid.Health < 0 then
				if VictimNPC == true and not AttackerNPC  then
					if VictimHumanoid:GetAttribute("Killed") == false then
						VictimHumanoid:SetAttribute("Killed",true)
						if VictimHumanoid:GetAttribute("IsBoss") then
							local Player = Players:GetPlayerFromCharacter(AttackerHumanoid.Parent)
							if Player then
								local Profile = DataStoreService.ReturnPlayersProfile(Player)
								if Profile then
									if Random.new():NextNumber() < .35 then
										local VictimSword = VictimHumanoid.Parent:FindFirstChildOfClass("Tool")
										if VictimSword then
											local SwordsID = VictimSword:GetAttribute("SwordID")
											if SwordsID then
												local SwordInformation = SwordService.GetSwordInfo(SwordsID)
												if SwordInformation then
													local SwordInstance = SwordService.NewSword(Player,SwordInformation.Config)
													SwordService.SendSwordToSellingUI(Player,SwordInstance:GetAttribute("SwordID"))
													SwordService.BankSword(Player,SwordInstance:GetAttribute("SwordID"))
												end
											end
										end
									end
									local RandomBossCoinAmount = Random.new():NextInteger(5,50)
									Profile.Replica:SetValue({"PlayerData","BossCoins"},Profile.Profile.Data.PlayerData.BossCoins + RandomBossCoinAmount)
								end
							end
						end
						local VictimSword = VictimHumanoid.Parent:FindFirstChildOfClass("Tool")
						if VictimSword then
							local SwordsID = VictimSword:GetAttribute("SwordID")
							if SwordsID then
								SwordService.CleanUpSword(SwordsID)
							end
						end
					end
				end
				
			end
		end
	end
end



function SwordToolService.Init()
	for _,Sword in pairs(CollectionService:GetTagged("Sword")) do
		SwordToolService.AddSword(Sword)
	end
	CollectionService:GetInstanceAddedSignal("Sword"):Connect(function(Sword)
		SwordToolService.AddSword(Sword)
	end)

end

return SwordToolService
