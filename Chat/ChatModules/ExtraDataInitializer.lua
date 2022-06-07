--	// FileName: ExtraDataInitializer.lua
--	// Written by: Xsitsu
--	// Description: Module that sets some basic ExtraData such as name color, and chat color.
--
--  // Editted by: Nicholas_Foreman
--  // ^ I'm not a Roblox admin nor an intern. I'm just a bored guy who has OCD and likes a neat chat. :)


local stackTags = false
--[[
	Value	Effect								Example
	true	A player can have multiple tags		[Owner] [Admin] [God] [Nicholas_Foreman]: hi
	false	A player can only have one tag		[Owner] [Nicholas_Foreman]: hi
--]]

local groupRankComparison = ">="
--[[
	Value	Effect
	">="	If the player's rank is greater than or equal to the GroupId Rank
	">"		If the player's rank is greater than to the GroupId Rank
	"<"		If the player's rank is less than the GroupId Rank
	">="	If the player's rank is less than or equal to the GroupId Rank
--]]

--[[
	This is where you put all possible tags and chat colors. So, the index, like in my examples, is the name of the tag that you will later refer to.
	
	Priority is the order in which the tags are added. I have random values for examples.
	
	The higher the number, the more it will be seen first.
	
	Example given what is below, if you have all the tags:
	[Owner] [Developer] [Moderator] [Tester] [VIP] [Roblox Staff] [Roblox Star] [Roblox QA] [Roblox DevForum] [Nicholas_Foreman]: hi
	Let's just say, it's reaaaaally long.
--]]

local possibleTags = {
	["Owner"] = {
		TagText = "Owner",
		TagColor = Color3.fromRGB(255, 0, 0),
		Priority = 25,
	},
	["Creator"] = {
		TagText = "Creator",
		TagColor = Color3.fromRGB(170, 0, 0),
		Priority = 24,
	},
	["CoOwner"] = {
		TagText = "Co-Owner",
		TagColor = Color3.fromRGB(98, 37, 209),
		Priority = 23,
	},
	["Developer"] = {
		TagText = "Developer",
		TagColor = Color3.fromRGB(52, 44, 170),
		Priority = 22,
	},
	["Admin"] = {
		TagText = "Admin",
		TagColor = Color3.fromRGB(0, 200, 0),
		Priority = 21,
	},	
	["Senior Mod"] = {
		TagText = "Sr Mod",
		TagColor = Color3.fromRGB(0, 255, 150),
		Priority = 20,
	},	
	["karbis"] = {
		TagText = "karbis",
		TagColor = Color3.fromRGB(230,0,0),
		Priority = 19,
	},	
	["Manager"] = {
		TagText = "Manager",
		TagColor = Color3.fromRGB(0, 200, 0),
		Priority = 18,
	},
	["Moderator"] = {
		TagText = "Mod",
		TagColor = Color3.fromRGB(25, 148, 255),
		Priority = 17,
	},
	["Contributor"] = {
		TagText = "Contributor",
		TagColor = Color3.fromRGB(255, 0, 100),
		Priority = 16,
	},
	["Roblox Staff"] = {
		TagText = "Roblox Staff",
		TagColor = Color3.fromRGB(255, 85, 85),
		Priority = 15,
	},
	["Roblox Star"] = {
		TagText = "Roblox Star",
		TagColor = Color3.fromRGB(255, 170, 0),
		Priority = 14,
	},
	["Roblox QA"] = {
		TagText = "Roblox QA",
		TagColor = Color3.fromRGB(40, 110, 190),
		Priority = 13,
	},
	["Roblox DevForum"] = {
		TagText = "Roblox DevForum",
		TagColor = Color3.fromRGB(255, 170, 0),
		Priority = 12,
	},
	["Tester"] = {
		TagText = "Tester",
		TagColor = Color3.fromRGB(255, 0, 0),
		Priority = 11,
	},
	["VIP"] = {
		TagText = "VIP",
		TagColor = Color3.fromRGB(255, 170, 0),
		Priority = 10,
	},
	["Obbyist"] = {
		TagText = "Elite Obbyist",
		TagColor = Color3.fromRGB(255, 0, 255),
		Priority = 9,
	},
}

