local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Services = ServerScriptService.Services
local SharedModules = ReplicatedStorage.Modules.SharedModules

local SwordService = require(script.Parent)
local DataStoreService = require(Services.DataStoreService)

local SwordSavingService = {}

function SwordSavingService.SwordRemoving(Player,Item)
	local SwordID = Item:GetAttribute("SwordID")
	if SwordID then
		local Profile = DataStoreService.ReturnPlayersProfile(Player)
		if Profile  then
			local CurrentData = Profile.Replica.Data.PlayerData.SwordsInInventory
			CurrentData[SwordID] = nil;
			Profile.Replica:SetValue("PlayerData.SwordsInInventory",CurrentData)
		end
	end
end

function SwordSavingService.SwordAdded(Player,Item,Path)
	local SwordID = Item:GetAttribute("SwordID")
	if SwordID then
		local Profile = DataStoreService.ReturnPlayersProfile(Player)
		if Profile  then
			local SwordObject = SwordService.GetSwordInfo(SwordID)
			if SwordObject then
				local CurrentData = Profile.Replica.Data.PlayerData.SwordsInInventory
				CurrentData[SwordID] = SwordObject.Config
				Profile.Replica:SetValue(Path,CurrentData)
			end
		end
	end
end


function SwordSavingService.Init(Player)
	local Backpack = Player.Backpack
	Backpack.ChildAdded:Connect(function(Item)
		SwordSavingService.SwordAdded(Player,Item,"PlayerData.SwordsInInventory")
	end)
	
	Player.Character.ChildRemoved:Connect(function(Item)
		if not Item:IsDescendantOf(Player.Backpack) then -- The sword was not unequipped
			SwordSavingService.SwordRemoving(Player,Item)
		end
	end)
end



function SwordSavingService.CleanUp(Player)


end










return SwordSavingService
