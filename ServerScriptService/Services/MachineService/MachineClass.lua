local MachineClass = {}
MachineClass.__index = MachineClass


local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules

local Short = require(SharedModules.Short)
local DataStoreService = require(Services.DataStoreService)
local SwordStats = require(SharedModules.SwordStats)
local SwordService = require(Services.SwordService)
local BoostService = require(Services.BoostService)

local Janitor = require(SharedModules.Janitor)
-- As much as I hate OOP, I believe its usesful here
-- Really meh ish implmentation of this you could make it better.

local Random = Random.new()

MachineClass.GlobalLuck = 5

function MachineClass.new(Base,Player)
	local self ={}
	self.Base = Base;
	self.Player = Player; -- Used for levels 
	self.Machines = {
		[1] = {
			Name = "Molder";
			ConfigValue = "Mold";
			Position = Base.Machines.Molder.SwordPosition.Position;
			Occupied = false;
			LinkedObject = Base.Machines.Molder;
			AnimationFunction = function(Modler,Self)
				local Head = Modler.Head
				local UpPosition = Head.PrimaryPart.CFrame
				local FinishedEvent = Instance.new("BindableEvent")
				local CFrameValue = Instance.new("CFrameValue")
				CFrameValue.Value = Head.PrimaryPart.CFrame
				local TotalTimeRequired = self:CalculateTimeRequired("Molder")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)


				local DownTween = TweenService:Create(CFrameValue,TweenInfo.new(TotalTimeRequired/2),{Value = Head.PrimaryPart.CFrame - Vector3.new(0,2,0)})
				local UpTween = TweenService:Create(CFrameValue,TweenInfo.new(TotalTimeRequired/2),{Value = UpPosition})

				local ChangedEvent; ChangedEvent = CFrameValue.Changed:Connect(function()
					Head:PivotTo(CFrameValue.Value)
				end)



				DownTween.Completed:Connect(function()
					UpTween.Completed:Connect(function()
						FinishedEvent:Fire()
					end)
					UpTween:Play()
				end)
				DownTween:Play()

				local Disconnect; Disconnect = FinishedEvent.Event:Connect(function() -- FinishedEvent also serves as the cleanup event 
					Disconnect:Disconnect()
					DownTween:Destroy()
					UpTween:Destroy()
					ChangedEvent:Disconnect()
					CFrameValue:Destroy()
				end)

				FinishedEvent.Event:Wait()
				FinishedEvent:Destroy()
			end,
			MachineFinished = Instance.new("BindableEvent");
		};
		[2] = {
			Name = "Polisher";
			ConfigValue = "Quality";
			Position = Base.Machines.Polisher.SwordPosition.Position;
			LinkedObject = Base.Machines.Polisher;
			AnimationFunction = function(Polisher,Self)
				local TotalTimeRequired = self:CalculateTimeRequired("Polisher")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)
				task.wait(TotalTimeRequired)
			end,
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");


		};
		[3] = {
			Name = "Classifier";
			ConfigValue = "Class";
			LinkedObject = Base.Machines.Classifier;
			Position = Base.Machines.Classifier.SwordPosition.Position;
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");
			AnimationFunction = function(Polisher,Self)
				local TotalTimeRequired = self:CalculateTimeRequired("Classifier")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)
				task.wait(TotalTimeRequired)
			end

		};
		[4] = {
			Name = "Upgrader";
			ConfigValue = "Level";
			UsesAlternativeFunction = true;
			AlternativeFunction = MachineClass.CalculateSwordLevel;
			LinkedObject = Base.Machines.Upgrader;
			Position = Base.Machines.Upgrader.SwordPosition.Position;
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");
			AnimationFunction = function(Polisher,Self)
				local TotalTimeRequired = self:CalculateTimeRequired("Upgrader")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)
				task.wait(TotalTimeRequired)
			end

		};
		[5] = {
			Name = "Enchanter";
			ConfigValue = {"Sharpness","Resistance"};
			LinkedObject = Base.Machines.Enchanter;
			UsesAlternativeFunction = true;
			AlternativeFunction = MachineClass.CalculateEnchantLevel;
			Position = Base.Machines.Enchanter.SwordPosition.Position;
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");
			AnimationFunction = function(Polisher,Self)
				local TotalTimeRequired = self:CalculateTimeRequired("Enchanter")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)
				task.wait(TotalTimeRequired)
			end
		};
		[6] = {
			Name = "Appraiser";
			ConfigValue = "Rarity";
			LinkedObject = Base.Machines.Appraiser;
			Position = Base.Machines.Appraiser.SwordPosition.Position;
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");
			AnimationFunction = function(Polisher,Self)
				local TotalTimeRequired = self:CalculateTimeRequired("Appraiser")
				ReplicatedStorage.RemoteEvents.UpdateMachineTimer:FireClient(self.Player,Self.Name,workspace:GetServerTimeNow() + TotalTimeRequired)
				task.wait(TotalTimeRequired)
			end
		};
		[7] = {
			Name = "SellStation";
			Position = Base.Machines.Appraiser.SwordPosition.Position;
			Occupied = false;
			MachineFinished = Instance.new("BindableEvent");
		}

	}
	self.Janitor = Janitor.new()
	return setmetatable(self, MachineClass)
