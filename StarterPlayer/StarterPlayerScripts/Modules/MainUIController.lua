local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
--------------------------------------------





local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)
local Short = require(ReplicatedStorage.Modules.SharedModules.Short)
local MouseEnterHelper  = require(ReplicatedStorage.Modules.SharedModules.MouseEnterHelper)
-----------------------------
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GameGui = PlayerGui:WaitForChild("GameUI")
local CurrentlyOpenFrame = nil;
--------------------------


local MainUIController = {}

function MainUIController.Arrange(Frame,Override)
	warn("Ran")
	print(debug.traceback())
	if CurrentlyOpenFrame and CurrentlyOpenFrame:GetAttribute("Locked") then return end
	
	if CurrentlyOpenFrame and not Override  then
		CurrentlyOpenFrame.Visible = false

		if CurrentlyOpenFrame == Frame then
			CurrentlyOpenFrame = nil;
			return
		end	

		CurrentlyOpenFrame = nil;
	end
	CurrentlyOpenFrame = Frame


	local SavedPosition = Frame.Position;
	Frame.Position += UDim2.new(0,0,.1,0)
	local Tween = TweenService:Create(Frame,TweenInfo.new(.3, Enum.EasingStyle.Exponential),{Position = SavedPosition})
	Tween.Completed:Connect(function()
		Tween:Destroy()
		Frame.Position = SavedPosition
	end)
	workspace.Click:Play()
	Tween:Play()
	Frame.Visible = true;
end

function MainUIController:GetSwordsIcon(SwordConfig)
	local MoldInfo = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,SwordConfig.Config.Mold)
	if MoldInfo then
		return MoldInfo.ImageID
	end
end

function MainUIController.Notify(Text)
	local NotificationFrame = GameGui.Notification
	NotificationFrame.Outline.Body.InnerBody.TextLabel.Text = Text
	MainUIController.Arrange(NotificationFrame)
	MainUIController.PopEffect(NotificationFrame.Outline.CloseButton)
	local Event; Event = NotificationFrame.Outline.CloseButton.MouseButton1Click:Connect(function()
		NotificationFrame.Visible = false;
		Event:Disconnect()
	end)
end

function MainUIController.PopEffect(Button: GuiButton)
	local NormalSize = Button.Size;
	local ButtonUpSize = UDim2.new(Button.Size.X.Scale * 1.05,Button.Size.X.Offset * 1.05, Button.Size.Y.Scale * 1.05, Button.Size.Y.Offset * 1.05)
	local ButtonDownSize = UDim2.new(Button.Size.X.Scale * .95,Button.Size.X.Offset * .95, Button.Size.Y.Scale * .95, Button.Size.Y.Offset * .95)
	local Enter,Leave = MouseEnterHelper.MouseEnterLeaveEvent(Button)
	Enter:Connect(function(x,y)
		local Tween = TweenService:Create(Button,TweenInfo.new(.1),{Size = ButtonUpSize})
		Tween.Completed:Connect(function()
			Tween:Destroy()
		end)
		Tween:Play()
	end)

	Leave:Connect(function(x,y)
		local Tween = TweenService:Create(Button,TweenInfo.new(.1),{Size = NormalSize})
		Tween.Completed:Connect(function()
			Tween:Destroy()
		end)
		Tween:Play()
	end)
	Button.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			local Tween = TweenService:Create(Button,TweenInfo.new(.1),{Size = ButtonDownSize})
			Tween.Completed:Connect(function()
				Tween:Destroy()
			end)
			Tween:Play()
		end
	end)

	Button.InputEnded:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			local Tween = TweenService:Create(Button,TweenInfo.new(.1),{Size = ButtonUpSize})
			Tween.Completed:Connect(function()
				Tween:Destroy()
			end)
			Tween:Play()
		end
	end)
end



function MainUIController.PopulateStatsFrame(Frame,Config)
	for _,StatFrame in pairs(Frame:GetChildren()) do
		if StatFrame:IsA("TextLabel") then
			local LinkedConfig = StatFrame:GetAttribute("LinkedConfig")
			if LinkedConfig then
				local LinkedConfigObject;
				if SwordStats[LinkedConfig] then
					LinkedConfigObject = SwordStats.FindObjectFromIdentifier(SwordStats[LinkedConfig],Config[LinkedConfig])
				else
					LinkedConfigObject = {Name = Config[LinkedConfig],Color = "#b6b6b6"}
				end
				if LinkedConfigObject then
					StatFrame.Text =  LinkedConfig .. ": " .. LinkedConfigObject.Name
					StatFrame.TextColor3 = Color3.fromHex(LinkedConfigObject.Color)
				end
			end
		end
	end
end


