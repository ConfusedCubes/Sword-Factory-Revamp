
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local Player = Players.LocalPlayer
local SettingsController = {}
local PlayerGui = Player.PlayerGui
local GameGUI = PlayerGui:WaitForChild("GameUI")
local SettingsGUI = GameGUI.Settings


local MainUiController = require(script.Parent.MainUIController)

SettingsController.NotEnabledButtonImageId = "rbxassetid://9336286078"
SettingsController.NotEnabledButtonColor3 = Color3.fromRGB(132, 17, 23)
SettingsController.EnabledButtonImageId = "rbxassetid://9336279940"
SettingsController.EnabledButtonColor3 = Color3.fromRGB(48, 147, 54)


function SettingsController.SetupSettingButtons()
	for _, Button in pairs(SettingsGUI.ImageLabel.Frame.Frame.UpgradeBulkBuy:GetChildren()) do
		if  Button:IsA("ImageButton") then
			Button.MouseButton1Click:Connect(function()
				local ButtonNumber = Button:GetAttribute("BulkNumber")
				if ButtonNumber then
					ReplicatedStorage.RemoteEvents.SettingsEvent.ChageBulkBuyMode:FireServer(ButtonNumber)
				end
			end)
			MainUiController.PopEffect(Button)
		end
	end
	for _, Button in pairs(SettingsGUI.ImageLabel.Frame.Frame.TradePrivacy:GetChildren()) do
		if  Button:IsA("ImageButton") then
			Button.MouseButton1Click:Connect(function()
				local LinkedSetting = Button:GetAttribute("LinkedSetting")
				if LinkedSetting then
					ReplicatedStorage.RemoteEvents.SettingsEvent.ChangeTradePrivacy:FireServer(LinkedSetting)
				end
			end)
			MainUiController.PopEffect(Button)
		end
	end
	for _, Button in pairs(SettingsGUI.ImageLabel.Frame.Frame.BankingMode:GetChildren()) do
		if  Button:IsA("ImageButton") then
			Button.MouseButton1Click:Connect(function()
				local LinkedSetting = Button:GetAttribute("LinkedSetting")
				if LinkedSetting then
					print("Clicked",LinkedSetting)
					ReplicatedStorage.RemoteEvents.SettingsEvent.ChangeBankingMode:FireServer(LinkedSetting)
				end
			end)
			MainUiController.PopEffect(Button)
		end
	end
	SettingsGUI.ImageLabel.Frame.Frame.BankingLimit.Increase.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SettingsEvent.IncreaseAutoBank:FireServer()

	end)
	SettingsGUI.ImageLabel.Frame.Frame.BankingLimit.Decrease.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SettingsEvent.DecreaseAutoBank:FireServer()

	end)
	local AllowVistorsFrame = SettingsGUI.ImageLabel.Frame.Frame.AllowVistors
	AllowVistorsFrame.ImageButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SettingsEvent.AllowVistors:FireServer()
	end)
	local MuteMusicFrame = SettingsGUI.ImageLabel.Frame.Frame.MuteMusic
	MuteMusicFrame.ImageButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SettingsEvent.MuteMusic:FireServer()
	end)
	local AutoBankFrame = SettingsGUI.ImageLabel.Frame.Frame.AutoBank
	AutoBankFrame.ImageButton.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.SettingsEvent.AutoBank:FireServer()
	end)
	MainUiController.PopEffect(MuteMusicFrame.ImageButton)
	MainUiController.PopEffect(AutoBankFrame.ImageButton)
	MainUiController.PopEffect(AllowVistorsFrame.ImageButton)
	MainUiController.PopEffect(SettingsGUI.ImageLabel.Frame.Frame.BankingLimit.Increase)
	MainUiController.PopEffect(SettingsGUI.ImageLabel.Frame.Frame.BankingLimit.Decrease)

end

function SettingsController.UpgradeBulkSettingChanged(NewValue)
	local UpgradeBulkFrame = SettingsGUI.ImageLabel.Frame.Frame.UpgradeBulkBuy
	for _, Button in pairs(UpgradeBulkFrame:GetChildren()) do
		local BulkNumber = Button:GetAttribute("BulkNumber")
		if BulkNumber then
			Button.Image = BulkNumber == NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
			Button.TextLabel.TextColor3 = BulkNumber == NewValue and SettingsController.EnabledButtonColor3  or SettingsController.NotEnabledButtonColor3
		end
	end	
end