local possibleChatColors = {
	["Red"] = {
		ChatColor = Color3.fromRGB(255, 0, 0),
		Priority = 5,
	},
	["Green"] = {
		ChatColor = Color3.fromRGB(0, 255, 0),
		Priority = 4,
	},
	["Cyan"] = {
		ChatColor = Color3.fromRGB(0, 255, 255),
		Priority = 3,
	},
	["Admin Yellow"] = {
		ChatColor = Color3.fromRGB(255, 215, 0),
		Priority = 2,
	},
	["Golden"] = {
		ChatColor = Color3.fromRGB(255, 170, 0),
		Priority = 2,
	},
	["Intern Blue"] = {
		ChatColor = Color3.fromRGB(175, 221, 255),
		Priority = 1,
	}
}

-- Set the value of Chat Colors
local SpecialChatColors = {
	Gamepasses = {
		--[[{
			--- VIP Gamepass
			GamepassId = 718077,
			ChatColor = possibleChatColors["Admin Yellow"],
		},]]
	},
	Badges = {
		--[[{
			--- Tester Badge
			BadgeId = 336132652,
			ChatColor = possibleChatColors["Admin Yellow"],
		},]]
	},
	Teams = {
		--[[{
			--- Example Team
			Team = "Example",
			ChatColor = possibleChatColors["Admin Yellow"],
		},]]
	},
	Groups = {
		{
			--- Roblox Admins group
			GroupId = 1200769,
			ChatColor = possibleChatColors["Admin Yellow"],
		},
		{
			--- Roblox Interns group
			GroupId = 2868472,
			Rank = 100,
			ChatColor = possibleChatColors["Intern Blue"],
		},
		
		--//
		{
			--- Roblox Interns group
			GroupId = 14157413,
			Rank = 150,
			ChatColor = possibleChatColors["Green"],
		},
		
		--//
		{
			--- Roblox Interns group
			GroupId = 14157413,
			Rank = 100,
			ChatColor = possibleChatColors["Cyan"],
		},
		
		{
			--- Roblox Stars group
			GroupId = 4199740,
			ChatColor = possibleChatColors["Intern Blue"],
		},
	},
	Players = {
		{
			--- Player Id -1, useful for testing.
			UserId = -1,
			ChatColor = possibleChatColors["Admin Yellow"],
		},
		{
			--- Eduritez, not the editor nor adder of chat tags.
			UserId = 37931702,
			ChatColor = possibleChatColors["Green"],
		},
		{
			--- Future
			UserId = 265424697,
			ChatColor = possibleChatColors["Green"],
		},
		{
			--- Illuzive, editor and adder of chat tags.
			UserId = 15433760,
			ChatColor = possibleChatColors["Red"],
		},
	}
}

-- Here is where you refer to the actual tags that you listed above. This saves time and simplicity. Also helps with mass editting. :?
local SpecialTags = {
	Gamepasses = {
	},
	Badges = {
		--[[{
			--- Tester Badge?
			BadgeId = 336132652,
			Tags = {"Tester"}
		},]]
	},
	Teams = {
		--[[{
			--- Example Team
			Team = "Example",
			Tags = {"Owner"}
		},]]
	},
	Groups = {
		{
			--- Roblox Admins group
			GroupId = 1200769,
			Tags = {"Roblox Staff"}
		},
		{
			--- Roblox Interns group
			GroupId = 2868472,
			Rank = 100,
			Tags = {"Roblox Staff"}
		},
		{
			--- Roblox Interns group
			GroupId = 14157413,
			Rank = 200,
			Tags = {"Admin"},
		},
		
		{
			--- Roblox Interns group
			GroupId = 14157413,
			Rank = 100,
			Tags = {"Moderator"},
		},
		
		{
			--- Roblox Stars group
			GroupId = 4199740,
			Tags = {"Roblox Star"}
		},
	},
	Players = {
--[[		{
			--- Nicholas_Foreman, editor and adder of chat tags.
			UserId = 1190196785,
			Tags = {"Owner"}
		},
		{
			--- Nicholas_Foreman, editor and adder of chat tags.
			UserId = 1190196785,
			Tags = {"Creator"}
		},
		{
			--- Nicholas_Foreman, editor and adder of chat tags.
			UserId = 1190196785,
			Tags = {"Developer"}
        },	]]	
		{
			--- Ed
			UserId = 37931702,
			Tags = {"Developer"}
		},
		{
			--- Future
			UserId = 265424697,
			Tags = {"Manager"}
		},
		{
			--- Nicholas_Foreman, editor and adder of chat tags.
			UserId = 1190196785,
			Tags = {"Owner"}
		},
		{
			--- Player Id -1, useful for testing.
			UserId = -1,
			Tags = {"Contributor"}
		},
	}
}

