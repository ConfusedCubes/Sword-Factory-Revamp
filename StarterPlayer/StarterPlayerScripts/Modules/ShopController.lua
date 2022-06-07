-- This controller is a bit of a mess sorry
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketPlaceService = game:GetService("MarketplaceService")


local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local Player = Players.LocalPlayer
local ShopController = {}
local PlayerGui = Player.PlayerGui
local GameGUI = PlayerGui:WaitForChild("GameUI")
local ShopGUI = GameGUI.Shop

local CurrentlySelectedTab = ShopGUI.ImageLabel.Tabs.Selected;


local SelectedSize = UDim2.new(0.271, 0,0.979, 0)
local SelectedImageID = "rbxassetid://9336583663"
local SelectedColorStroke = Color3.fromRGB(150, 105, 1)
local NotSelectedSize = UDim2.new(0.231, 0,0.752, 0)
local NotSelectedImage = "rbxassetid://9336591055"
local NonSelectedColorStroke = Color3.fromRGB(11, 116, 18)

local Replica = nil;

local CashPackFormulas = {
	["Cash Pack 1"] = function(PlayerLevel)
		return 90+(10*(1.06^PlayerLevel)*1)
	end,
	["Cash Pack 2"] = function(PlayerLevel)
		return 400+(10*(1.06^PlayerLevel)*10)
	end,
	["Cash pack 3"] = function(PlayerLevel)
		return 1700+(10*(1.06^PlayerLevel)*30)
	end,
	["Cash Pack 4"] = function(PlayerLevel)
		return 8500+(10*(1.06^PlayerLevel)*150)
	end,
	["Cash Pack 5"] = function(PlayerLevel)
		return 30000+(10*(1.06^PlayerLevel)*500)
	end,
}

function ShopController.CalculateCashPackValue(CashName,Replica)
	local PlayersLevel = Replica.Data.PlayerData.Level
	if PlayersLevel then
		return CashPackFormulas[CashName](PlayersLevel)
	end
end


function ShopController.TabClicked(Tab)
	if CurrentlySelectedTab then
		CurrentlySelectedTab.Size = NotSelectedSize
		CurrentlySelectedTab.Image =  NotSelectedImage
		CurrentlySelectedTab.TextLabel.UIStroke.Color = NonSelectedColorStroke
		local LinkedFrame = CurrentlySelectedTab:GetAttribute("LinkedFrame")
		if LinkedFrame then
			local LinkedFrameInstance = ShopGUI.ImageLabel:FindFirstChild(LinkedFrame)
			if LinkedFrameInstance then
				LinkedFrameInstance.Visible = false;
			end
		end
	end
	Tab.Size = SelectedSize
	Tab.Image = SelectedImageID
	Tab.TextLabel.UIStroke.Color = SelectedColorStroke

	local LinkedFrame = Tab:GetAttribute("LinkedFrame")
	if LinkedFrame then
		local LinkedFrameInstance = ShopGUI.ImageLabel:FindFirstChild(LinkedFrame)
		if LinkedFrameInstance then
			LinkedFrameInstance.Visible = true;
		end
	end
	CurrentlySelectedTab = Tab
end


function ShopController.PopulateGamePassFrame(Frame,GamepassID)
	local Sucess,Information = pcall(MarketPlaceService.GetProductInfo,MarketPlaceService,GamepassID,Enum.InfoType.GamePass)
	if Information and Sucess then
		Frame.Title.Text = Information.Name
		Frame.Description.Text = Information.Description
		Frame.ImageLabel.Image = "rbxassetid://" .. Information.IconImageAssetId
		Frame.Button.TextLabel.Text = Information.PriceInRobux .. " R$"
		local Success, Owned = pcall(MarketPlaceService.UserOwnsGamePassAsync,MarketPlaceService,Player.UserId,GamepassID)
		if Success and Owned then
			Frame.Button.TextLabel.Text = "Owned"
		else
			Frame.Button.MouseButton1Click:Connect(function()
				MarketPlaceService:PromptGamePassPurchase(Player,GamepassID)
			end)
		end
	end
