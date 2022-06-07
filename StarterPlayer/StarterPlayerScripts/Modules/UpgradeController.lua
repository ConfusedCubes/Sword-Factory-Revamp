

-- Used for the Selling and Buying UI and Trading UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local UpgradeController = {}

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local MainUIController = require(script.Parent.MainUIController)
local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local Players = game:GetService('Players')
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local UpgradeMachineEvent = ReplicatedStorage.RemoteEvents.UpgradeMachine
local GameGUI = LocalPlayer.PlayerGui:WaitForChild("GameUI")

local CurrentlySelectedMachine = nil;
local SelectedButton = nil
local ChangeMachineMultiEvent = ReplicatedStorage.RemoteEvents.ChangeMachineMulti


function UpgradeController.GenerateUpgradeWorth(MachineObject,Replica)
	local BulkUpgrade = Replica.Data.PlayerData.Settings.CurrrentBulkUpgrade
	local X = 2.5+math.max((0.0005+(0.0004*MachineObject.Level/100))*((MachineObject.Level)),0)
	local FinalAmmount = math.round( 9+(10*((X-2.5)*20) + MachineObject.Level^X))
	return BulkUpgrade * FinalAmmount

	
end


function UpgradeController.UpdateStat(Frame,MachineInformation_1,Replica)
	Frame.Level.Text = "Current Level: " .. MachineInformation_1.Level	
	Frame.ImageButton.TextLabel.Text = "Upgrade $" .. Short(UpgradeController.GenerateUpgradeWorth(MachineInformation_1,Replica),2)
end


function UpgradeController:UpdateAllMachines(Replica)
	for _,MachineFrame in pairs(GameGUI.Upgrades.ImageLabel.ScrollingFrame:GetChildren()) do
		local LinkedStat = MachineFrame:GetAttribute("LinkedStat")
		if LinkedStat then
			local MachineInformation_1 = Replica.Data.FactoryInfo.MachineInformation_1[LinkedStat]
			UpgradeController.UpdateStat(MachineFrame,MachineInformation_1,Replica)
		end
	end
end

function UpgradeController.MachineChanged(MachineType,Value,Replica)
	for _,MachineFrame in pairs(GameGUI.Upgrades.ImageLabel.ScrollingFrame:GetChildren()) do
		local LinkedStat = MachineFrame:GetAttribute("LinkedStat")
		if LinkedStat then
			if LinkedStat == MachineType then
				UpgradeController.UpdateStat(MachineFrame,Value,Replica)
			end
		end
	end
end

function UpgradeController.UpgradeMachine(Frame)
	local LinkedStat = Frame:GetAttribute("LinkedStat")
	if LinkedStat then
		UpgradeMachineEvent:FireServer(LinkedStat)
	end
end


function UpgradeController.UpdateMultiplier(Replica)
	local MuiltiplierFrames = GameGUI.Upgrades.Multipliers.ScrollingFrame:GetChildren()
	if CurrentlySelectedMachine then
		local MachinesLevel = Replica.Data.FactoryInfo.MachineInformation_1[CurrentlySelectedMachine].Level
		local Information = ReplicatedStorage.RemoteFunction.GetCurrentMachineMulti:InvokeServer(CurrentlySelectedMachine)
		if Information then
			for _,MultiplierFrame in pairs(MuiltiplierFrames) do
				if MultiplierFrame:IsA("ImageButton") then
					local RequiredLevel = MultiplierFrame:GetAttribute("RequiredLevel")
					local LinkedMulti = MultiplierFrame:GetAttribute("LinkedMultiplier")
					if LinkedMulti and RequiredLevel then
						if MachinesLevel < RequiredLevel then
							MultiplierFrame.ImageColor3 = Color3.fromRGB(49, 49, 49)
							MultiplierFrame:SetAttribute("Locked",true)
							MultiplierFrame.Title.Text = "Level " .. RequiredLevel .. " Required"
						else
							MultiplierFrame:SetAttribute("Locked",false)
							MultiplierFrame.Title.Text = LinkedMulti .. "X"
							if LinkedMulti == Information.Multiplier then
								MultiplierFrame.ImageColor3 = Color3.fromRGB(188, 188, 188) 
							else
								MultiplierFrame.ImageColor3 = Color3.fromRGB(255, 255, 255) 
							end
						end
					end
				end
			end
			
		end
	end
end

function UpgradeController.InitalizeFrames(Replica)
	local MuiltiplierFrame = GameGUI.Upgrades.Multipliers
	for _,MachineFrame in pairs(GameGUI.Upgrades.ImageLabel.ScrollingFrame:GetChildren()) do
		local LinkedStat = MachineFrame:GetAttribute("LinkedStat")
		if LinkedStat then
			local MachineData = Replica.Data.FactoryInfo.MachineInformation_1[LinkedStat]
			UpgradeController.UpdateStat(MachineFrame,MachineData,Replica)
			MachineFrame.ImageButton.MouseButton1Click:Connect(function() -- TODO add in check before sending to server
				UpgradeController.UpgradeMachine(MachineFrame)
			end)
			MachineFrame.OpenMultiplier.MouseButton1Click:Connect(function()
					if SelectedButton then
						SelectedButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
					end

					if LinkedStat == CurrentlySelectedMachine then
						MuiltiplierFrame.Visible = not MuiltiplierFrame.Visible;
					else
						MuiltiplierFrame.Visible = true;
					end
					if MuiltiplierFrame.Visible then
						MachineFrame.OpenMultiplier.ImageColor3 = Color3.fromRGB(0, 116, 8)
					end

					CurrentlySelectedMachine = LinkedStat
					SelectedButton = MachineFrame.OpenMultiplier
					UpgradeController.UpdateMultiplier(Replica)
			end)
			MainUIController.PopEffect(	MachineFrame.ImageButton)
			MainUIController.PopEffect(MachineFrame.OpenMultiplier)
		end
	end
end

function UpgradeController.InitalizeMultiplierFrame(Replica)
	local MuiltiplierFrame = GameGUI.Upgrades.Multipliers
	for _,MultiplierAmmount in pairs(MuiltiplierFrame.ScrollingFrame:GetChildren()) do
		if MultiplierAmmount:IsA("ImageButton") then
			MultiplierAmmount.MouseButton1Click:Connect(function()
				local LinkedMultplier = MultiplierAmmount:GetAttribute("LinkedMultiplier")
				if LinkedMultplier  then
					if CurrentlySelectedMachine and not MultiplierAmmount:GetAttribute("Locked") then
						ChangeMachineMultiEvent:FireServer(CurrentlySelectedMachine,LinkedMultplier)
						UpgradeController.UpdateMultiplier(Replica)
					end
				end
			end)
			MainUIController.PopEffect(MultiplierAmmount)
		end
	end
end



function UpgradeController.Init(Replica)
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		Replica:ListenToRaw(function(_,Path,Value)
			if Path[1] == "FactoryInfo" and Path[2] and Path[2] == "MachineInformation_1" then
				UpgradeController.MachineChanged(Path[3],Value,Replica)
			end
		end)
		Replica:ListenToChange({"PlayerData","Settings","CurrrentBulkUpgrade"},function(NewValue)
			UpgradeController:UpdateAllMachines(Replica)
		end)
		Replica:ListenToChange({"PlayerData","Level"},function(NewValue)
			UpgradeController.InitalizeMultiplierFrame(Replica)
		end)
		UpgradeController.InitalizeMultiplierFrame(Replica)
		UpgradeController.InitalizeFrames(Replica)
	end)
end


	


	return UpgradeController
