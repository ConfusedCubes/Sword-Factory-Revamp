--	// FileName: ChatCommandsTeller.lua
--	// Written by: Xsitsu
--	// Description: Module that provides information on default chat commands to players.

local Chat = game:GetService("Chat")
local ReplicatedModules = Chat:WaitForChild("ClientChatModules")
local ChatSettings = require(ReplicatedModules:WaitForChild("ChatSettings"))
local ChatConstants = require(ReplicatedModules:WaitForChild("ChatConstants"))

local ChatLocalization = nil
pcall(function() ChatLocalization = require(game:GetService("Chat").ClientChatModules.ChatLocalization) end)
if ChatLocalization == nil then ChatLocalization = { Get = function(key,default) return default end } end

local function Run(ChatService)

	local function ShowJoinAndLeaveCommands()
		if ChatSettings.ShowJoinAndLeaveHelpText ~= nil then
			return ChatSettings.ShowJoinAndLeaveHelpText
		end
		return false
	end

	local function ProcessCommandsFunction(fromSpeaker, message, channel)
		if (message:lower() == "/?" or message:lower() == "/help") then
			local speaker = ChatService:GetSpeaker(fromSpeaker)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","These are the basic chat commands."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_MeCommand","/me <text> : roleplaying command for doing actions."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_SwitchChannelCommand","/c <channel> : switch channel menu tabs."), channel)
			if ShowJoinAndLeaveCommands() then
				speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_JoinChannelCommand","/join <channel> or /j <channel> : join channel."), channel)
				speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_LeaveChannelCommand","/leave <channel> or /l <channel> : leave channel. (leaves current if none specified)"), channel)
			end
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_WhisperCommand","/whisper <speaker> or /w <speaker> : open private message channel with speaker."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_MuteCommand","/mute <speaker> : mute a speaker."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_UnMuteCommand","/unmute <speaker> : unmute a speaker."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_ToggleCommand","/toggle <tags/color> : toggles chat tags or chat color."), channel)

			local player = speaker:GetPlayer()
			if player and player.Team then
				speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_TeamCommand","/team <message> or /t <message> : send a team chat to players on your team."), channel)
			end

			return true
		elseif (message:lower() == "/tutorial") then
			local speaker = ChatService:GetSpeaker(fromSpeaker)	
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","/ Tutorial \."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You get points by walking/running or collecting orbs."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You get EXP from collecting orbs, which will turn into Level!"), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You can unlock new areas with levels and u get cash from leveling up."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","/ Stat to Stat's \."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","Points -> Rebirth -> Prestige -> Sacrifice -> Ultra."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You get ranks by using an amount of cash and ultra, it will reset progress but with an op multiplier boost."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","/ Other Info \."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You can only donate a max of 1D, Typing 'All' in the username bar distributes the points to everyone."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","Click the pink button to open the Stat Panel."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","It is useful for mobile because they cant see most of their stats."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","Click the gray button to open the Settings Panel."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You can set your speed from 0 to ur current max speed."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","You have to turn off 'Auto Set Speed' for it to work, otherwise nothing happens."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","There are also gamepass buttons, only works when having the gamepasses."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","Lastly, the VIP gamepass. It gives you a 1.5x Boost in everything except ultra, really worth it for the small 300 price."), channel)
			speaker:SendSystemMessage(ChatLocalization:Get("GameChat_ChatCommandsTeller_Desc","Thats all for the tutorial, Have Fun Grinding!"), channel)

			return true
		end

		return false
	end

	ChatService:RegisterProcessCommandsFunction("chat_commands_inquiry", ProcessCommandsFunction, ChatConstants.StandardPriority)

	if ChatSettings.GeneralChannelName then
		local allChannel = ChatService:GetChannel(ChatSettings.GeneralChannelName)
		if (allChannel) then
			allChannel.WelcomeMessage = ChatLocalization:Get("GameChat_ChatCommandsTeller_AllChannelWelcomeMessage","Welcome to Orb Simulator, Type /tutorial for a tutorial!")
		end
	end
end

return Run
