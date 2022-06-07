local AscenderController = {}

local Players = game:GetService('Players')
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local MainUIController = require(script.Parent.MainUIController)
local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)

local LocalPlayer = Players.LocalPlayer
local GameGUI = LocalPlayer.PlayerGui:WaitForChild("GameUI")
local AscenderGUI = GameGUI.Ascender

local CurrentSelectedStat = nil;


function AscenderController:UpdateSwordSlot(SwordID,new)
	for _,SwordFrame in pairs(AscenderGUI.Inventory.FrameHolder.ScrollingFrame:GetChildren()) do
		local ID = SwordFrame:GetAttribute("ID") 
		if ID then
			local IsAscenderSword = SwordID == ID
			SwordFrame.EquipButton.TextLabel.Text = IsAscenderSword and "Unselect" or "Select"
			SwordFrame.EquipButton.TextLabel.TextColor3 = IsAscenderSword and Color3.fromRGB(132, 17, 23) or Color3.fromRGB(48, 147, 54)
			SwordFrame.EquipButton.Image = IsAscenderSword and "rbxassetid://9336286078" or "rbxassetid://9336279940"
		end
	end
end

function AscenderController:UpdateUpgradeSelectionSlot(SelectedStat)
	for _,SwordFrame in pairs(AscenderGUI.Upgrades.Outline.Body.InnerBody:GetChildren()) do
		local LinkedStat = SwordFrame:GetAttribute("LinkedStat")
		if LinkedStat then
			local IsSelectedStat  = LinkedStat == SelectedStat
			SwordFrame.ImageColor3 = if IsSelectedStat then Color3.fromRGB(197, 197, 197) else Color3.fromRGB(255, 255, 255)
		end
	end

end

function AscenderController:AddSwordToInventory(SwordObject,InAscender)
	warn("Adding", SwordObject.ID)

	local Template = script.Template:Clone()
	Template.MouseEnter:Connect(function()
		local StatsFrame = AscenderGUI.Stats
		MainUIController.PopulateStatsFrame(StatsFrame,SwordObject.Config)
		MainUIController.Hover(Template,StatsFrame)
	end)
	local MoldInfo = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,SwordObject.Config.Mold)
	if MoldInfo then
		local ImageID = MoldInfo.ImageID
		if ImageID then
			Template.ImageLabel.Image = ImageID
		end
	end
	Template.EquipButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.UpdateSelectedAscenderItem:FireServer(SwordObject.ID)
	end)
	Template:SetAttribute("ID",SwordObject.ID)
	Template:SetAttribute("InAscender",InAscender)
	Template.Parent = AscenderGUI.Inventory.FrameHolder.ScrollingFrame
end


function AscenderController:FindSwordSlotFromID(SwordID)
	for Index,SwordSlot in pairs(AscenderGUI.Inventory.FrameHolder.ScrollingFrame:GetChildren()) do
		local SwordID = SwordSlot:GetAttribute("ID")
		if SwordID and SwordID == SwordID then
			return SwordSlot
		end
	end
end

function AscenderController:RemoveSwordFromInventory(SwordObject)
	for Index,SwordSlot in pairs(AscenderGUI.Inventory.FrameHolder.ScrollingFrame:GetChildren()) do
		local SwordID = SwordSlot:GetAttribute("ID")
		if SwordID and SwordID == SwordObject.ID then
			warn("Deleting", SwordObject.ID)
			SwordSlot:Destroy()
		end
	end
end

function AscenderController:PopulateInventory(Replica)
	for _,SwordTemplate in pairs(Replica.Data.PlayerData.SwordsInBank_1) do
		AscenderController:AddSwordToInventory(SwordTemplate)
	end
	local SwordInAscenderID = Replica.Data.FactoryInfo.SwordInAscender
	if SwordInAscenderID then
		local SwordSlot = AscenderController:FindSwordSlotFromID(SwordInAscenderID)
		if SwordSlot then
			AscenderController:UpdateSwordSlot(SwordSlot,true)
		end
	end
