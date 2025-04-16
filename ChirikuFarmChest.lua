repeat wait() until game:IsLoaded()

-- SETTINGS
getgenv().Team = "Marines"
getgenv().Speed = 350
getgenv().Enabled = getgenv().Enabled or false
getgenv().TotalMoney = getgenv().TotalMoney or 0

-- NOTIFY GIỚI THIỆU
pcall(function()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Chest Farm | By Chiriku Roblox",
		Text = "Đang tải... Chờ 2 giây để bắt đầu!",
		Duration = 5
	})
end)

-- ANTI AFK
pcall(function()
	local vu = game:GetService("VirtualUser")
	game.Players.LocalPlayer.Idled:Connect(function()
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
if game.CoreGui:FindFirstChild("ChestFarmUI") then game.CoreGui.ChestFarmUI:Destroy() end
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestFarmUI"

local toggle = Instance.new("TextButton", gui)
toggle.Size = UDim2.new(0, 140, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 100)
toggle.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
toggle.TextColor3 = Color3.fromRGB(255, 255, 0)
toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
toggle.TextSize = 16
toggle.Font = Enum.Font.SourceSansBold
toggle.BorderSizePixel = 0

local moneyLabel = Instance.new("TextLabel", gui)
moneyLabel.Size = UDim2.new(0, 200, 0, 30)
moneyLabel.Position = UDim2.new(0, 10, 0, 145)
moneyLabel.BackgroundTransparency = 1
moneyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
moneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
moneyLabel.TextSize = 16
moneyLabel.Font = Enum.Font.SourceSansBold

toggle.MouseButton1Click:Connect(function()
	getgenv().Enabled = not getgenv().Enabled
	toggle.Text = getgenv().Enabled and "Chest Farm: ON" or "Chest Farm: OFF"
end)

-- QUEUE ON TELEPORT (đã sửa)
queue_on_teleport([[
	getgenv().Team = "]]..getgenv().Team..[["
	getgenv().Speed = ]]..getgenv().Speed..[[
	getgenv().TotalMoney = ]]..getgenv().TotalMoney..[[
	getgenv().Enabled = true
	loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/ChirikuFarmChest/refs/heads/main/ChirikuFarmChest.lua"))()
]])

-- CHEST DETECTION
function GetAllChests()
	local chests = {}
	for _,v in pairs(workspace:GetDescendants()) do
		if v:IsA("Model") and v.Name:lower():find("chest") and v:FindFirstChildWhichIsA("BasePart") then
			local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
			if part and v:FindFirstChildWhichIsA("TouchTransmitter", true) then
				table.insert(chests, part)
			end
		end
	end
	return chests
end

-- Bay đến chest bằng Tween
function TweenTo(pos)
	local TweenService = game:GetService("TweenService")
	local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
	local dist = (hrp.Position - pos).Magnitude
	local time = dist / getgenv().Speed
	local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
	local goal = {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))}
	local tween = TweenService:Create(hrp, info, goal)
	tween:Play()
	tween.Completed:Wait()
end

-- FARM LOOP
spawn(function()
	while wait(1) do
		if getgenv().Enabled then
			wait(2)
			local chests = GetAllChests()
			if #chests == 0 then
				game:GetService("TeleportService"):Teleport(game.PlaceId)
			else
				table.sort(chests, function(a,b)
					return (a.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
						   (b.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				end)
				for _,chest in pairs(chests) do
					if not getgenv().Enabled then break end
					local oldBeli = game.Players.LocalPlayer.Data.Beli.Value
					TweenTo(chest.Position)
					wait(0.2)
					local newBeli = game.Players.LocalPlayer.Data.Beli.Value
					local earned = newBeli - oldBeli
					if earned > 0 then
						getgenv().TotalMoney += earned
						moneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
					end
				end
			end
		end
	end
end)
