--Simplest framework possible, just to get something going. -Eduritez
local framework = {}
local RunService = game:GetService("RunService")

--Script inside ServerScriptService
local currentModules = {}

local function Setup(v)
	function v:Get(_,serviceName)
		return currentModules[serviceName]
	end
end

local function Execute(task_name)
	for _,v in pairs (currentModules) do
		local this = v[task_name]
		if this and typeof(this)=="function" then 
			coroutine.wrap(function()
				this() 
			end)()
		end
	end
end

function framework.Start(parent)
	for _,v in pairs (parent:GetDescendants()) do
		if v:IsA("ModuleScript") then
			local f = require(v)
			currentModules[v.Name] = f
			Setup(f)
		end
	end
	
	Execute("Init")
	
	Execute("Start")
	
	if RunService:IsServer() then
		RunService.Stepped:Connect(function()
			Execute("Step")
		end)
	else
		RunService.RenderStepped:Connect(function()
			Execute("Step")
		end)
	end
end

return framework