end


function MachineClass:CreateBlankSword()
	local BlankSword = ReplicatedStorage.Assets.BeltSword:Clone()
	BlankSword.Main.Gui.PlayersName.Text = self.Player.Name
	BlankSword:PivotTo(self.Base.Machines.SwordPosition.CFrame)
	BlankSword.Main.Anchored = true;
	BlankSword.Parent = self.Base.Swords
	self:MoveSword(BlankSword,1)
end


function MachineClass:CalculateSwordsWorth(Config)
	local ValueToMultiply = 1;
	for StatName,Stat in pairs(Config) do
		if SwordStats[StatName] then
			local Information = SwordStats.FindObjectFromIdentifier(SwordStats[StatName],Stat)
			if Information then
				if Information.Multiplier then
					ValueToMultiply *= Information.Multiplier
				end
			end
		end
	end
	return 10*(1.01^Config.Level) * ValueToMultiply
end



function MachineClass:UpdateSwordWorth(Sword,ConfigObject)
	local MainGUI = Sword.Main.Gui
	local TextLabel = MainGUI:FindFirstChild("Worth")
	if TextLabel then
		TextLabel.Text =  string.format("$%s",Short( self:CalculateSwordsWorth(ConfigObject)) )   
	end
end

function MachineClass:UpdateSwordSurfanceGui(Sword,ConfigObject,StatName)
	local MainGUI = Sword.Main.Gui
	local TextLabel = MainGUI:FindFirstChild(StatName)
	if TextLabel then
		if not ConfigObject.Identifier then
			TextLabel.Text = StatName .. ": " .. ConfigObject.Name
		else
			TextLabel.Text = ConfigObject.Name
		end
		TextLabel.TextColor3 = Color3.fromHex(ConfigObject.Color)
	end
	Sword:SetAttribute(StatName,ConfigObject.Identifier or ConfigObject.Name)
	MainGUI.PlayersName.Text = self.Player.Name
end

function MachineClass:UpgradeSword(Sword,MachineObject) -- This is terrible VVVVV
	if not MachineObject.ConfigValue then return end;
	if MachineObject.UsesAlternativeFunction then
		if typeof(MachineObject.ConfigValue) == "table" then
			for _,Stat in pairs(MachineObject.ConfigValue) do
				local Worth = MachineObject.AlternativeFunction(self)
				local ProtoTypeTable = {Name = Worth, Color = "afafaf"}
				self:UpdateSwordSurfanceGui(Sword,ProtoTypeTable,Stat)
			end
		else
			local Worth = MachineObject.AlternativeFunction(self)
			local ProtoTypeTable = {Name = Worth, Color = "afafaf"}
			self:UpdateSwordSurfanceGui(Sword,ProtoTypeTable,MachineObject.ConfigValue)
		end
		return;
	end
	local Luck = self:CalculateMachineLuck(MachineObject.Name)
	local Stats = SwordStats[MachineObject.ConfigValue]
	if Luck and Stats then
		for _, Stat in ipairs(Stats) do
			if Luck <= 1/Stat.Chance then
				local SwordGui = Sword.Main.Gui
				self:UpdateSwordSurfanceGui(Sword,Stat,MachineObject.ConfigValue)
				if MachineObject.ConfigValue == "Rarity" then
					local NewLevel = math.min(10*Stat.Identifier,Sword:GetAttribute("Level"))
					local ProtoTypeTable = {Name = NewLevel, Color = "afafaf"}
					self:UpdateSwordSurfanceGui(Sword,ProtoTypeTable,"Level")
				end
				break;
			end
		end
	end
	self:UpdateSwordWorth(Sword,Sword:GetAttributes())
end

