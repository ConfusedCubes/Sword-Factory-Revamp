local CashProducts = {
	[1240168881] = function(PlayerLevel)
		return 90+(10*(1.06^PlayerLevel)*1)
	end,
	[1240168928] = function(PlayerLevel)
		return 400+(10*(1.06^PlayerLevel)*10)
	end,
	[1240168973] = function(PlayerLevel)
		return 1700+(10*(1.06^PlayerLevel)*30)
	end,
	[1240169028] = function(PlayerLevel)
		return 8500+(10*(1.06^PlayerLevel)*150)
	end,
	[1240169123] = function(PlayerLevel)
		return 30000+(10*(1.06^PlayerLevel)*500)
	end,
}

return CashProducts
