local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)


local MusicController = {}

local Songs = {
	
	1842241530,
	1846458016,
	1841987490,
	1843382567,
}


function MusicController:PlaySong(SoundID)
	local Sound = Instance.new("Sound")
	Sound.SoundId = "rbxassetid://" .. SoundID
	Sound.Parent = game.SoundService
	Sound:Play()
	Sound.Name = "Music"
	Sound.Volume = 0.2
	Sound.Ended:Connect(function()
		Sound:Destroy()
	end)
	return Sound.Ended
end

function MusicController:StopPlayingMusic()
	local Music = game.SoundService:FindFirstChild("Music")
	if Music then
		Music:Destroy()
	end
end

function MusicController:Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		Replica:ListenToChange({"PlayerData","Settings","MuteMusic"},function(Muted)
			if Muted then
				MusicController:StopPlayingMusic()
			else
				MusicController:StartPlayingMusic()
			end
		end)
		if not Replica.Data.PlayerData.Settings.MuteMusic then
			MusicController:StartPlayingMusic()
		end
	end)
end

function MusicController:StartPlayingMusic()
	local RandomSong = Songs[math.random(1,#Songs)]
	local SongFinished = MusicController:PlaySong(RandomSong)
	SongFinished:Connect(function()
		self:StartPlayingMusic()
	end)
end


return MusicController