end

function AscenderController:SetupUpgradeFrame()
	for _, Frame in pairs(GameGUI.Ascender.Upgrades.Outline.Body.InnerBody:GetChildren()) do
		if Frame:IsA("ImageButton") then
			local LinkedStat = Frame:GetAttribute("LinkedStat")
			if LinkedStat then
				Frame.MouseButton1Click:Connect(function()
					CurrentSelectedStat = LinkedStat; 
				end)
			end
		end
	end
end


function AscenderController:SetupUIPopUp()
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	local BankOpenPrompt: ProximityPrompt = PlayersBase:WaitForChild("Structures"):WaitForChild("Ascender"):WaitForChild("Stand"):WaitForChild("ProximityPrompt")-- Required because of cloning replication :(
	BankOpenPrompt.PromptShown:Connect(function()
		MainUIController.Arrange(AscenderGUI,true)
	end)
	BankOpenPrompt.PromptHidden:Connect(function()
		AscenderGUI.Visible = false;
	end)
	BankOpenPrompt.Triggered:Connect(function()
		if AscenderGUI.Visible == false then
			MainUIController.Arrange(AscenderGUI,true)
		else
			AscenderGUI.Visible = false;
		end
	end)
end

function AscenderController:SetupUpgradeSelector()
	for Index,Button: GuiButton in pairs(AscenderGUI.Upgrades.Outline.Body.InnerBody:GetChildren()) do
		local LinkedStat = Button:GetAttribute("LinkedStat")
		if LinkedStat then
			MainUIController.PopEffect(Button)
			Button.MouseButton1Click:Connect(function()
				ReplicatedStorage.RemoteEvents.UpdateSelectedAscenderItem:FireServer(LinkedStat)
			end) 
		end
	end
end

function AscenderController.Init(Replica)
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		local CurrentSwordInAscender = Replica.Data.FactoryInfo.SwordInAscender
		Replica:ListenToArrayInsert({"PlayerData","SwordsInBank_1"},function(new_index,new_value)
			AscenderController:AddSwordToInventory(new_value)
		end)
		ReplicatedStorage.RemoteEvents.SwordChanged.OnClientEvent:Connect(function(SwordObject)
			if not SwordObject.ID then
				SwordObject.ID = SwordObject._ID
			end
			AscenderController:RemoveSwordFromInventory(SwordObject)
			AscenderController:AddSwordToInventory(SwordObject)
			AscenderController:UpdateSwordSlot(CurrentSwordInAscender)
		end)
	
		Replica:ListenToArrayRemove({"PlayerData","SwordsInBank_1"},function(new_index,new_value)
			AscenderController:RemoveSwordFromInventory(new_value)
		end)
		Replica:ListenToChange({"FactoryInfo","SwordInAscender"},function(NewSwordObject,OldSwordObject)
			if NewSwordObject then
				AscenderController:UpdateSwordSlot(NewSwordObject)
			else
				AscenderController:UpdateSwordSlot("")
			end
			CurrentSwordInAscender = NewSwordObject
		end)
		Replica:ListenToChange({"FactoryInfo","AscenderMode"},function(NewSwordObject,OldSwordObject)
			AscenderController:UpdateUpgradeSelectionSlot(NewSwordObject)
		end)
		AscenderController:SetupUpgradeSelector()
		AscenderController:PopulateInventory(Replica)
		AscenderController:SetupUpgradeFrame()
		AscenderController:SetupUIPopUp()
		local CurrentAsenderMode = Replica.Data.FactoryInfo.AscenderMode
		if CurrentSwordInAscender then
			AscenderController:UpdateSwordSlot(CurrentSwordInAscender)
		end
		if CurrentAsenderMode then
			AscenderController:UpdateUpgradeSelectionSlot(CurrentAsenderMode)
		end
	end)
end

return AscenderController
