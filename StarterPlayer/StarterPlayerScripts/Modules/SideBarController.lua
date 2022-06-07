
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local Player = Players.LocalPlayer
local SideBarController = {}
local PlayerGui = Player.PlayerGui
local GameGui = PlayerGui:WaitForChild("GameUI")
local MainUIController = require(script.Parent.MainUIController)



-- Will handle all of the Sidebar buttons and everything in them.




function SideBarController:SetUpButtonEvents(Replica)
	local Buttons = GameGui.HUD["HUD BUTTONS"]
	for _,Frame in pairs(Buttons:GetChildren()) do
		if Frame:IsA("Frame") then
			local Button = Frame:FindFirstChildOfClass("ImageButton")
			if Button then
				MainUIController.PopEffect(Button)
				local LinkedFrame = Button:GetAttribute("LinkedFrame")
				if LinkedFrame then
					local LinkedFrameInstance = GameGui:FindFirstChild(LinkedFrame)
					if LinkedFrameInstance then
						Button.MouseButton1Click:Connect(function()
							MainUIController.Arrange(LinkedFrameInstance)
						end)
						local CloseButton = LinkedFrameInstance.ImageLabel:FindFirstChild("CloseButton")
						if CloseButton then
							MainUIController.PopEffect(CloseButton)
							CloseButton.MouseButton1Click:Connect(function()
								MainUIController.Arrange(LinkedFrameInstance)
							end)
						end
					end
				end
			end
		end
	end
end


function SideBarController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		SideBarController.SetUpButtonEvents(Replica)
		local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
		GameGui.HUD["HUD BUTTONS"].Teleport.ImageButton.MouseButton1Click:Connect(function()
			local Character = Player.Character
			if Character then
				Character:PivotTo(PlayersBase.Spawn:GetPivot())
			end
		end)
	end)
end


return SideBarController
