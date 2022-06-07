local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local SharedModules = ReplicatedStorage.Modules.SharedModules

local Janitor = require(SharedModules.Janitor)

local BoostController = {}  -- THis module is badly written tbh
local GameGUI = Players.LocalPlayer.PlayerGui:WaitForChild("GameUI")
local BoostHolder = GameGUI.HUD.CURRENCY.BoostHolder
BoostController.Janitor = nil;

BoostController.BoostImages = {
	["CashBoost"]  = "http://www.roblox.com/asset/?id=9485042781";
	["XPBoost"] = "rbxassetid://9643182239";
	["LuckBoost"] = "rbxassetid://9643183191";
	["HealthBoost"] = "rbxassetid://9643182687"
}

--[[
]]

function BoostController:GenerateUIAndCountdown(BoostInformation,Janitor)
	local Template = script.Template:Clone()
	Template.Image = BoostController.BoostImages[BoostInformation.Type]
	Template.Parent = BoostHolder
	Janitor:Add(Template,"Destroy",BoostInformation.Type .. "Frame")
	Janitor:Add(RunService.Heartbeat:Connect(function()
		local CurrentTime = workspace:GetServerTimeNow()
		local TimeLeft = BoostInformation.EndingTime - CurrentTime
		if TimeLeft < 0 then
			Janitor:Remove(BoostInformation.Type .. "Event")
			Janitor:Remove(BoostInformation.Type .. "Frame")
		else
			Template.Timer.Text = string.format("%02d:%02d:%02d", TimeLeft/3600, TimeLeft/60%60, TimeLeft%60)
		end		
	end),"Disconnect",BoostInformation.Type .. "Event")
end

function BoostController.RedrawBoosts(AllBoosts) -- Just redraw all boosts I am too lazy to make it only adjust the changed boost
	if BoostController.Janitor then
		BoostController.Janitor:Destroy()
	end
	local Janitor = Janitor.new()
	BoostController.Janitor = Janitor
	for _,Boost in pairs(AllBoosts) do
		print(Boost)
		BoostController:GenerateUIAndCountdown(Boost,Janitor)
	end
end

function BoostController.Init()
	ReplicatedStorage.RemoteEvents.BoostEvents.RedrawBoosts.OnClientEvent:Connect(BoostController.RedrawBoosts)
end


return BoostController