end



MarketPlaceService.PromptGamePassPurchaseFinished:Connect(function(Player,GamepassID,Purchased)
	if Purchased and Player == Players.LocalPlayer then
		for Index,PassFrame in pairs(ShopGUI.ImageLabel.Passes:GetChildren()) do
			if PassFrame:GetAttribute("GamepassID") and PassFrame:GetAttribute("GamepassID") == GamepassID then
				PassFrame.Button.TextLabel.Text = "Owned"
			end
		end
	end
end)

function ShopController.PopulateCashFrame(Frame,GamepassID,Replica)
	local Sucess,Information = pcall(MarketPlaceService.GetProductInfo,MarketPlaceService,GamepassID,Enum.InfoType.Product)
	if Information and Sucess then
		local CashWorth = ShopController.CalculateCashPackValue(Information.Name,Replica) or "ERROR"
		Frame.Title.Text = Information.Name
		Frame.Description.Text = string.format("You will gain $%s", Short(CashWorth,2))
		Frame.ImageLabel.Image = "http://www.roblox.com/asset/?id=9485042781"
		Frame.Button.TextLabel.Text = Information.PriceInRobux .. " R$"
		Frame.Button.MouseButton1Click:Connect(function()
			MarketPlaceService:PromptProductPurchase(Player,GamepassID,false,Enum.CurrencyType.Robux)
		end)
	end
end

function ShopController.PopulateDevProduct(Frame,GamepassID)
	local Sucess,Information = pcall(MarketPlaceService.GetProductInfo,MarketPlaceService,GamepassID,Enum.InfoType.Product)
	if Information and Sucess then
		Frame.Title.Text = Information.Name
		Frame.Description.Text = Information.Description
		Frame.ImageLabel.Image = "rbxassetid://" .. Information.IconImageAssetId
	end
end

function ShopController.SetUpGamePassFrame(Replica)
	for _,ProductFrame in pairs(ShopGUI.ImageLabel:GetChildren()) do
		if ProductFrame:IsA("ScrollingFrame") then
			for _,ProductLabel in pairs(ProductFrame:GetChildren()) do
				if ProductLabel:IsA("ImageLabel") then
					local GamepassID = ProductLabel:GetAttribute("GamepassID")
					if GamepassID then
						if ProductFrame.Name == "Cash" then
							task.spawn(ShopController.PopulateCashFrame,ProductLabel,GamepassID,Replica)
						elseif ProductFrame.Name == "Passes" then
							task.spawn(ShopController.PopulateGamePassFrame,ProductLabel,GamepassID)
						else
							task.spawn(ShopController.PopulateDevProduct,ProductLabel,GamepassID)
						end
					end
				end
			end
		end
	end
end



function ShopController.SetupBoosts()
	for Index,BoostType in pairs(ShopGUI.ImageLabel.Boosts:GetChildren()) do
		if BoostType:IsA("ImageLabel") then
			for _, Button in pairs(BoostType.Frame:GetChildren()) do
				if Button:IsA("ImageButton") then
					Button.MouseButton1Click:Connect(function()
						local GamepassID = Button:GetAttribute("GamepassID")
						local LinkedBoost = Button:GetAttribute("LinkedBoost")
						if GamepassID then
							MarketPlaceService:PromptProductPurchase(Player,GamepassID,false,Enum.CurrencyType.Robux)
						end
						if LinkedBoost then
							ReplicatedStorage.RemoteEvents.BuyBoostWithBossCoins:FireServer(LinkedBoost)
						end
					end)
				end
			end
		end
	end
end

function ShopController.SetupTabs()
	for Index,TabFrame in pairs(ShopGUI.ImageLabel.Tabs:GetChildren()) do
		if TabFrame:IsA("ImageButton") then
			TabFrame.MouseButton1Click:Connect(function()
				ShopController.TabClicked(TabFrame)
			end)
		end
	end	
end


function ShopController.Init()
	ShopController.SetupTabs()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		ShopController.SetUpGamePassFrame(Replica)
	end)
	ShopController.SetupBoosts()
end



return ShopController
