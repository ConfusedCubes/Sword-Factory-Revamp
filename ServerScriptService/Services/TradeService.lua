local TradeService = {}

local HttpService = game:GetService("HttpService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ServerModules = ServerStorage.Modules.ServerModules
local Services = ServerScriptService.Services

local DataStoreService = require(Services.DataStoreService)
local ReplicaService = require(ServerModules.ReplicaService)
local SwordService = require(Services.SwordService)

TradeService.ClassToken = ReplicaService.NewClassToken("Trading")
TradeService.ActiveTrades = {}
TradeService.PendingTrades = {}
TradeService.PlayersOnCoolDown = {}


function TradeService.NewTrade(Sender,Recipent)
	local RandomID = HttpService:GenerateGUID(false)
	TradeService.ActiveTrades[RandomID] = {
		Sender = Sender;
		Recipent = Recipent;
		Replica = ReplicaService.NewReplica({
			ClassToken = TradeService.ClassToken,
			Data = {SenderItems = table.create(3,"NULL"), RecipentItems = table.create(3,"NULL"),SenderItemsLocked = false, RecipentItemsLocked = false,EndingTime = 0}; -- The reason I am using Null is because of a ReplicaService limitation with nil values
			Replication = {[Sender] = true,[Recipent] = true},
		});
		_CurrentlyCountingDown = false;
		_ExecutingTrade = false;
		_Locked = false; -- Locked trades can't be edited
		_ID = RandomID;
	}
	return TradeService.ActiveTrades[RandomID]
end


function TradeService:_FindFirstEmptyArraySpot(Arrary,Length)
	for Index = 1,Length do
		if Arrary[Index] == "NULL" then
			return Index
		end
	end
end

function TradeService:ValidateSwords(Table,Profile)
	for Index,SwordObject in pairs(Table) do
		if SwordObject ~= "NULL" then
			local Sword = SwordService.GetSwordInfo(SwordObject.ID)
			local SwordInBank = SwordService.FindSwordInArrary(SwordObject.ID,Profile.Profile.Data.PlayerData.SwordsInBank_1)  
			if not Sword or not SwordInBank then -- The sword is in SwordService and is in the players Bank
				return false
			end
		end
	end
	return true;
end

function TradeService:SwapSwords(Sender,SenderItems,RecipentProfile)
	for Index,Sword in pairs(SenderItems) do
		if Sword ~= "NULL" then
			warn("Transfering Sword",Sword,Sender)
			SwordService:RemoveSwordFromDataStore(Sender,Sword.ID)
			RecipentProfile.Replica:ArrayInsert({"PlayerData","SwordsInBank_1"},{ID = Sword.ID, Equipped = false,Config = Sword.Config})	
			SwordService.NewSword(RecipentProfile._Player,Sword.Config,Sword.ID)
		end
	end
end

function TradeService:ExecuteTrade(TradeID)
	local ActiveTrade = self.ActiveTrades[TradeID]
	if ActiveTrade and not ActiveTrade._ExecutingTrade then -- This might not be needed
		ActiveTrade._ExecutingTrade = true
		ActiveTrade._CurrentlyCountingDown = false
		local SenderProfile = DataStoreService.ReturnPlayersProfile(ActiveTrade.Sender)
		local RecipentProfile = DataStoreService.ReturnPlayersProfile(ActiveTrade.Recipent)
		if SenderProfile and RecipentProfile then
			if SenderProfile.Profile:IsActive() and RecipentProfile.Profile:IsActive() then -- Not sure if this is needed
				local SendersItems = ActiveTrade.Replica.Data.SenderItems
				local RecipentItems = ActiveTrade.Replica.Data.RecipentItems
				if self:ValidateSwords(SendersItems,SenderProfile) and self:ValidateSwords(RecipentItems,RecipentProfile)  then
					self:SwapSwords(ActiveTrade.Sender,SendersItems,RecipentProfile)
					self:SwapSwords(ActiveTrade.Recipent,RecipentItems,SenderProfile)
					TradeService:CleanUpTrade(TradeID)
				end
			end
		end
	end
end

function TradeService:CleanUpTrade(TradeID)
	local ActiveTrade = self.ActiveTrades[TradeID]
	if ActiveTrade then
		ActiveTrade.Replica:Destroy()
		TradeService.ActiveTrades[TradeID] = nil;
	end
end

function TradeService:StartCountDown(TradeID)
	local ActiveTrade = self.ActiveTrades[TradeID]
	if ActiveTrade then
		ActiveTrade.Replica:SetValue("EndingTime",workspace:GetServerTimeNow() + 15)
		ActiveTrade._CurrentlyCountingDown = true;
		local CountdownEvent; CountdownEvent = RunService.Heartbeat:Connect(function()
			local EndingTime = ActiveTrade.Replica.Data.EndingTime
			if ActiveTrade._CurrentlyCountingDown then
				local TimeLeft = EndingTime - workspace:GetServerTimeNow()
				if TimeLeft < 0 then
					CountdownEvent:Disconnect()
					self:ExecuteTrade(TradeID)
					return;
				end
			else
				ActiveTrade._Locked = false;
				CountdownEvent:Disconnect()
			end
		end)
	end
end

function TradeService.LockTrade(Player)
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade and not ActiveTrade._ExecutingTrade then
		local Replica = ActiveTrade.Replica
		local ArrayName = if ActiveTrade.Sender == Player then "SenderItems" elseif ActiveTrade.Recipent == Player then "RecipentItems" else nil;
		local OtherArrayName = if ArrayName == "SenderItems" then "RecipentItems" else "SenderItems" -- VVV this is stupid
		if ArrayName then
			Replica:SetValue({ArrayName.."Locked"},true)
		end
		if Replica.Data.SenderItemsLocked == true and Replica.Data.RecipentItemsLocked == true then
			ActiveTrade._Locked = true;
			TradeService:StartCountDown(ActiveTrade._ID)
		end
	end
end

function TradeService.UnlockTrade(Player)
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade and not ActiveTrade._ExecutingTrade then
		local Replica = ActiveTrade.Replica
		local ArrayName = if ActiveTrade.Sender == Player then "SenderItems" elseif ActiveTrade.Recipent == Player then "RecipentItems" else nil;
		local OtherArrayName = if ArrayName == "SenderItems" then "RecipentItems" else "SenderItems" -- VVV this is stupid
		if ArrayName then
			Replica:SetValue({ArrayName.."Locked"},false)
			ActiveTrade.Replica:SetValue("EndingTime","NULL")
		end
		ActiveTrade._Locked = false;
		ActiveTrade._CurrentlyCountingDown = false;
	end
end

function TradeService.AddItemToTrade(Player,SwordID) -- TODO add in Player checking
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade and not ActiveTrade._ExecutingTrade and not ActiveTrade._CurrentlyCountingDown then
		local ArrayName = if ActiveTrade.Sender == Player then "SenderItems" elseif ActiveTrade.Recipent == Player then "RecipentItems" else nil;
		if ArrayName then
			local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
			if PlayersProfile then
				local FoundSword = SwordService.FindSwordInArrary(SwordID,PlayersProfile.Profile.Data.PlayerData.SwordsInBank_1)
				local SwordInAscender = PlayersProfile.Profile.Data.FactoryInfo.SwordInAscender
				if FoundSword and SwordInAscender ~= SwordID then
					local SwordInformation = PlayersProfile.Profile.Data.PlayerData.SwordsInBank_1[FoundSword]
					if not SwordService.FindSwordInArrary(SwordInformation.ID,ActiveTrade.Replica.Data[ArrayName]) then -- Prevent people from adding the same sword twice
						local EmptyIndex = TradeService:_FindFirstEmptyArraySpot(ActiveTrade.Replica.Data[ArrayName],3)
						if EmptyIndex and not ActiveTrade.Replica.Data[ArrayName.."Locked"]  then
							ActiveTrade.Replica:ArraySet({ArrayName},EmptyIndex,{ID =SwordInformation.ID,Config = SwordInformation.Config})
						end
					end
				end
			end
		end
	end
end

function TradeService:FindTradeFromPlayer(Player)
	for TradeID,TradeInfo in pairs(self.ActiveTrades) do
		if TradeInfo.Sender == Player or TradeInfo.Recipent == Player then
			return TradeInfo,TradeID
		end
	end
end

function TradeService.RemoveItemFromTrade(Player,SwordID)
	print("REmove item from trade")
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade and not ActiveTrade._ExecutingTrade then
		local ArrayName = if ActiveTrade.Sender == Player then "SenderItems" elseif ActiveTrade.Recipent == Player then "RecipentItems" else nil;
		if ArrayName then
			local PlayersReplica = ActiveTrade.Replica
			local SwordIndex = SwordService.FindSwordInArrary(SwordID,PlayersReplica.Data[ArrayName])
			if SwordIndex then
				PlayersReplica:ArraySet({ArrayName},SwordIndex,"NULL")
			end
		end		
	end
end

function TradeService.AcceptedPendingTradeRequest(Recipent,TradeID)
	local PendingTrade = TradeService.PendingTrades[TradeID]
	if PendingTrade then
		if PendingTrade.Recipent == Recipent then --Sender can't force a trade;
			local ActiveTrade = TradeService.NewTrade(PendingTrade.Sender,PendingTrade.Recipent)
			PendingTrade = nil;
			local ActiveTradeReplicaID = ActiveTrade.Replica.Id
			
			local Info = {Sender = ActiveTrade.Sender,Recipent = ActiveTrade.Recipent}
			ReplicatedStorage.RemoteEvents.TradingEvents.ActiveTradingRequest:FireClient(ActiveTrade.Sender,ActiveTradeReplicaID,"SenderItems",Info)
			ReplicatedStorage.RemoteEvents.TradingEvents.ActiveTradingRequest:FireClient(ActiveTrade.Recipent,ActiveTradeReplicaID,"RecipentItems",Info)
			TradeService.PendingTrades[TradeID] = nil
		end
	end
end

function TradeService.DeclinePendingTradeRequest(Recipent,TradeID)
	local PendingTrade = TradeService.PendingTrades[TradeID]
	if PendingTrade then
		if PendingTrade.Recipent == Recipent then --Sender can't force a trade;
			TradeService.PendingTrades[TradeID] = nil
		end
	end
end


function TradeService.SendUserTradeRequest(Sender,Recipent)
	if Sender == Recipent then
		return false, "Error 402 (This error code has no meaning)"
	end

	local SendersProfile = DataStoreService.ReturnPlayersProfile(Sender)
	local RecieverProfile = DataStoreService.ReturnPlayersProfile(Recipent)
	if SendersProfile and RecieverProfile then 

		local Cooldown = TradeService.PlayersOnCoolDown[Sender]
		if Cooldown and Cooldown - workspace:GetServerTimeNow() > 0 then -- Cooldown Checks 
			local TimeLeft = Cooldown - workspace:GetServerTimeNow()
			return false, "Please wait " .. math.round(TimeLeft) .. " Seconds before sending another trade request"
		end
		TradeService.PlayersOnCoolDown[Sender] = workspace:GetServerTimeNow() + 60 -- 60 Second Cooldown 

		local RecipentsPrivacySetting = RecieverProfile.Profile.Data.PlayerData.Settings.TradingPrivacy -- Privacy Checks   
		if RecipentsPrivacySetting == 'OFF' then
			return false, "Recipent isn't currently afllowing Trading Requests"
		elseif RecipentsPrivacySetting == "Friends" then
			if not Recipent:IsFriendsWith(Sender.UserId) then
				return false, "Recipent isn't currently allowing Trading Requests"
			end
		end

		for _,ActiveTrade in pairs(TradeService.ActiveTrades) do -- Check both players to see if they are activetly trading someone else;
			if ActiveTrade.Sender == Sender or ActiveTrade.Sender == Recipent then
				return false, "You are already trading with someone"
			end
			if ActiveTrade.Reciever == Sender or ActiveTrade.Reciever == Recipent then
				return false, "You are already trading with someone"
			end
		end

		for _,PendingTrades in pairs(TradeService.PendingTrades) do -- Check both players to see if they have a pending trading request I might change this
			if PendingTrades.Sender == Sender or PendingTrades.Sender == Recipent then
				return false, "You are already trading with someone"
			end
			if PendingTrades.Reciever == Sender or PendingTrades.Reciever == Recipent then
				return false, "You are already trading with someone"
			end
		end		
		local RandomID = HttpService:GenerateGUID()
		TradeService.PendingTrades[RandomID] = {
			Sender = Sender;
			Recipent = Recipent;
		}

		ReplicatedStorage.RemoteEvents.TradingEvents.NotifyTradingRequest:FireClient(Recipent,Sender,RandomID)
		return true, "Trade has been sucessfully sent"
	end
	return false, "Unkown Error has happended :("
end


function TradeService.CancelTrade(Player)
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade and not ActiveTrade._Locked then
		TradeService:CleanUpTrade(ActiveTrade._ID)
	end
end

function TradeService.GetTradeablePlayers(User)
	local PlayerList = {}
	for _,Player in pairs(Players:GetPlayers()) do
		if Player == User then continue end
		local PlayersProfiles = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfiles then
			local RecipentsPrivacySetting = PlayersProfiles.Profile.Data.PlayerData.Settings.TradingPrivacy -- Privacy Checks   
			if RecipentsPrivacySetting == "All" then
				table.insert(PlayerList,Player)
			elseif RecipentsPrivacySetting == "Friends" then
				if Player:IsFriendsWith(User) then
					table.insert(PlayerList,Player)
				end
			end
		end
	end
	return PlayerList
end


function TradeService:PlayerLeft(Player)
	local ActiveTrade = TradeService:FindTradeFromPlayer(Player)
	if ActiveTrade then
		self:CleanUpTrade(ActiveTrade._ID)
	end
end


function TradeService.TradePrivacyChange(Player,NewValue)
	local AllowedValues = {"ALL","OFF","FRIENDS"}
	if table.find(AllowedValues,NewValue) then
		local PlayersProfile = DataStoreService.ReturnPlayersProfile(Player)
		if PlayersProfile then
			PlayersProfile.Replica:SetValue({"PlayerData","Settings","TradingPrivacy"},NewValue)
		end 
	end
end

ReplicatedStorage.RemoteFunction.TradingFunctions.SendTradeRequest.OnServerInvoke = TradeService.SendUserTradeRequest
ReplicatedStorage.RemoteFunction.TradingFunctions.GetTradeablePlayers.OnServerInvoke = TradeService.GetTradeablePlayers
ReplicatedStorage.RemoteEvents.TradingEvents.AcceptedTradingRequest.OnServerEvent:Connect(TradeService.AcceptedPendingTradeRequest)
ReplicatedStorage.RemoteEvents.TradingEvents.DeclinedTradingRequest.OnServerEvent:Connect(TradeService.DeclinePendingTradeRequest)

ReplicatedStorage.RemoteEvents.TradingEvents.AddItemToTrade.OnServerEvent:Connect(TradeService.AddItemToTrade)
ReplicatedStorage.RemoteEvents.TradingEvents.RemoveItemFromTrade.OnServerEvent:Connect(TradeService.RemoveItemFromTrade)
ReplicatedStorage.RemoteEvents.TradingEvents.LockTrade.OnServerEvent:Connect(TradeService.LockTrade)
ReplicatedStorage.RemoteEvents.TradingEvents.UnlockTrade.OnServerEvent:Connect(TradeService.UnlockTrade)
ReplicatedStorage.RemoteEvents.TradingEvents.CancelTrade.OnServerEvent:Connect(TradeService.CancelTrade)
ReplicatedStorage.RemoteEvents.SettingsEvent.ChangeTradePrivacy.OnServerEvent:Connect(TradeService.TradePrivacyChange)

return TradeService