local function MakeIsInGroup(groupId, requiredRank)
	assert(type(requiredRank) == "nil" or type(requiredRank) == "number", "requiredRank must be a number or nil")

	return function(player)
		if player and player.UserId then
			local userId = player.UserId

			local inGroup = false
			local success, err = pcall(function() -- Many things can error is the IsInGroup check
				if requiredRank then
					if groupRankComparison == ">=" then
						inGroup = player:GetRankInGroup(groupId) >= requiredRank
					elseif groupRankComparison == ">" then
						inGroup = player:GetRankInGroup(groupId) > requiredRank
					elseif groupRankComparison == "<" then
						inGroup = player:GetRankInGroup(groupId) < requiredRank
					elseif groupRankComparison == "<=" then
						inGroup = player:GetRankInGroup(groupId) <= requiredRank
					end
				else
					inGroup = player:IsInGroup(groupId)
				end
			end)
			if not success and err then
				print("Error checking in group: " ..err)
			end

			return inGroup
		end

		return false
	end
end

local function ConstructIsInGroups()
	if SpecialChatColors.Groups then
		for _, group in pairs(SpecialChatColors.Groups) do
			group.IsInGroup = MakeIsInGroup(group.GroupId, group.Rank)
		end
	end
	if SpecialTags.Groups then
		for _, group in pairs(SpecialTags.Groups) do
			group.IsInGroup = MakeIsInGroup(group.GroupId, group.Rank)
		end
	end
end
ConstructIsInGroups()

local Players = game:GetService("Players")


--[[
	THIS IS A MESS. IF YOU WANT TO CLEAN IT UP, GO FOR IT. SORRY FOR ALL OF YOU SCRIPTERS OUT THERE. LMAO.
--]]
function GetSpecialChatColor(speakerName)
	local chatColor = Color3.new(1,1,1)
	local currentPriority = 0
	if SpecialChatColors.Players then
		local playerFromSpeaker = Players:FindFirstChild(speakerName)
		if playerFromSpeaker then
			for _, player in pairs(SpecialChatColors.Players) do
				if playerFromSpeaker.UserId == player.UserId then
					if player["ChatColor"]["Priority"] > currentPriority then
						currentPriority = player["ChatColor"]["Priority"]
						chatColor = player["ChatColor"]["ChatColor"]
					end
				end
			end
		end
	end
	if SpecialChatColors.Groups then
		for _, group in pairs(SpecialChatColors.Groups) do
			if group.IsInGroup(Players:FindFirstChild(speakerName)) then
				if group["ChatColor"]["Priority"] > currentPriority then
					currentPriority = group["ChatColor"]["Priority"]
					chatColor = group["ChatColor"]["ChatColor"]
				end
			end
		end
	end
	if SpecialChatColors.Teams then
		local playerFromSpeaker = Players:FindFirstChild(speakerName)
		if playerFromSpeaker then
			for _, team in pairs(SpecialChatColors.Teams) do
				local actualTeam = game:GetService("Teams"):FindFirstChild(team.Team)
				if playerFromSpeaker.Team == actualTeam then
					if team["ChatColor"]["Priority"] > currentPriority then
						currentPriority = team["ChatColor"]["Priority"]
						chatColor = team["ChatColor"]["ChatColor"]
					end
				end
			end
		end
	end
	if SpecialChatColors.Gamepasses then
		for _, gamepass in pairs(SpecialChatColors.Gamepasses) do
			local playerFromSpeaker = Players:FindFirstChild(speakerName)
			if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(playerFromSpeaker.UserId, gamepass.GamepassId) then
				if gamepass["ChatColor"]["Priority"] > currentPriority then
					currentPriority = gamepass["ChatColor"]["Priority"]
					chatColor = gamepass["ChatColor"]["ChatColor"]
				end
			end
		end
	end
	if SpecialChatColors.Badges then
		for _, badge in pairs(SpecialChatColors.Badges) do
			local playerFromSpeaker = Players:FindFirstChild(speakerName)
			if game:GetService("BadgeService"):UserHasBadge(playerFromSpeaker.UserId, badge.BadgeId) then
				if badge["ChatColor"]["Priority"] > currentPriority then
					currentPriority = badge["ChatColor"]["Priority"]
					chatColor = badge["ChatColor"]["ChatColor"]
				end
			end
		end
	end
	return chatColor