function SettingsController.TradePrivacyChanged(NewValue)
	local TradePrivacyFrame = SettingsGUI.ImageLabel.Frame.Frame.TradePrivacy
	for _, Button in pairs(TradePrivacyFrame:GetChildren()) do
		local LinkedSetting = Button:GetAttribute("LinkedSetting")
		if LinkedSetting then
			Button.Image = LinkedSetting == NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
			Button.TextLabel.TextColor3 = LinkedSetting == NewValue and SettingsController.EnabledButtonColor3  or SettingsController.NotEnabledButtonColor3
		end
	end	
end

function SettingsController.AllowVistorsChanged(NewValue)
	local AllowVistorsFrame = SettingsGUI.ImageLabel.Frame.Frame.AllowVistors
	AllowVistorsFrame.ImageButton.Image = NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
	AllowVistorsFrame.ImageButton.TextLabel.TextColor3 = NewValue and SettingsController.EnabledButtonColor3 or SettingsController.NotEnabledButtonColor3
	AllowVistorsFrame.ImageButton.TextLabel.Text = NewValue and "ON" or "OFF"
end

function SettingsController.MuteMusicChanged(NewValue)
	local MuteMusicFrame = SettingsGUI.ImageLabel.Frame.Frame.MuteMusic
	MuteMusicFrame.ImageButton.Image = NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
	MuteMusicFrame.ImageButton.TextLabel.TextColor3 = NewValue and SettingsController.EnabledButtonColor3 or SettingsController.NotEnabledButtonColor3
	MuteMusicFrame.ImageButton.TextLabel.Text = NewValue and "ON" or "OFF"
end

function SettingsController.AutoBankChanged(NewValue)
	local AutoBankFrame = SettingsGUI.ImageLabel.Frame.Frame.AutoBank
	AutoBankFrame.ImageButton.Image = NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
	AutoBankFrame.ImageButton.TextLabel.TextColor3 = NewValue and SettingsController.EnabledButtonColor3 or SettingsController.NotEnabledButtonColor3
	AutoBankFrame.ImageButton.TextLabel.Text = NewValue and "ON" or "OFF"
end
function SettingsController.AutoBankModeChanged(NewValue)
	local AutoBankFrame = SettingsGUI.ImageLabel.Frame.Frame.BankingMode
	for _, Frame in pairs(AutoBankFrame:GetChildren()) do
		local Attribute = Frame:GetAttribute("LinkedSetting")
		if Attribute then
			Frame.Image = Attribute == NewValue and SettingsController.EnabledButtonImageId or SettingsController.NotEnabledButtonImageId
			Frame.TextLabel.TextColor3 = Attribute == NewValue and SettingsController.EnabledButtonColor3 or SettingsController.NotEnabledButtonColor3
		end
	end
end


function SettingsController.AutoBankLimitChanged(NewValue)
	local AutoBankFrame = SettingsGUI.ImageLabel.Frame.Frame.BankingLimit
	AutoBankFrame.TextLabel.Text = "Banking: 1/" ..  tostring(math.floor(NewValue)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end



function SettingsController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		SettingsController.SetupSettingButtons()
		Replica:ListenToChange({"PlayerData","Settings","CurrrentBulkUpgrade"},SettingsController.UpgradeBulkSettingChanged)
		Replica:ListenToChange({"PlayerData","Settings","TradingPrivacy"},SettingsController.TradePrivacyChanged)
		Replica:ListenToChange({"PlayerData","Settings","AllowVistors"},SettingsController.AllowVistorsChanged)
		Replica:ListenToChange({"PlayerData","Settings","AutoBank"},SettingsController.AutoBankChanged)
		Replica:ListenToChange({"PlayerData","Settings","AutoBankLimit"},SettingsController.AutoBankLimitChanged)
		Replica:ListenToChange({"PlayerData","Settings","AutoBankMode"},SettingsController.AutoBankModeChanged)

		Replica:ListenToChange({"PlayerData","Settings","MuteMusic"},SettingsController.MuteMusicChanged)

		SettingsController.AllowVistorsChanged(Replica.Data.PlayerData.Settings.AllowVistors)
		SettingsController.UpgradeBulkSettingChanged(Replica.Data.PlayerData.Settings.CurrrentBulkUpgrade)
		SettingsController.TradePrivacyChanged(Replica.Data.PlayerData.Settings.TradingPrivacy)
		SettingsController.AutoBankChanged(Replica.Data.PlayerData.Settings.AutoBank)
		SettingsController.AutoBankLimitChanged(Replica.Data.PlayerData.Settings.AutoBankLimit)
		SettingsController.AutoBankModeChanged(Replica.Data.PlayerData.Settings.AutoBankMode)

		SettingsController.MuteMusicChanged(Replica.Data.PlayerData.Settings.MuteMusic)
	end)
end


return SettingsController
 