function MainUIController.Hover(Template,StatFrame)	
	local CleanupEvent = Instance.new("BindableEvent")
	StatFrame.Visible = true
	
	local Enter,Exit = MouseEnterHelper.MouseEnterLeaveEvent(Template)
	
	Enter:Connect(function()
		StatFrame.Visible = true
	end)
	
	local Event1; Event1 = Template.MouseMoved:Connect(function(X,Y)
		StatFrame.Position = UDim2.new(0.15,X - StatFrame.Parent.AbsolutePosition.X,0.2925,Y - StatFrame.Parent.AbsolutePosition.Y -36)
	end)
	Exit:Connect(function()
		StatFrame.Visible = false;
	end)

	local Event3; Event3 = Template.Destroying:Connect(function() -- Stupid way of doing this VVVV
		CleanupEvent:Fire()
	end)
	CleanupEvent.Event:Connect(function()
		Event1:Disconnect()
		Event3:Disconnect()
		CleanupEvent:Destroy()
		StatFrame.Visible = false
	end)	
end


function MainUIController.SetUpSideBarButtons(Replica)
	local PlayerGui = Player:WaitForChild("PlayerGui")
	local GameGui = PlayerGui:WaitForChild("GameUI")
end

function MainUIController.UpdateStringWithPattern(TextLabel,Pattern,...)
	TextLabel.Text = string.format(Pattern, ...)
end

function MainUIController.UpdateLevelBar(Replica)
	local MAXLEVELBARSIZE = 0.821;
	local Levelbar = GameGui.HUD.LevelBar
	local LevelTextLabel = Levelbar.Level
	local ProgressionBar = Levelbar.ProgressionBar

	local CurrentLevel = Replica.Data.PlayerData.Level
	local CurrentXP = Replica.Data.PlayerData.XP
	local XpRequiredToLevelUp = 10_000*(1.07^(CurrentLevel-1))


	local Percent = math.clamp(CurrentXP/XpRequiredToLevelUp,0,1)
	local Size = Percent * MAXLEVELBARSIZE

	ProgressionBar.Size = UDim2.new(Size,0,0.409,0)	
	ProgressionBar.Position = UDim2.new(0.096,ProgressionBar.AbsoluteSize.X/2,0.639, 0)
	
	MainUIController.UpdateStringWithPattern(LevelTextLabel,"Level %d | %s/%s XP", CurrentLevel,Short(CurrentXP),Short(XpRequiredToLevelUp))
end


function MainUIController.SetUpHUDEvents(Replica)
	local CashTextLabel = GameGui.HUD.CURRENCY.Cash.TextLabel
	local BossCoinTextLabel = GameGui.HUD.CURRENCY.BossCoins.TextLabel
	local HUD = GameGui.HUD
	local CashCurrencyButton = HUD.CURRENCY.Cash.ImageButton
	
	local Levelbar = GameGui.HUD.LevelBar
	local LevelTextLabel = Levelbar.Level
	MainUIController.UpdateStringWithPattern(CashTextLabel,"$%s", Short(Replica.Data.PlayerData.Money,1))
	Replica:ListenToChange({"PlayerData","Money"}, function(NewValue)
			MainUIController.UpdateStringWithPattern(CashTextLabel,"$%s",Short(NewValue,1))
	end)
	MainUIController.UpdateStringWithPattern(BossCoinTextLabel,"%s", Short(Replica.Data.PlayerData.BossCoins))
	Replica:ListenToChange({"PlayerData","BossCoins"}, function(NewValue)
		MainUIController.UpdateStringWithPattern(BossCoinTextLabel,"%s",Short(NewValue))
	end)
	
	MainUIController.UpdateLevelBar(Replica)
	Replica:ListenToChange({"PlayerData","Level"}, function(NewValue)
		MainUIController.UpdateLevelBar(Replica)
	end)
	Replica:ListenToChange({"PlayerData","XP"}, function(NewValue)
		MainUIController.UpdateLevelBar(Replica)
	end)
	
	
	
	MainUIController.PopEffect(CashCurrencyButton)
	CashCurrencyButton.MouseButton1Click:Connect(function()
		local ShopController = require(script.Parent.ShopController)
		local ShopFrame = GameGui.Shop
		local CashTab = ShopFrame.ImageLabel.Tabs.CashTab
		MainUIController.Arrange(ShopFrame)
		ShopController.TabClicked(CashTab)
	end)
end



function MainUIController.TeleportPlayer(Replica,FrameClicked)
	local LinkedIsland = FrameClicked:GetAttribute("LinkedIsland")
	local LevelRequired = FrameClicked:GetAttribute("LevelRequired")
	if LinkedIsland and LevelRequired then
		local LinkedIslandInstance = workspace.Islands:FindFirstChild(LinkedIsland)
		if LinkedIslandInstance then
			if Replica.Data.PlayerData.Level >= LevelRequired then
				local Character = Player.Character
				if Character then
					Character:PivotTo(LinkedIslandInstance.SpawnArea:GetPivot())
				end
			end
		end
	end
end


