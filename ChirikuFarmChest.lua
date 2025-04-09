--===[ Farm Chest Tối Ưu Nhất | Hop Server | Mobile Stable ]===--

-- Cấu hình
getgenv().ChestFarm = {
    Enabled = false,
    Speed = 350,
    Team = "Marines",
    DelayHop = 3,
    AntiLoopHop = 10,
}

local JoinedAt = tick()
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local TS = game:GetService("TweenService")
local TP = game:GetService("TeleportService")
local Http = game:GetService("HttpService")

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    Player.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto Team
coroutine.wrap(function()
    repeat
        RS.Remotes.CommF_:InvokeServer("SetTeam", getgenv().ChestFarm.Team)
        task.wait(1)
    until Player.Team
end)()

-- UI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 130)
frame.Position = UDim2.new(1, -180, 1, -150)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Text = "Chest Farm"
title.Size = UDim2.new(1, 0, 0, 25)
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local status = Instance.new("TextLabel", frame)
status.Position = UDim2.new(0, 0, 0, 25)
status.Size = UDim2.new(1, 0, 0, 40)
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.Text = "OFF"

local toggle = Instance.new("TextButton", frame)
toggle.Position = UDim2.new(0, 0, 0, 70)
toggle.Size = UDim2.new(1, 0, 0, 25)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "Toggle Farm"
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBold

toggle.MouseButton1Click:Connect(function()
    getgenv().ChestFarm.Enabled = not getgenv().ChestFarm.Enabled
    status.Text = getgenv().ChestFarm.Enabled and "ON" or "OFF"
end)

local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Speed: "..getgenv().ChestFarm.Speed
speedBox.Position = UDim2.new(0, 0, 0, 100)
speedBox.Size = UDim2.new(1, 0, 0, 25)
speedBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then getgenv().ChestFarm.Speed = val end
end)

-- Tween function
local function MoveTo(pos)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local dist = (hrp.Position - pos).Magnitude
        local ti = TweenInfo.new(dist / getgenv().ChestFarm.Speed, Enum.EasingStyle.Linear)
        TS:Create(hrp, ti, {CFrame = CFrame.new(pos)}):Play()
        task.wait(dist / getgenv().ChestFarm.Speed)
    end
end

-- Hop Server
local function Hop()
    if tick() - JoinedAt < getgenv().ChestFarm.AntiLoopHop then return end
    local req = (syn and syn.request or http_request or request)
    local res = req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"})
    local data = Http:JSONDecode(res.Body)
    for _,v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            TP:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
            break
        end
    end
end

-- Main loop
spawn(function()
    while task.wait(0.5) do
        if getgenv().ChestFarm.Enabled then
            local found = false
            for _,v in ipairs(WS:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("TouchInterest") and v.Name:lower():find("chest") then
                    found = true
                    MoveTo(v:GetModelCFrame().p + Vector3.new(0,3,0))
                    task.wait(0.25)
                end
            end
            if not found then
                task.wait(getgenv().ChestFarm.DelayHop)
                local stillNothing = true
                for _,v in ipairs(WS:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("TouchInterest") and v.Name:lower():find("chest") then
                        stillNothing = false break
                    end
                end
                if stillNothing then
                    Hop()
                end
            end
        end
    end
end)
