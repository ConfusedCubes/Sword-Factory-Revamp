-- Used for the Selling and Buying UI and Trading UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local BankController = {}

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local MainUIController = require(script.Parent.MainUIController)
local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)



local Players = game:GetService('Players')
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local EquipSwordEvent = ReplicatedStorage.RemoteEvents.EquipSword
local UnEquipSwordEvent = ReplicatedStorage.RemoteEvents.UnEquipSword

local GameGUI = LocalPlayer.PlayerGui:WaitForChild("GameUI")
local BankGUI = GameGUI.Bank


function BankController.EquipButtonHandler(Frame)
	local SwordID = BankController:GetAttribute("ID")
end


function BankController.UpdateFrame(SwordObject)
	for _,SwordFrame in pairs(GameGUI.Bank.ImageLabel.ScrollingFrame:GetChildren()) do
		local ID = SwordFrame:GetAttribute("ID") 
		if ID then
			if SwordObject.ID == ID then
				SwordFrame.EquipButton.TextLabel.Text = SwordObject.Equipped and "Unequip" or "Equip"
				SwordFrame.EquipButton.TextLabel.TextColor3 = SwordObject.Equipped and Color3.fromRGB(132, 17, 23) or Color3.fromRGB(48, 147, 54)
				SwordFrame.EquipButton.Image = SwordObject.Equipped and "rbxassetid://9336286078" or "rbxassetid://9336279940"
				SwordFrame:SetAttribute("Equipped",SwordObject.Equipped) 
			end
		end
	end
end

function BankController:RemoveFrame(SwordObject)
	for _,SwordFrame in pairs(GameGUI.Bank.ImageLabel.ScrollingFrame:GetChildren()) do
		local ID = SwordFrame:GetAttribute("ID") 
		if ID and ID == SwordObject.ID then
			SwordFrame:Destroy()
			return
		end
	end
end

function BankController.AddSwordToUI(SwordObject)
	local Template = script.Template:Clone()
	Template.EquipButton.MouseButton1Click:Connect(function()
		if Template:GetAttribute("Equipped") == true then
			UnEquipSwordEvent:FireServer(SwordObject.ID)
		else
			EquipSwordEvent:FireServer(SwordObject.ID)
		end
	end)
	local MoldInfo = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,SwordObject.Config.Mold)
	if MoldInfo then
		local ImageID = MoldInfo.ImageID
		if ImageID then
			Template.ImageLabel.Image = ImageID
		end
	end
	Template.SellButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SendSwordToSellingUI:FireServer(SwordObject.ID)
	end)
	Template.Parent = GameGUI.Bank.ImageLabel.ScrollingFrame
	Template.MouseEnter:Connect(function()
		local StatsFrame = GameGUI.Bank.ImageLabel.Stats
		MainUIController.PopulateStatsFrame(StatsFrame,SwordObject.Config)
		MainUIController.Hover(Template,StatsFrame)
	end)
	Template:SetAttribute("Equipped",SwordObject.Equipped) 
	Template:SetAttribute("ID",SwordObject.ID)
end

function TrackShopDistance(PlayersBase)
	local BankOpenPrompt: ProximityPrompt = PlayersBase:WaitForChild("Structures"):WaitForChild("Bank"):WaitForChild("Distance"):WaitForChild("BankOpenPrompt")-- Required because of cloning replication :(
	BankOpenPrompt.PromptShown:Connect(function()
		MainUIController.Arrange(BankGUI,true)
	end)
	BankOpenPrompt.PromptHidden:Connect(function()
		BankGUI.Visible = false;
	end)
	BankOpenPrompt.Triggered:Connect(function()
		if BankGUI.Visible == false then
			MainUIController.Arrange(BankGUI,true)
		else
			BankGUI.Visible = false;
		end
	end)
end



function BankController.Init(Replica)
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		Replica:ListenToArrayInsert({"PlayerData","SwordsInBank_1"},function(new_index,new_value)
			BankController.AddSwordToUI(new_value)
			BankController.UpdateFrame(new_value)
		end)
		for _,BankedSword in pairs(Replica.Data.PlayerData.SwordsInBank_1) do
			BankController.AddSwordToUI(BankedSword)
			BankController.UpdateFrame(BankedSword)
		end
		Replica:ListenToArraySet({"PlayerData","SwordsInBank_1"},function(new_index,new_value)
			BankController:RemoveFrame(new_value)
			BankController.AddSwordToUI(new_value)
			BankController.UpdateFrame(new_value)
		end)
		ReplicatedStorage.RemoteEvents.SwordChanged.OnClientEvent:Connect(function(SwordObject)
			if not SwordObject.ID then
				SwordObject.ID = SwordObject._ID
			end
			BankController:RemoveFrame(SwordObject)
			BankController.AddSwordToUI(SwordObject)
			BankController.UpdateFrame(SwordObject)
		end)

		
		Replica:ListenToArrayRemove({"PlayerData","SwordsInBank_1"},function(new_index,new_value)
			BankController:RemoveFrame(new_value)
		end)
	end)
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	if PlayersBase then
		TrackShopDistance(PlayersBase)
	end
	MainUIController.PopEffect(GameGUI.Bank.ImageLabel.CloseButton)
	GameGUI.Bank.ImageLabel.CloseButton.MouseButton1Click:Connect(function()
		BankGUI.Visible = false;
	end)
end





return BankController