function MainUIController.FindTeleportOption(Player)
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	local Board = PlayersBase:WaitForChild("Board")
	for _, TeleportOption in pairs(Board.SurfaceGui.PlayerList:GetChildren()) do
		if TeleportOption:IsA("TextButton") then
			local LinkedPlayer = TeleportOption:GetAttribute("LinkedPlayer")
			if LinkedPlayer then
				local LinkedPlayerInstance = Players:FindFirstChild(LinkedPlayer)
				if LinkedPlayerInstance then
					if Player == LinkedPlayerInstance then 
						return true,TeleportOption
					end
				end
			end
		end
	end
end


function MainUIController.IntializeTeleportOption(Player)
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	local Board = PlayersBase:WaitForChild("Board")
	
	local Template = script.TeleportOptionTemplate:Clone()
	Template.Parent = Board.SurfaceGui.PlayerList
	Template.MouseButton1Click:Connect(function()
		local LinkedPlayer = Template:GetAttribute("LinkedPlayer")
		if LinkedPlayer then
			local LinkedPlayerInstance = Players:FindFirstChild(LinkedPlayer)
			if LinkedPlayerInstance then
				ReplicatedStorage.RemoteEvents.TeleportTo:FireServer(Player,LinkedPlayerInstance) -- Should be handled client side but Im lazy
			end
		end
	end)
	Template.Text = "Teleport To: " ..  Player.Name .. "'s Base"
	Template:SetAttribute("LinkedPlayer",Player.Name)
end


function MainUIController.SetUpBoard(Replica)
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	local Board = PlayersBase:WaitForChild("Board")
	local ServerluckBoard = PlayersBase:WaitForChild("Structures"):WaitForChild("ServerBoard")
	for _, TeleportOption in pairs(Board.SurfaceGui.Frame:GetChildren()) do
		if TeleportOption:IsA("TextButton") then
			TeleportOption.MouseButton1Click:Connect(function()
				MainUIController.TeleportPlayer(Replica,TeleportOption)
			end)
		end
	end
	local CurrentListOfTeleportableBases = ReplicatedStorage.RemoteFunction.GetTeleportableBases:InvokeServer()
	for _, Player in pairs(CurrentListOfTeleportableBases) do
		MainUIController.IntializeTeleportOption(Player)
	end
	ReplicatedStorage.RemoteEvents.TeleportBaseChanged.OnClientEvent:Connect(function(Player,Added)
		if Player ~= Players.LocalPlayer then
			if Added then
				local FoundIndex, Frame = MainUIController.FindTeleportOption(Player)
				if not FoundIndex then
					MainUIController.IntializeTeleportOption(Player)
				end
			else
				local FoundIndex, Frame = MainUIController.FindTeleportOption(Player)
				if FoundIndex then
					Frame:Destroy()
				end
			end
		end		
	end)
	Players.PlayerRemoving:Connect(function(PlayerWhoLeft)
		local FoundIndex, Frame = MainUIController.FindTeleportOption(PlayerWhoLeft)
		if FoundIndex then
			Frame:Destroy()
		end
	end)
	ReplicatedStorage.RemoteEvents.ServerluckChanged.OnClientEvent:Connect(function(NewServerLuck)
		ServerluckBoard.Screen.Gui.Information.Serverluck.Text = "Total Server Luck: " .. tostring(NewServerLuck) .. "x"
	end)
	local CurrentServerLuck = ReplicatedStorage.RemoteFunction.GetCurrentServerLuck:InvokeServer()
	ServerluckBoard.Screen.Gui.Information.Serverluck.Text = "Total Server Luck: " .. tostring(CurrentServerLuck) .. "x"
end


function MainUIController.StartTimer(MachineInstance,EndingTime)
	local CounterTextLabel = MachineInstance.Counter.Part.SurfaceGui.TextLabel
	local DisconnectEvent; DisconnectEvent = RunService.Heartbeat:Connect(function()
		local TimeLeft = EndingTime - workspace:GetServerTimeNow() 
		if TimeLeft < 0 then
			DisconnectEvent:Disconnect()
			CounterTextLabel.Text = "00:00.00"
			return
		end
		CounterTextLabel.Text = string.format("%02d:%02d.%02d", TimeLeft/60%60, TimeLeft%60,(TimeLeft%1)* 100) -- Kinda hacky I don't know if theres a better way to do [0]0.00
	end)
end

function MainUIController.SetupMachineTimers()
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	ReplicatedStorage.RemoteEvents.UpdateMachineTimer.OnClientEvent:Connect(function(MachineName,EndingTime)
		local MachineInstance = PlayersBase.Machines:FindFirstChild(MachineName)
		if MachineInstance then
			MainUIController.StartTimer(MachineInstance,EndingTime)
		end
	end)
end


function MainUIController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		MainUIController.SetUpHUDEvents(Replica)
		MainUIController.SetUpBoard(Replica)
	end)
	MainUIController.SetupMachineTimers()
end


return MainUIController
