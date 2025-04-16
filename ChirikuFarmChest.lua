-- Chest Farm Script | By Chiriku Roblox
repeat wait() until game:IsLoaded()
if game.CoreGui:FindFirstChild("ChestFarmUI") then game.CoreGui["ChestFarmUI"]:Destroy() end

-- SEND NOTIFICATION GIỚI THIỆU
pcall(function()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Chest Farm | By Chiriku Roblox",
		Text = "Đang tải script nhặt rương...",
		Duration = 5
	})
end)

-- SETTINGS
getgenv().Team = "Marines"
getgenv().Speed = 350
getgenv().TotalMoney = getgenv().TotalMoney or 0
getgenv().Enabled = getgenv().Enabled or false

-- QUEUE ON TELEPORT
local ScriptSource = [[
repeat wait() until game:IsLoaded()
getgenv().Team = "]]..getgenv().Team..[["
getgenv().Speed = ]]..getgenv().Speed..[[ 
getgenv().TotalMoney = ]]..getgenv().TotalMoney..[[ 
getgenv().Enabled = true
loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/ChirikuFarmChest/refs/heads/main/ChirikuFarmChest.lua"))()
]]
queue_on_teleport(ScriptSource)

-- ANTI AFK
pcall(function()
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:Connect(function()
		vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		wait(1)
		vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)
end)

-- AUTO TEAM
spawn(function()
	while not game.Players.LocalPlayer.Team or game.Players.LocalPlayer.Team.Name ~= getgenv().Team do
		for i,v in pairs(game:GetService("Teams"):GetChildren()) do
			if v.Name == getgenv().Team then
				game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("SetTeam", getgenv().Team)
			end
		end
		wait(2)
	end
end)

-- UI
local ChestFarmUI = Instance.new("ScreenGui", game.CoreGui)
ChestFarmUI.Name = "ChestFarmUI"

local Toggle = Instance.new("TextButton", ChestFarmUI)
Toggle.Size = UDim2.new(0, 140, 0, 40)
Toggle.Position = UDim2.new(0, 10, 0, 100)
Toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 0)
Toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
Toggle.TextSize = 16
Toggle.Font = Enum.Font.SourceSansBold
Toggle.BorderSizePixel = 0

local MoneyLabel = Instance.new("TextLabel", ChestFarmUI)
MoneyLabel.Size = UDim2.new(0, 200, 0, 30)
MoneyLabel.Position = UDim2.new(0, 10, 0, 145)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
MoneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
MoneyLabel.TextSize = 16
MoneyLabel.Font = Enum.Font.SourceSansBold

Toggle.MouseButton1Click:Connect(function()
	getgenv().Enabled = not getgenv().Enabled
	Toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
end)

-- HOP FUNCTION
function Hop()
	local ts = game:GetService("TeleportService")
	ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
end

-- TÌM CHEST
function FindChest()
	local chests = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v:FindFirstChildWhichIsA("TouchTransmitter", true) and v:FindFirstChildWhichIsA("BasePart") then
			local chestPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
			if chestPart and v.Name:lower():find("chest") then
				table.insert(chests, {Model = v, Part = chestPart})
			end
		end
	end
	return chests
end

-- AUTO CHEST FARM
spawn(function()
	while wait(1) do
		if getgenv().Enabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local chests = FindChest()
			if #chests == 0 then
				Hop()
			else
				table.sort(chests, function(a, b)
					local pos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
					return (a.Part.Position - pos).Magnitude < (b.Part.Position - pos).Magnitude
				end)
				for _,data in pairs(chests) do
					if not getgenv().Enabled then break end
					local part = data.Part
					local oldBeli = game.Players.LocalPlayer.Data.Beli.Value
					pcall(function()
						local char = game.Players.LocalPlayer.Character
						char.Humanoid:ChangeState(11)
						char:WaitForChild("HumanoidRootPart").CFrame = part.CFrame + Vector3.new(0, 15, 0)
						local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
						for i = 1, math.ceil(dist / getgenv().Speed * 10) do wait(0.01) end
					end)
					local newBeli = game.Players.LocalPlayer.Data.Beli.Value
					local earned = newBeli - oldBeli
					if earned > 0 then
						getgenv().TotalMoney += earned
						MoneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
					end
				end
			end
		end
	end
end)

-- THÔNG BÁO ITEM HIẾM
workspace.DescendantAdded:Connect(function(v)
	if v:IsA("Tool") and (v.Name:find("Fist of Darkness") or v.Name:find("God's Chalice")) then
		game.StarterGui:SetCore("SendNotification", {
			Title = "Rare Item!",
			Text = v.Name .. " vừa xuất hiện!",
			Duration = 8
		})
	end
end)
