	local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local MainUIController = require(script.Parent.MainUIController)
local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)


local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GameGui = PlayerGui:WaitForChild("GameUI")
local TradeGui = GameGui.Trade

local TradeController = {}
TradeController.CountdownEvent = nil;

function TradeController:SendTradeRequest(Recipent)
	local Success,ErrorMessage = ReplicatedStorage.RemoteFunction.TradingFunctions.SendTradeRequest:InvokeServer(Recipent)
	if Success then
		game.SoundService:FindFirstChild("SucessSound"):Play()
		MainUIController.Notify("✅ " .. ErrorMessage)
	else
		game.SoundService:FindFirstChild("ErrorSound"):Play() -- Move these two a module thing
		MainUIController.Notify("❌ " .. ErrorMessage)
	end
end

function TradeController:CreateTemplateAtParent(SwordConfig,Parent)
	local Template = script.Template:Clone()
	local MoldInfo = SwordStats.FindObjectFromIdentifier(SwordStats.Mold,SwordConfig.Config.Mold)
	if MoldInfo then
		local ImageID = MoldInfo.ImageID
		if ImageID then
			Template.SwordIcon.Image = ImageID
		end
	end
	Template.MouseEnter:Connect(function()
		local StatsFrame = TradeGui.Stats
		MainUIController.PopulateStatsFrame(StatsFrame,SwordConfig.Config)
		MainUIController.Hover(Template,StatsFrame)
	end)
	Template:SetAttribute("ID",SwordConfig.ID)
	if Parent then
		Template.Parent = Parent
	end
	return Template
end

function TradeController:AddItemToOffer(SwordID)
	ReplicatedStorage.RemoteEvents.TradingEvents.AddItemToTrade:FireServer(SwordID)
end

function TradeController:AddItemToInventory(SwordConfig)
	local Template = self:CreateTemplateAtParent(SwordConfig,TradeGui.Inventory.FrameHolder.ScrollingFrame)
	Template.SwordIcon.MouseButton1Click:Connect(function()
		TradeController:AddItemToOffer(SwordConfig.ID)
	end)
end


function TradeController:RemoveItemFromInventory(ID)
	for Index,Template in pairs(TradeGui.Inventory.FrameHolder.ScrollingFrame:GetChildren()) do
		if Template:GetAttribute("ID") == ID then
			Template:Destroy()
			break;
		end
	end
end


function TradeController:PopulatePlayerList()
	local TradeablePlayers = ReplicatedStorage.RemoteFunction.TradingFunctions.GetTradeablePlayers:InvokeServer()
	for _,Button in pairs(GameGui.PlayerList.Outline.Body.InnerBody:GetChildren()) do
		if Button:IsA("TextButton") then
			Button:Destroy()
		end
	end
	for _,Player in pairs(TradeablePlayers) do
		local Template = script.PlayerListTemplate:Clone()
		Template.TextLabel.Text = Player.Name
		MainUIController.PopEffect(Template)
		Template.MouseButton1Click:Connect(function()
			TradeController:SendTradeRequest(Player)
		end)
		Template.Parent = GameGui.PlayerList.Outline.Body.InnerBody
	end
end

function TradeController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		for _,SwordConfig in pairs(Replica.Data.PlayerData.SwordsInBank_1) do
			TradeController:AddItemToInventory(SwordConfig)
		end
		Replica:ListenToArrayInsert({"PlayerData","SwordsInBank_1"},function(SwordIndex,NewSwordValue)
			TradeController:AddItemToInventory(NewSwordValue)
		end)

		Replica:ListenToArrayRemove({"PlayerData","SwordsInBank_1"},function(SwordIndex,NewSwordValue)
			TradeController:RemoveItemFromInventory(NewSwordValue.ID)
		end)

		MainUIController.PopEffect(TradeGui.Background.GreyscaleFrame.PlayerBox.ReadyButton)
		TradeGui.Background.GreyscaleFrame.PlayerBox.ReadyButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.TradingEvents.LockTrade:FireServer()
		end)
		TradeGui.Background.GreyscaleFrame.PlayerBox.UnreadyButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.TradingEvents.UnlockTrade:FireServer()
		end)
		TradeGui.Background.GreyscaleFrame.PlayerBox.CancelButton.MouseButton1Click:Connect(function()
			ReplicatedStorage.RemoteEvents.TradingEvents.CancelTrade:FireServer()

		end)
	end)
	GameGui.HUD["HUD BUTTONS"].Trade.ImageButton.MouseButton1Click:Connect(function()
		if GameGui.PlayerList.Visible == false then
			TradeController:PopulatePlayerList()
		end		
		MainUIController.Arrange(GameGui.PlayerList)
	end)
