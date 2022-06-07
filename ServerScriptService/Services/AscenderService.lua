local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules
local SwordStats = require(SharedModules.SwordStats)

local DataStoreService = require(Services.DataStoreService)
local MachineClass = require(Services.MachineService.MachineClass)
local BaseService = require(Services.BaseService)
local SwordService = require(Services.SwordService)

local AscenderService = {}
AscenderService.Random = Random.new()
AscenderService.AscenderObjects = {}

AscenderService.StatAlias = {
	["Mold"] = "Mold";
	["Quality"] = "Quality";
	["Class"] = "Class";
	["Level"] = "Level";
	["Enchant"] = {"Sharpness","Resistance"};
	["Rarity"] = "Rarity"	
}

AscenderService.MachineNames = {
	["Mold"] = "Molder";
	["Quality"] = "Polisher";
	["Class"] = "Classifier";
	["Level"] = "Upgrader";
	["Enchant"] = "Enchanter";
	["Rarity"] = "Appraiser"	
	
}

AscenderService.StatColors = {
	["Mold"] = Color3.fromRGB(73, 164, 236);
	["Quality"] = Color3.fromRGB(214, 221, 78);
	["Class"] = Color3.fromRGB(27, 171, 16);
	["Level"] = Color3.fromRGB(236, 91, 55);
	["Enchant"] = Color3.fromRGB(99, 192, 202);
	["Rarity"] = Color3.fromRGB(225, 96, 229)	;
}

AscenderService.AllowedModes = {"Mold","Rarity","Quality","Class","Level","Enchant"}

