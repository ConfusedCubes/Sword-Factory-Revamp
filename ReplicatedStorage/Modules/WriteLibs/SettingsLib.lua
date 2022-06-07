local WriteLib = {
	-- Mutator functions will receive the first parameter as the
	--   Replica being mutated; Custom parameters passed with
	--   Replica:Write() will follow
	
	ChangeUpgradeBulkMode = function(Replica,BulkMode)
		local AllowedValues = {1,5,50}
		print(BulkMode)
		if table.find(AllowedValues,BulkMode) then
		--	Replica:SetValue({"PlayerData","Settings","CurrrentBulkUpgrade"},BulkMode)
		end
	end,
	
	-- A note for power users:
	--   replica.Children and replica.Parent can be accessed within
	--   WriteLib mutator functions - built-in and custom mutators
	--   can be triggered for those replicas as well. Go wild!
}

return WriteLib