end
function GetSpecialTags(speakerName)
	local tags = {}
	local currentPriority = 0
	if SpecialTags.Players then
		local playerFromSpeaker = Players:FindFirstChild(speakerName)
		if playerFromSpeaker then
			for _, player in pairs(SpecialTags.Players) do
				if playerFromSpeaker.UserId == player.UserId then
					for possibleTagName,possibleTagValue in pairs(possibleTags) do
						for i,playerTagName in pairs(player.Tags) do
							if playerTagName == possibleTagName then
								if stackTags then
									table.insert(tags,possibleTagValue)
									if possibleTagValue["Priority"] > currentPriority then
										currentPriority = possibleTagValue["Priority"]
									end
								else
									if possibleTagValue["Priority"] > currentPriority then
										tags = {possibleTagValue}
										currentPriority = possibleTagValue["Priority"]
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if SpecialTags.Groups then
		for _, group in pairs(SpecialTags.Groups) do
			if group.IsInGroup(Players:FindFirstChild(speakerName)) then
				for possibleTagName,possibleTagValue in pairs(possibleTags) do
					for i,groupTagName in pairs(group.Tags) do
						if groupTagName == possibleTagName then
							if stackTags then
								table.insert(tags,possibleTagValue)
								if possibleTagValue["Priority"] > currentPriority then
									currentPriority = possibleTagValue["Priority"]
								end
							else
								if possibleTagValue["Priority"] > currentPriority then
									tags = {possibleTagValue}
									currentPriority = possibleTagValue["Priority"]
								end
							end
						end
					end
				end
			end
		end
	end
	if SpecialTags.Teams then
		local playerFromSpeaker = Players:FindFirstChild(speakerName)
		if playerFromSpeaker then
			for _, team in pairs(SpecialTags.Teams) do
				local actualTeam = game:GetService("Teams"):FindFirstChild(team.Team)
				if playerFromSpeaker.Team == actualTeam then
					for possibleTagName,possibleTagValue in pairs(possibleTags) do
						for i,playerTagName in pairs(team.Tags) do
							if playerTagName == possibleTagName then
								if stackTags then
									table.insert(tags,possibleTagValue)
									if possibleTagValue["Priority"] > currentPriority then
										currentPriority = possibleTagValue["Priority"]
									end
								else
									if possibleTagValue["Priority"] > currentPriority then
										tags = {possibleTagValue}
										currentPriority = possibleTagValue["Priority"]
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if SpecialTags.Gamepasses then
		for _, gamepass in pairs(SpecialTags.Gamepasses) do
			local playerFromSpeaker = Players:FindFirstChild(speakerName)
			if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(playerFromSpeaker.UserId, gamepass.GamepassId) then
				local playerTags = {}
				for possibleTagName,possibleTagValue in pairs(possibleTags) do
					for i,gamepassTagName in pairs(gamepass.Tags) do
						if gamepassTagName == possibleTagName then
							if stackTags then
								table.insert(tags,possibleTagValue)
								if possibleTagValue["Priority"] > currentPriority then
									currentPriority = possibleTagValue["Priority"]
								end
							else
								if possibleTagValue["Priority"] > currentPriority then
									tags = {possibleTagValue}
									currentPriority = possibleTagValue["Priority"]
								end
							end
						end
					end
				end
			end
		end
	end
	if SpecialTags.Badges then
		for _, badge in pairs(SpecialTags.Badges) do
			local playerFromSpeaker = Players:FindFirstChild(speakerName)
			if game:GetService("BadgeService"):UserHasBadge(playerFromSpeaker.UserId, badge.BadgeId) then
				local playerTags = {}
				for possibleTagName,possibleTagValue in pairs(possibleTags) do
					for i,badgeTagName in pairs(badge.Tags) do
						if badgeTagName == possibleTagName then
							if stackTags then
								table.insert(tags,possibleTagValue)
								if possibleTagValue["Priority"] > currentPriority then
									currentPriority = possibleTagValue["Priority"]
								end
							else
								if possibleTagValue["Priority"] > currentPriority then
									tags = {possibleTagValue}
									currentPriority = possibleTagValue["Priority"]
								end
							end
						end
					end
				end
			end
		end
	end
	local returnTags = {}
	if #tags > 1 then
		for i = currentPriority, 1, -1 do
			for tagIndex,tagValue in pairs(tags) do
				if tagValue["Priority"] == i then
					table.insert(returnTags, tagValue)
				end
			end
		end
	else
		returnTags = tags
	end
	return returnTags