end



function TradeController:RemoveItemFromTrade(SwordObject)
	ReplicatedStorage.RemoteEvents.TradingEvents.RemoveItemFromTrade:FireServer(SwordObject.ID)
end

function TradeController:StartCountDown(EndingTime)
	local CountDown = TradeGui.Background.GreyscaleFrame.Countdown -- /TODO FIX THIS
	CountDown.Visible = true;
	self.CountdownEvent = RunService.Heartbeat:Connect(function()
		local TimeLeft =  EndingTime - workspace:GetServerTimeNow()
		CountDown.Text = string.format("%02d", TimeLeft%60) -- Kinda hacky I don't know if theres a better way to do [0]0.00
	end)
end

function TradeController:StopCountDown()
	local CountDown = TradeGui.Background.GreyscaleFrame.Countdown -- /TODO FIX THIS
	CountDown.Visible = false;
	if self.CountdownEvent then
		self.CountdownEvent:Disconnect()
	end
end

function TradeController:RemoveItemFromOfferFrame(Index,IsPlayer)
	local ItemFrame = if IsPlayer then TradeGui.Background.GreyscaleFrame.PlayerBox.ItemsFrame else TradeGui.Background.GreyscaleFrame.OtherPlayerBox.ItemsFrame	
	local SlotFrame = ItemFrame:FindFirstChild("Slot" .. Index)
	if SlotFrame then
		SlotFrame.SwordIcon.Image = "";
		if IsPlayer then
			SlotFrame.CloseButton.Visible = false;
		end
	end
end

function TradeController:AddItemToOfferFrame(Index,SwordObject,IsPlayer)
	local ItemFrame = if IsPlayer then TradeGui.Background.GreyscaleFrame.PlayerBox.ItemsFrame else TradeGui.Background.GreyscaleFrame.OtherPlayerBox.ItemsFrame	
	local SlotFrame = ItemFrame:FindFirstChild("Slot" .. Index)
	if SlotFrame then
		local SwordImage = MainUIController:GetSwordsIcon(SwordObject)
		if SwordImage then
			SlotFrame.SwordIcon.Image = SwordImage
		end
		SlotFrame.MouseEnter:Connect(function()
			local StatsFrame = TradeGui.Stats
			MainUIController.PopulateStatsFrame(StatsFrame,SwordObject.Config)
			MainUIController.Hover(SlotFrame,StatsFrame)
		end)
		if IsPlayer then
			SlotFrame.CloseButton.Visible = true;
			local Event; Event = SlotFrame.CloseButton.MouseButton1Click:Connect(function()
				self:RemoveItemFromTrade(SwordObject)
			end)			
		end
	end
end

function TradeController.IncomingTradeRequest(Sender,TradingID) -- Pending Trade requests
	local TradingRequest = GameGui["Trading Request"]
	TradingRequest.Outline.Body.InnerBody.TextLabel.Text = Sender.Name .." Has sent you a trade request. Do you accept?"
	TradingRequest.Visible = true;
	local TradingRequestBody = TradingRequest.Outline.Body.InnerBody 
	local Disconnect; Disconnect = TradingRequestBody.Accept.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.TradingEvents.AcceptedTradingRequest:FireServer(TradingID)
		TradingRequest.Visible = false;
		Disconnect:Disconnect()
	end)
	local Disconnect; Disconnect = TradingRequestBody.Decline.MouseButton1Click:Connect(function()
		ReplicatedStorage.RemoteEvents.TradingEvents.DeclinedTradingRequest:FireServer(TradingID)
		TradingRequest.Visible = false;
		Disconnect:Disconnect()
	end)
end

function TradeController:LockedTrade(IsPlayer)
	if IsPlayer then
		local PlayersBox = TradeGui.Background.GreyscaleFrame.PlayerBox
		PlayersBox.ReadyButton.Visible = false;
		PlayersBox.CancelButton.Visible = true;
		PlayersBox.UnreadyButton.Visible = true
	else
		local OtherPlayerBox = TradeGui.Background.GreyscaleFrame.OtherPlayerBox
		OtherPlayerBox.Notice.Text = "Ready!"
		OtherPlayerBox.Notice.TextColor3 = Color3.fromRGB(115, 235, 116)
		OtherPlayerBox.UIStroke.Color = Color3.fromRGB(115, 235, 116)
	end	
end

