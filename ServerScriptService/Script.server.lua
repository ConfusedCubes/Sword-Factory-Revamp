local Module = game.ReplicatedStorage.ModuleScript

local Sort = function(A,B)
	return tonumber(A.Name) > tonumber(B.Name)
end


local Molds = game.ReplicatedStorage.Qualities:GetChildren()
table.sort(Molds,Sort)

for i,v in pairs(Molds) do
	local Name = v.QualityName.Value
	local MoldChance = v.QualityChance.Value
	local ValueMulti = v.ValueMulti.Value
	local MoldColor = Color3.fromHex("afafaf")
	
	

	local String = '{' ..  "\n" .. "	Name = " .. '"' .. Name .. '"' .. "; \n" .. "	Chance = " .. MoldChance .. "; \n" .. "	Color = " .. '"' .. MoldColor:ToHex() .. '"' .. "; \n" .. "	Identifier = " .. #Molds-i .. "; \n" .. "}" .. "; \n"

	--local String2 = "[" .. '"' .. Name .. '"' .. "] = { \n" .. "	Multiplier = " .. ValueMulti .. "; \n" .. "	Chance = " .. MoldChance .. "; \n }; \n"

	Module.Source = Module.Source .. String



end

local Raritys = require(game.ReplicatedStorage.Modules.SharedModules.SwordStats.Rarity)

for i,v in pairs(Raritys) do
	print(v.Color)
	local HexColorConversion = Color3.fromHex(v.Color)
	local _,_,BrightLevel = Color3.toHSV(HexColorConversion)
	
	if BrightLevel > 0.8 then
		local Index,NextColor = next(Raritys,i)
		local HexColorConversion = Color3.fromHex(NextColor.Color)
		local _,_,BrightLevel = Color3.toHSV(HexColorConversion)
		if BrightLevel > 0.7 then
			
			print("Too bright")
			v.Color = "afafaf"
		else
			print("OK")
			v.Color = NextColor.Color
		end

	end

end


local DataStoreService = game:GetService("DataStoreService")

local TestStore = DataStoreService:GetDataStore("PlayerData")


local Pages = TestStore:ListKeysAsync()


while true do
	local Items = Pages:GetCurrentPage()

	for i,v in pairs(Items) do
		local value = TestStore:GetAsync(v.KeyName)
		local keyname = v.KeyName
		warn("Removing" .. keyname)
		TestStore:RemoveAsync(keyname)

	end
	if Pages.IsFinished then
		break
	end
	Pages:AdvanceToNextPageAsync()	
end