end

local function Run(ChatService)
	local NAME_COLORS =
	{
		Color3.new(253/255, 41/255, 67/255), -- BrickColor.new("Bright red").Color,
		Color3.new(1/255, 162/255, 255/255), -- BrickColor.new("Bright blue").Color,
		Color3.new(2/255, 184/255, 87/255), -- BrickColor.new("Earth green").Color,
		BrickColor.new("Bright violet").Color,
		BrickColor.new("Bright orange").Color,
		BrickColor.new("Bright yellow").Color,
		BrickColor.new("Light reddish violet").Color,
		BrickColor.new("Brick yellow").Color,
	}

	local function GetNameValue(pName)
		local value = 0
		for index = 1, #pName do
			local cValue = string.byte(string.sub(pName, index, index))
			local reverseIndex = #pName - index + 1
			if #pName%2 == 1 then
				reverseIndex = reverseIndex - 1
			end
			if reverseIndex%4 >= 2 then
				cValue = -cValue
			end
			value = value + cValue
		end
		return value
	end

	local color_offset = 0
	local function ComputeNameColor(pName)
		return NAME_COLORS[((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1]
	end

	local function GetNameColor(speaker)
		local player = speaker:GetPlayer()
		if player then
			if player.Team ~= nil then
				return player.TeamColor.Color
			end
		end
		return ComputeNameColor(speaker.Name)
	end

	ChatService.SpeakerAdded:connect(function(speakerName)
		local speaker = ChatService:GetSpeaker(speakerName)
		if not speaker:GetExtraData("NameColor") then
			speaker:SetExtraData("NameColor", GetNameColor(speaker))
		end
		if not speaker:GetExtraData("ChatColor") then
			local specialChatColor = GetSpecialChatColor(speakerName)
			if specialChatColor then
				speaker:SetExtraData("ChatColor", specialChatColor)
			end
		end
		if not speaker:GetExtraData("Tags") then
			local specialTags = GetSpecialTags(speakerName)
			speaker:SetExtraData("Tags", specialTags)
		end
	end)

	local PlayerChangedConnections = {}
	Players.PlayerAdded:connect(function(player)
		local changedConn = player.Changed:connect(function(property)
			local speaker = ChatService:GetSpeaker(player.Name)
			if speaker then
				if property == "TeamColor" or property == "Neutral" or property == "Team" then
					speaker:SetExtraData("NameColor", GetNameColor(speaker))
					local specialTags = GetSpecialTags(player.Name)
					speaker:SetExtraData("Tags", specialTags)
				end
			end
		end)
		PlayerChangedConnections[player] = changedConn
	end)

	Players.PlayerRemoving:connect(function(player)
		local changedConn = PlayerChangedConnections[player]
		if changedConn then
			changedConn:Disconnect()
		end
		PlayerChangedConnections[player] = nil
	end)
	
	local DefaultChatSystemChatEvents = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents");
	local event = Instance.new("RemoteEvent");
	event.Name = "Toggle"
	event.Parent = DefaultChatSystemChatEvents
	event.OnServerEvent:Connect(function(player, eventType)
		local speaker = ChatService:GetSpeaker(player.Name)
		if eventType == "Tags" then
			if not speaker:GetExtraData("Tags") or not speaker:GetExtraData("Tags")[1] then
				local specialTags = GetSpecialTags(player.Name)
				speaker:SetExtraData("Tags", specialTags)
			else
				speaker:SetExtraData("Tags", {})
			end
		elseif eventType == "Color" then
			if not speaker:GetExtraData("ChatColor") then
				local specialChatColor = GetSpecialChatColor(player.Name)
				if specialChatColor then
					speaker:SetExtraData("ChatColor", specialChatColor)
				end
			else
				speaker:SetExtraData("ChatColor", false)
			end
		end
	end)
end

return Run