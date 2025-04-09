repeat wait() until game:IsLoaded()

-- // Auto chọn team
local teamToJoin = "Marines" -- ← Đổi thành "Marines" nếu muốn
spawn(function()
    while not game:IsLoaded() do wait() end
    wait(2)

    local plr = game.Players.LocalPlayer
    local choose = game:GetService("ReplicatedStorage").Remotes.ChooseTeam

    if plr.Team == nil then
        choose:FireServer(teamToJoin)
    elseif plr.Team.Name ~= teamToJoin then
        warn("Sai team, đang reset để đổi...")
        plr.Character:BreakJoints()
        wait(5)
        choose:FireServer(teamToJoin)
    end
end)

-- // Giới thiệu
print("====== Chest Farm V5 ======")
print("Auto Team | Full Chest Fix | GUI | Server Hop | Fly Bypass | Delta X")
print("================================")

-- // Anti AFK
game.Players.LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
    wait(1)
    game:GetService("VirtualUser"):Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
end)

-- // Biến
local farming = false
local speed = 120

-- // GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestFarmGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 250, 0, 180)
frame.Position = UDim2.new(0.5, -125, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Text = "Chest Farm V5"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(255, 255, 255)

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0.5, -75, 0, 40)
toggle.Size = UDim2.new(0, 150, 0, 35)
toggle.Text = "BẬT FARM"
toggle.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
toggle.TextColor3 = Color3.new(1,1,1)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.BorderSizePixel = 0
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 8)

local speedLabel = Instance.new("TextLabel", frame)
speedLabel.Text = "Tốc độ: "..speed
speedLabel.Position = UDim2.new(0, 15, 0, 85)
speedLabel.Size = UDim2.new(0, 200, 0, 25)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 16
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", frame)
speedBox.Position = UDim2.new(0, 15, 0, 110)
speedBox.Size = UDim2.new(0, 220, 0, 30)
speedBox.PlaceholderText = "Nhập tốc độ (ví dụ: 120)"
speedBox.Text = tostring(speed)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 16
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBox.BorderSizePixel = 0
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 6)

toggle.MouseButton1Click:Connect(function()
    farming = not farming
    toggle.Text = farming and "TẮT FARM" or "BẬT FARM"
    toggle.BackgroundColor3 = farming and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 100, 200)
end)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val > 0 then
        speed = val
        speedLabel.Text = "Tốc độ: " .. tostring(speed)
    else
        speedBox.Text = tostring(speed)
    end
end)

-- // Fly mượt
local TweenService = game:GetService("TweenService")
function flyTo(pos)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local dist = (hrp.Position - pos).Magnitude
    local time = dist / speed
    local tween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos + Vector3.new(0, 4, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- // Server Hop
function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceID = game.PlaceId
    local req = (syn and syn.request) or http_request or request
    if not req then return end

    local servers = {}
    local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
    local res = req({Url = url, Method = "GET"})
    local data = HttpService:JSONDecode(res.Body)

    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers then
            table.insert(servers, v.id)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceID, servers[math.random(1, #servers)], game.Players.LocalPlayer)
    end
end

-- // Farm Loop
spawn(function()
    while wait() do
        if farming then
            wait(2)

            local chests = {}
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("TouchInterest", true) and v.Name:lower():find("chest") then
                    local part = v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        table.insert(chests, part)
                    end
                end
            end

            if #chests == 0 then
                print("Hết rương → Đang chuyển server...")
                wait(2)
                serverHop()
            else
                for _, chest in pairs(chests) do
                    pcall(function()
                        flyTo(chest.Position)
                        wait(0.5)
                    end)
                end
            end

            wait(5)
        end
    end
end)