function MachineClass:CalculateMachineLuck(MachineName)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(self.Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineInformation_1 = Data.FactoryInfo.MachineInformation_1[MachineName]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local PlayerLevel = Data.PlayerData.Level
			local ExtraLuckGamepass = if PlayersProfile.PlayersGamepasses["More Luck"] then 5 else 1
			local ExtraLuckBoost = if BoostService:FindBoostWithType(self.Player,"LuckBoost") then  3 else 1
			local MachinePrestige = MachineInformation_1.Prestige
			return Random:NextNumber()/(1+(0.1*PlayerLevel))/(1+(0.5*MachineLevel))/MachineMultiplier/(0.75+(0.25*MachinePrestige))/ExtraLuckGamepass/ExtraLuckBoost/MachineClass.GlobalLuck
		end
	end
end


function MachineClass:CalculateSwordLevel()
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(self.Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineInformation_1 = Data.FactoryInfo.MachineInformation_1["Upgrader"]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local PlayerLevel = Data.PlayerData.Level
			local MachinePrestige = MachineInformation_1.Prestige					
			return  math.floor(PlayerLevel*math.max(1,1+math.log10(((0.75+(0.25*MachinePrestige))*MachineMultiplier*math.random())^0.1)))
		end
	end
end


function MachineClass:CalculateEnchantLevel(Player)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(self.Player or Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data
		local MachineInformation_1 = Data.FactoryInfo.MachineInformation_1["Enchanter"]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local PlayerLevel = Data.PlayerData.Level
			local MachinePrestige = MachineInformation_1.Prestige
			local CalculatedLuck = math.random()/(1.01^MachineLevel)/MachineMultiplier/(0.75+(0.25*MachinePrestige))
			return 1+math.floor(math.log(1/CalculatedLuck))
		end
	end
end

function MachineClass:CalculateTimeRequired(MachineName)
	local PlayersProfile = DataStoreService.ReturnPlayersProfile(self.Player)
	if PlayersProfile then
		local Data = PlayersProfile.Profile.Data.FactoryInfo.MachineInformation_1
		local MachineInformation_1 = Data[MachineName]
		if MachineInformation_1 then
			local MachineMultiplier = MachineInformation_1.Multiplier
			local MachineLevel = MachineInformation_1.Level
			local FasterMachineGamepass = if PlayersProfile.PlayersGamepasses["Faster Machine"] then 2 else 1
			return math.max(math.floor((50*(1+MachineMultiplier/5))-((0.5*MachineLevel)*(1+MachineMultiplier/100)))/10,1)/FasterMachineGamepass
		end
	end
end


function MachineClass:SellSword(Sword)
	local SwordObject = SwordService.NewSword(self.Player,Sword:GetAttributes())
	SwordService.SendSwordToSellingUI(self.Player,SwordObject:GetAttribute("SwordID"))
	local PlayersProfile = DataStoreService.ReturnPlayersData(self.Player)
	if PlayersProfile then
		local AutoBanking = PlayersProfile.PlayerData.Settings.AutoBank
		if AutoBanking then
			local AutoBankingMode = PlayersProfile.PlayerData.Settings.AutoBankMode
			local AutoBankLimit =  PlayersProfile.PlayerData.Settings.AutoBankLimit
			local SwordInformation = SwordService.GetSwordInfo(SwordObject:GetAttribute("SwordID"))
			local RelatedStat = SwordInformation.Config[AutoBankingMode]
			if RelatedStat then
				local StatInformation = SwordStats.FindObjectFromIdentifier(SwordStats[AutoBankingMode],RelatedStat)
				if 1/StatInformation.Chance < 1/AutoBankLimit then
					print("Addingn to bank")
					SwordService.BankSword(self.Player,SwordObject:GetAttribute("SwordID"))
				end
			end

		end
	end
	Sword:Destroy()
end

function MachineClass:MoveSword(Sword,MachineIndex) -- This is ugly :/
	local MachineObject = self.Machines[MachineIndex]
	if MachineObject then
		if MachineIndex == 7 then
			self:SellSword(Sword)
			return;
		end
		local Position = MachineObject.Position	
		local MovingTween = TweenService:Create(Sword.Main,TweenInfo.new(0.5,Enum.EasingStyle.Linear),{Position = Position})		

		self.Janitor:Add(MovingTween.Completed:Connect(function() 
			if MachineObject.LinkedObject then
				MachineObject.AnimationFunction(MachineObject.LinkedObject,MachineObject)
			end 
			if self.CleanUp then -- Required because MachineObject.AnimationFunction yeilds and the player could have left in that time
				local NextMachine = self.Machines[MachineIndex + 1]
				if NextMachine.Occupied == true then
					NextMachine.MachineFinished.Event:Wait()
				end
				MachineObject.Occupied = false;
				MachineObject.MachineFinished:Fire()

				self:UpgradeSword(Sword,MachineObject)
				self:MoveSword(Sword,MachineIndex + 1)

				MovingTween:Destroy()
				Janitor:Remove(MachineIndex.. "MoveTween")
			end
		end),"Disconnect",tostring(MachineIndex) .. "MoveTween")

		MachineObject.Occupied = true;
		MovingTween:Play()
	end




end


function MachineClass:CleanUp()
	for _,Machine in pairs(self.Machines) do
		if Machine.MachineFinished then
			Machine.MachineFinished:Destroy()
		end
	end
	self.Janitor:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return MachineClass
