local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RarityBoardController = {}



local SwordStats = require(ReplicatedStorage.Modules.SharedModules.SwordStats)
local Short = require(ReplicatedStorage.Modules.SharedModules.Short)

local Lists = {
	{Table = SwordStats.Mold,BoardName = "MoldBoard",MachineName = "Molder"};
	{Table = SwordStats.Quality,BoardName = "QualityBoard", MachineName = "Polisher"};
	{Table = SwordStats.Class,BoardName = "ClassBoard",MachineName = "Classifier"};
	{Table = SwordStats.Rarity,BoardName = "RarityBoard",MachineName = "Appraiser"};

}






function RarityBoardController:Init()
	local PlayersBase = ReplicatedStorage.RemoteFunction.GetBaseInstance:InvokeServer()
	if PlayersBase then
		for _,Whatever in pairs(Lists) do
			local MachineLuck = ReplicatedStorage.RemoteFunction.GetMachineLuck:InvokeServer(Whatever.MachineName)

			for Index,Information in pairs(Whatever.Table) do
				local Template = script.Template:Clone()
				Template.LabelName.Text = Information.Name
				Template.LabelName.TextColor3 = Color3.fromHex(Information.Color)
				local Luck = math.max(Information.Chance * MachineLuck,1)
				Template.Chance.Text = "1/" .. Short(Luck,2)
				Template.Parent = PlayersBase.Structures:FindFirstChild(Whatever.BoardName).Screen.Gui.Information
			end
		end
		
	end
end


return RarityBoardController
