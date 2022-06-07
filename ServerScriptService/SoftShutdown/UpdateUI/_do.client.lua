local ui = script.Parent
local fr = ui:WaitForChild("Frame")
local tim = fr:WaitForChild("tim")
local d = fr:WaitForChild("d")
local s = script:WaitForChild("s")
local b = Instance.new("BlurEffect",workspace.CurrentCamera)
local ti = script:WaitForChild("ti")

d.Text = [[
The game will shutdown to update in 15 seconds.
To avoid problems, leave the game, wait a couple minutes, and rejoin!
]]

s:Play()
for i = 15,0,-1 do
	tim.tex.Text = ("(%s)"):format(i)
	wait(1)
	ti:Play()
end

b:Destroy()
ui:Destroy()