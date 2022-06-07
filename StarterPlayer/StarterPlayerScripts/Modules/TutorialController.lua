
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")


local ReplicaController = require(ReplicatedStorage.Modules.SharedModules.ReplicaController)
local Player = Players.LocalPlayer
local TutorialController = {}
local PlayerGui = Player.PlayerGui
local GameGUI = PlayerGui:WaitForChild("GameUI")
local TutorialGUI = GameGUI.Tutorial.ImageLabel


local TutorialFlow = {
	{
		TitleText = "Welcome To Sword Factory";
		ParagraphText = "Would you like to play the Tutorial?"
	};
	{
		CameraName = "CameraOne";
		TitleText = "Welcome To Sword Factory";
		ParagraphText = "This is Factory line."
	};
	{
		CameraName = "CameraTwo";
		TitleText = "Welcome To Sword Factory";
		ParagraphText = "New Information!"
	};
	{
		CameraName = "CameraThree";
		TitleText = "Welcome To Sword Factory";
		ParagraphText = "New Information!"
	}	;
	{
		CameraName = "CameraFour";
		TitleText = "Welcome To Sword Factory";
		ParagraphText = "New Information!"
	}	
}
local CurrentSceneIndex = 1;




function TutorialController.CameraPanTo(CFrame)
	local CameraPanTween = TweenService:Create(workspace.CurrentCamera,TweenInfo.new(3),{CFrame = CFrame})
	CameraPanTween:Play()
end

function TutorialController.PlayScene(SceneIndex)
	local SceneInfo = TutorialFlow[SceneIndex]
	if SceneInfo then
		TutorialGUI.Title.Text = SceneInfo.TitleText
		TutorialGUI.Paragraph.Text = SceneInfo.ParagraphText
		CurrentSceneIndex = SceneIndex
		if SceneInfo.CameraCFrame then
			TutorialController.CameraPanTo(SceneInfo.CameraCFrame)
		end
	end
	
end

function TutorialController.InitateTutorial(Base) -- Now this is janky.
	local PlayersCamera = workspace.CurrentCamera
	for Index,TutorialScene in pairs(TutorialFlow) do
		if TutorialScene.CameraName then
			local CameraName = TutorialScene.CameraName
			TutorialScene.CameraCFrame = Base:WaitForChild(CameraName).CFrame
		end
	end
	TutorialGUI.InputBegan:Connect(function(InputObject)
		if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			if CurrentSceneIndex == 1 then
				PlayersCamera.CameraType = Enum.CameraType.Scriptable
			end
			local NextSceneIndex = next(TutorialFlow,CurrentSceneIndex)
			TutorialController.PlayScene(NextSceneIndex)
		end
	end)
	TutorialController.PlayScene(1)
end



function TutorialController.Init()
	ReplicaController.ReplicaOfClassCreated("PlayerProfile", function(Replica)
		if not Replica.Data.PlayerData.PlayTutorial then
			ReplicatedStorage.RemoteEvents.BaseCreated.OnClientEvent:Connect(function(Base)
				TutorialController.InitateTutorial(Base)
			end)
		end
	end)
end


return TutorialController
 