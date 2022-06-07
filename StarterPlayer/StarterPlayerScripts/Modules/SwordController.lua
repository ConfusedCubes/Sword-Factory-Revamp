-- Used for the Selling and Buying UI and Trading UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")


local SwordController = {}

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)
local MainUIController = require(script.Parent.MainUIController)

local Players = game:GetService('Players')
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local SellSwordEvent = ReplicatedStorage.RemoteEvents.SellSword
local GameGUI = LocalPlayer.PlayerGui:WaitForChild("GameUI")


function SwordController.UpdateSwordUIFrame(Frame: ImageLabel)
	local SellTime = Frame:GetAttribute("SellTime")
	if SellTime then
		local TimeLeft = SellTime - workspace:GetServerTimeNow()
		local TimeLeftNumber = tonumber(TimeLeft)
		if TimeLeftNumber <= 0 then -- Countdown has ran out
			SwordController.SellSword(Frame)
		else
			Frame.CountDown.Text = string.format("%02d:%02d", TimeLeft/60%60, TimeLeft%60)
		end
	end
end

function SwordController.CountDown()
	RunService.Heartbeat:Connect(function()
		local SellingUI = GameGUI.Sell.ImageLabel.ScrollingFrame
		for _,SwordUI in pairs(SellingUI:GetChildren())	do
			if SwordUI:IsA("ImageLabel") then
				SwordController.UpdateSwordUIFrame(SwordUI)
			end
		end
	end)	
end

function SwordController.SellSword(Frame)-- If the client wants to sell the sword early
	local ID = Frame:GetAttribute("ID")
	if ID then	
		SellSwordEvent:FireServer(ID)
	end
	Frame:Destroy()
end

function SwordController.BankSword(Frame)
	local SwordID = Frame:GetAttribute("ID")
	if SwordID then
		ReplicatedStorage.RemoteEvents.BankSword:FireServer(SwordID)
	end
	Frame:Destroy()
end

function SwordController:AddSwordToSellingUI(Sword)
	local SellingUI = GameGUI.Sell.ImageLabel.ScrollingFrame
	local Template = script.Template:Clone()
	local MoldInfo = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,Sword.Config.Mold)
	if MoldInfo then
		local ImageID = MoldInfo.ImageID
		if ImageID then
			Template.ImageLabel.Image = ImageID
		end
	end
	Template:SetAttribute("SellTime",Sword.SellTime)
	Template:SetAttribute("ID",Sword.ID)
	Template.Parent = SellingUI
	Template.ImageButton.MouseButton1Click:Connect(function()
		SwordController.BankSword(Template)
	end)
	Template.MouseEnter:Connect(function()
		local StatsFrame = GameGUI.Sell.ImageLabel.Stats
		MainUIController.PopulateStatsFrame(StatsFrame,Sword.Config)
		MainUIController.Hover(Template,StatsFrame)
	end)
end

function SwordController.Init(Replica)
	ReplicaController.ReplicaOfClassCreated("PlayerSwords", function(Replica)
		Replica:ListenToArrayInsert({"SellSwords"},function(new_index,new_value)
			SwordController:AddSwordToSellingUI(new_value)
		end)
		Replica:ListenToArrayRemove({"SellSwords"},function(new_index,new_value)
			for i,v in pairs(GameGUI.Sell.ImageLabel.ScrollingFrame:GetChildren()) do
				if v:GetAttribute("ID") == new_value.ID then
					v:Destroy()
				end
			end
		end)
		SwordController.CountDown()
	end)
end



return SwordController
