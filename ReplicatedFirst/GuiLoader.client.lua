-- Loads the GUI 

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players")

local PlayerGui = Player.LocalPlayer.PlayerGui
local UIFolder = ReplicatedStorage.UI

for _,ScreenUI in pairs(UIFolder:GetChildren()) do
	ScreenUI:Clone().Parent = PlayerGui
end