function AscenderService:_GenerateRNG(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineMode = Data.FactoryInfo.AscenderMode
		local MachineName = self.MachineNames[MachineMode]
		local MachineInformation_1 = Data.FactoryInfo.MachineInformation_1[MachineName]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local PlayerLevel = Data.PlayerData.Level
			local MachinePrestige = MachineInformation_1.Prestige
			return self.Random:NextNumber()/25/(1+(0.01*PlayerLevel))/(1+(0.02*MachineLevel))/(0.75+(0.25*MachinePrestige))
		end
	end
end


function AscenderService:DisplayMessage(Player,Message)
	local AscenderObject = self.AscenderObjects[Player]
	if AscenderObject then
		local AscenderScreen =	AscenderObject.AscenderInstance.Screen.Gui
		AscenderScreen.Frame.Notice.Text = Message
	end
end

function AscenderService:_UpgradeItem(Player,SwordObject,StatToUpgrade)
	if StatToUpgrade == "Level" then
		local PlayersData = DataStoreService.ReturnPlayersData(Player)
		if PlayersData then
			if SwordObject.Config.Level + 1 < PlayersData.PlayerData.Level then
				SwordObject.Config.Level += 1
				AscenderService:DisplayMessage(Player,"Sucessfully leveled up sword to level" .. tostring(SwordObject.Config.Level))
				ReplicatedStorage.RemoteEvents.SwordChanged:FireClient(Player,SwordObject)
			else
				AscenderService:DisplayMessage(Player,"Failed to Upgrade Sword")
			end
		end
	elseif StatToUpgrade == "Sharpness" or StatToUpgrade ==  "Resistance" then
		local StatValue = SwordObject.Config[StatToUpgrade]
		local NewEnchant = MachineClass:CalculateEnchantLevel(Player)
		if NewEnchant > StatValue then
			AscenderService:DisplayMessage(Player,"Sucessfully Enchanted Sword")
			SwordObject.Config[StatToUpgrade] = NewEnchant
			ReplicatedStorage.RemoteEvents.SwordChanged:FireClient(Player,SwordObject)
		else
			AscenderService:DisplayMessage(Player,"Failed to Upgrade Sword")
		end
	else
		local Luck = self:_GenerateRNG(Player)
		local Stats = SwordStats[StatToUpgrade]
		if Luck and Stats then
			for _, Stat in ipairs(Stats) do
				if Luck <= 1/Stat.Chance then
					if Stat.Identifier > SwordObject.Config[StatToUpgrade] then
						AscenderService:DisplayMessage(Player,"Sucessfully Changed Sword Stat " .. StatToUpgrade .. " To " .. Stat.Name )
						SwordObject.Config[StatToUpgrade] = Stat.Identifier
						ReplicatedStorage.RemoteEvents.SwordChanged:FireClient(Player,SwordObject)
					else
						AscenderService:DisplayMessage(Player,"Failed to Upgrade Sword")
					end
					return;
				end
			end
			AscenderService:DisplayMessage(Player,"Failed to Upgrade Sword")
		end
	end
end

function AscenderService:UpgradeItem(Player,SwordObject)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineMode = Data.FactoryInfo.AscenderMode
		local Allias = self.StatAlias[MachineMode]		
		if typeof(Allias) == "table" then
			for _,Stat in pairs(Allias) do
				self:_UpgradeItem(Player,SwordObject,Stat)
			end
		else
			self:_UpgradeItem(Player,SwordObject,Allias)
		end
		self:UpdateSwordDisplay(self.AscenderObjects[Player].DisplaySword,SwordObject.Config,Player)
	end
end

function AscenderService:CalculateDelay(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayersProfile then
		local CurrentlySelectedMode = PlayersProfile.Profile.Data.FactoryInfo.AscenderMode
		if CurrentlySelectedMode then
			local MachineName = self.MachineNames[CurrentlySelectedMode]
			local MachineObject = PlayersProfile.Profile.Data.FactoryInfo.MachineInformation_1[MachineName]
			local MachineLevel = MachineObject.Level
			local FasterAscenderGamepass = if PlayersProfile.PlayersGamepasses["Faster Ascender"] then 2 else 1
			return math.max(math.floor(30/(1+(0.02*MachineLevel))*10)/10,1)/FasterAscenderGamepass -- TODO add in gamepass support
		end
	end
end

function AscenderService:StartUpgradingSword(Player,SwordObject) -- TODO add in player leave cleanup
	local AscenderEvent = AscenderService.AscenderObjects[Player]
	if AscenderEvent and AscenderEvent.Event then
		AscenderService:StopUpgradingSword(Player)
	end
	warn("Setting Ascending Status to true")
	SwordService:AscendSword(Player,SwordObject.ID,true)
	AscenderService:DisplaySword(Player,SwordObject)
	local AscenderScreen = AscenderService.AscenderObjects[Player].AscenderInstance.Screen.Gui
		AscenderService.AscenderObjects[Player].CurrentSword = SwordObject
		local EndingTime = workspace:GetServerTimeNow() + AscenderService:CalculateDelay(Player)
		AscenderService.AscenderObjects[Player].Event = game["Run Service"].Heartbeat:Connect(function()
			local TimeLeft = EndingTime - workspace:GetServerTimeNow()
			if TimeLeft < 0 then
				AscenderService:UpgradeItem(Player,SwordObject)
				EndingTime = workspace:GetServerTimeNow() + AscenderService:CalculateDelay(Player)
			else
				if AscenderScreen then -- Cleanup errors
					AscenderScreen.Frame.Countdown.Text = string.format("%02d:%02d", TimeLeft/60%60, TimeLeft%60) 
				end
			end
		end)
end

function AscenderService:StopUpgradingSword(Player)
	local AscenderEvent = AscenderService.AscenderObjects[Player]
	if AscenderEvent and AscenderEvent.Event then
		AscenderEvent.Event:Disconnect()
		if AscenderEvent.CurrentSword then
			warn("Setting Ascending Status to false")
			SwordService:AscendSword(Player,AscenderEvent.CurrentSword.ID,false)
			AscenderEvent.DisplaySword:Destroy()
		end
		local AscenderScreen = AscenderService.AscenderObjects[Player].AscenderInstance.Screen.Gui
		AscenderScreen.Frame.Countdown.Text = "00:00"
		AscenderEvent = nil
	end
end


function AscenderService:UpdateColors(Player,AscenderMode)
	local PlayerInfo = self.AscenderObjects[Player]
	if PlayerInfo then
		local AscenderScreen = PlayerInfo.AscenderInstance.Screen.Gui
		for i, Beam in pairs(PlayerInfo.AscenderInstance.Model.Beams:GetChildren()) do -- Sets the beams color
			local AssociatedColor = self.StatColors[AscenderMode]
			Beam.Color = ColorSequence.new(AssociatedColor)
		end
		for _, ColoredPart in pairs(PlayerInfo.AscenderInstance.Colored_Parts:GetChildren()) do
			ColoredPart.Color = self.StatColors[AscenderMode]
		end
		AscenderScreen.Frame.Countdown.TextColor3 = AscenderService.StatColors[AscenderMode]
	end
end

function AscenderService:UpdateSwordDisplay(Sword,SwordObject,Player)
	for StatName, StatValue in pairs(SwordObject) do
		local RelatedTextLabel = Sword.Main.Gui:FindFirstChild(StatName)
		if RelatedTextLabel then
			if SwordStats[StatName] then
				local StatInformation = SwordStats.FindObjectFromIdentifier(SwordStats[StatName],StatValue)
				if StatInformation then
					RelatedTextLabel.Text = StatInformation.Name
					RelatedTextLabel.TextColor3 = Color3.fromHex(StatInformation.Color) 
				end
			else
				RelatedTextLabel.Text = StatName .. ": " .. StatValue
			end
		end
	end
	Sword.Main.Gui.PlayersName.Text = Player.Name
end


function AscenderService:DisplaySword(Player,SwordObject)
	local PlayerInfo = self.AscenderObjects[Player]
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
	if PlayerInfo and PlayersProfile then
		local DisplaySword = PlayerInfo.DisplaySword
		local Data = PlayersProfile.Profile.Data
		local MachineMode = Data.FactoryInfo.AscenderMode
		if DisplaySword then
			DisplaySword:Destroy()
			DisplaySword = nil;
		end
		local SwordTemplate = ReplicatedStorage.Assets.BeltSword:Clone()
		SwordTemplate:PivotTo(PlayerInfo.AscenderInstance.Stand:GetPivot():ToWorldSpace(CFrame.new(0,2,0)) * CFrame.Angles(0,math.rad(90),0))
		SwordTemplate.Parent = PlayerInfo.AscenderInstance
		PlayerInfo.DisplaySword = SwordTemplate
		self:UpdateSwordDisplay(SwordTemplate,SwordObject.Config,Player)
		self:UpdateColors(Player,MachineMode)
	end
end

function AscenderService:PlayerLeft(Player)
	local AscenderEvent = AscenderService.AscenderObjects[Player]
	if AscenderEvent and AscenderEvent.Event then
		AscenderEvent.Event:Disconnect()
	end
end

function AscenderService:PlayerJoined(Player)
	local PlayersBase = BaseService.GetBaseFromPlayer(Player)
	if PlayersBase then
		local Ascender = PlayersBase.Structures.Ascender
		AscenderService.AscenderObjects[Player] = {}
		AscenderService.AscenderObjects[Player].AscenderInstance = Ascender
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			local SwordInAscender = PlayersProfile.Profile.Data.FactoryInfo.SwordInAscender
			if SwordInAscender and PlayersProfile.Profile.Data.FactoryInfo.AscenderMode then
				local SwordInformation = SwordService.GetSwordInfo(SwordInAscender)
				if SwordInformation then
					print(SwordInformation)
					self:StartUpgradingSword(Player,SwordInformation)
				end
			end
		end
	end
end

function AscenderService.UpdateAscenderMode(Player,NewMode)
	if table.find(AscenderService.AllowedModes,NewMode) then
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			PlayersProfile.Replica:SetValue({"FactoryInfo","AscenderMode"},NewMode)
			AscenderService:UpdateColors(Player,NewMode)
			local PlayerInfo = AscenderService.AscenderObjects[Player]
			if PlayerInfo and PlayerInfo.CurrentSword then
				AscenderService:StartUpgradingSword(Player,PlayerInfo.CurrentSword)
			end
		end
	end
end

ReplicatedStorage.RemoteEvents.UpdateSelectedAscenderItem.OnServerEvent:Connect(AscenderService.UpdateAscenderMode)




return AscenderService