function TradeController:UnlockTrade(IsPlayer)
	if IsPlayer then
		local PlayersBox = TradeGui.Background.GreyscaleFrame.PlayerBox
		PlayersBox.ReadyButton.Visible = true;
		PlayersBox.CancelButton.Visible = true;
		PlayersBox.UnreadyButton.Visible = false
	else
		local OtherPlayerBox = TradeGui.Background.GreyscaleFrame.OtherPlayerBox
		OtherPlayerBox.Notice.Text = "Waiting...!"
		OtherPlayerBox.Notice.TextColor3 = Color3.fromRGB(177, 177, 177)
		OtherPlayerBox.UIStroke.Color = Color3.fromRGB(227, 227, 227)
	end	
end

function TradeController:CleanUp()
	local PlayersBox = TradeGui.Background.GreyscaleFrame.PlayerBox
	local OtherPlayerBox = TradeGui.Background.GreyscaleFrame.OtherPlayerBox
	
	for Index,Slot in pairs(PlayersBox.ItemsFrame:GetChildren()) do
		Slot.SwordIcon.Image = ""
		Slot.CloseButton.Visible = false;
	end
	for Index,Slot in pairs(OtherPlayerBox.ItemsFrame:GetChildren()) do
		Slot.SwordIcon.Image = ""
	end
	PlayersBox.ReadyButton.Visible = true;
	PlayersBox.CancelButton.Visible = false;
	PlayersBox.UnreadyButton.Visible = false;
	TradeGui.Background.GreyscaleFrame.Countdown.Visible = false
	
	OtherPlayerBox.UIStroke.Color = Color3.fromRGB(227, 227, 227)
	OtherPlayerBox.Notice.Text = "Waiting..."
	OtherPlayerBox.Notice.TextColor3 = Color3.fromRGB(177, 177, 177)
	TradeGui:SetAttribute("Locked",false)

	TradeGui.Visible = false;
end

function TradeController.ActiveTradeRequestStarted(ReplicaID,ArrayName,TradeInformation) -- Actual trade requests 
	local Replica = ReplicaController.GetReplicaById(ReplicaID)
	if Replica then
		GameGui.Notification.Visible = false; -- Close out any active notification frame
		MainUIController.Arrange(TradeGui,true) 
		TradeGui:SetAttribute("Locked",true)
		local OtherArrayName = if ArrayName == "SenderItems" then "RecipentItems" else "SenderItems" -- VVV this is stupid
		if OtherArrayName == "SenderItems" then
			TradeGui.Background.GreyscaleFrame.OtherPlayerBox.Username.Text = TradeInformation.Sender.Name
		else
			TradeGui.Background.GreyscaleFrame.OtherPlayerBox.Username.Text = TradeInformation.Recipent.Name
		end
		Replica:ListenToArraySet({ArrayName},function(NewSwordIndex,NewSwordValue) -- This is the players offer
			if NewSwordValue == "NULL" then
				TradeController:RemoveItemFromOfferFrame(NewSwordIndex,true)
			else
				TradeController:AddItemToOfferFrame(NewSwordIndex,NewSwordValue,true)
			end
		end)
		Replica:ListenToChange({ArrayName.."Locked"},function(Locked) -- Player locked trade
			if not Locked then
				TradeController:UnlockTrade(true)
			else
				TradeController:LockedTrade(true)

			end
		end)
		Replica:ListenToArraySet({OtherArrayName},function(NewSwordIndex,NewSwordValue) -- This is the other players offer
			if NewSwordValue == "NULL" then
				TradeController:RemoveItemFromOfferFrame(NewSwordIndex,false)
			else
				TradeController:AddItemToOfferFrame(NewSwordIndex,NewSwordValue,false)
			end
		end)
		Replica:ListenToChange({OtherArrayName.."Locked"},function(Locked) -- Player locked trade
			if not Locked then
				TradeController:UnlockTrade(false)
			else
				TradeController:LockedTrade(false)

			end
		end)
		Replica:ListenToChange({"EndingTime"},function(EndingTime) -- Player locked trade
			if EndingTime == "NULL" then
				TradeController:StopCountDown()
			else
				TradeController:StartCountDown(EndingTime)
			end
		end)
		
		Replica:AddCleanupTask(TradeController.CleanUp)
	end
end

ReplicatedStorage.RemoteEvents.TradingEvents.ActiveTradingRequest.OnClientEvent:Connect(TradeController.ActiveTradeRequestStarted)
ReplicatedStorage.RemoteEvents.TradingEvents.NotifyTradingRequest.OnClientEvent:Connect(TradeController.IncomingTradeRequest)

return TradeController
