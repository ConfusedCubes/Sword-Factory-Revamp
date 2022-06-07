local SwordStats = {}


function SwordStats.FindObjectFromIdentifier(Path,Identifier)
	for i,v in pairs(Path) do
		if v.Identifier == Identifier then
			return v;
		end
	end
end


for _,Stat in pairs(script:GetChildren()) do
	SwordStats[Stat.Name] = require(Stat)
end



return SwordStats
