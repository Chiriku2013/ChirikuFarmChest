--==[ Chest Farm Script | Smart Server Hop | By Chiriku Roblox ]==--
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
        Text = "Đang tải... Chờ 2s để bắt đầu farm chest!",
        Duration = 5
    })
end)

-- ANTI AFK
spawn(function()
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
        for _,v in pairs(game:GetService("Teams"):GetChildren()) do
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

-- SAVE SETTINGS ON TELEPORT
queue_on_teleport([[
    getgenv().Team = "]]..getgenv().Team..[["
    getgenv().Speed = ]]..getgenv().Speed..[[
    getgenv().TotalMoney = ]]..getgenv().TotalMoney..[[
    getgenv().Enabled = true
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Chiriku2013/ChirikuFarmChest/refs/heads/main/ChirikuFarmChest.lua"))()
]])

-- TWEEN MƯỢT
function TweenTo(pos)
    local TweenService = game:GetService("TweenService")
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local distance = (hrp.Position - pos).Magnitude
    local tweenTime = distance / getgenv().Speed
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tweenGoal = {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))}
    local tween = TweenService:Create(hrp, tweenInfo, tweenGoal)
    tween:Play()
    tween.Completed:Wait()
end

-- LẤY CHEST TOÀN BẢN ĐỒ
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

-- FARM CHEST
spawn(function()
    wait(2)
    while task.wait(1) do
        if getgenv().Enabled then
            local chests = GetAllChests()
            table.sort(chests, function(a, b)
                return (a.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                       (b.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)

            local found = false
            for _, chest in ipairs(chests) do
                if not getgenv().Enabled then break end
                local oldBeli = game.Players.LocalPlayer.Data.Beli.Value
                TweenTo(chest.Position)
                task.wait(0.2)
                local newBeli = game.Players.LocalPlayer.Data.Beli.Value
                local earned = newBeli - oldBeli
                if earned > 0 then
                    getgenv().TotalMoney += earned
                    moneyLabel.Text = "Beli nhặt được: " .. tostring(getgenv().TotalMoney)
                    pcall(function()
                        game.StarterGui:SetCore("SendNotification", {
                            Title = "Nhặt được Beli!",
                            Text = "+ " .. tostring(earned),
                            Duration = 2
                        })
                    end)
                    found = true
                end
            end

            if not found then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
            end
        end
    end
end)
