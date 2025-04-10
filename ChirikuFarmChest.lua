--===[ Farm Chest Gọn Nhẹ | Tác giả: ChatGPT ]===--

getgenv().ChestFarm = {
    Enabled = false,
    Speed = 350,
    DelayHop = 3,
    AntiLoopHop = 10,
    Team = "Marines"
}

local JoinedAt = tick()
local plr = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local ts = game:GetService("TweenService")
local tp = game:GetService("TeleportService")
local http = game:GetService("HttpService")

--===[ Giới Thiệu Script Trên Màn Hình ]===--
local infoGui = Instance.new("ScreenGui", game.CoreGui)
infoGui.Name = "IntroGui"

local holder = Instance.new("Frame", infoGui)
holder.Size = UDim2.new(1, 0, 0, 50)
holder.Position = UDim2.new(0, 0, 0, 0)
holder.BackgroundTransparency = 1

local title1 = Instance.new("TextLabel", holder)
title1.Size = UDim2.new(0, 250, 1, 0)
title1.Position = UDim2.new(0, 10, 0, 0)
title1.BackgroundTransparency = 1
title1.Text = "Farm Chest Script"
title1.TextColor3 = Color3.fromRGB(255, 255, 0)
title1.TextScaled = true
title1.Font = Enum.Font.GothamBold
title1.TextXAlignment = Enum.TextXAlignment.Left

local title2 = Instance.new("TextLabel", holder)
title2.Size = UDim2.new(0, 200, 1, 0)
title2.Position = UDim2.new(0, 270, 0, 0)
title2.BackgroundTransparency = 1
title2.Text = "- Tác giả: Chiriku Roblox"
title2.TextColor3 = Color3.fromRGB(0, 255, 0)
title2.TextScaled = true
title2.Font = Enum.Font.GothamBold
title2.TextXAlignment = Enum.TextXAlignment.Left

local status = Instance.new("TextLabel", holder)
status.Size = UDim2.new(0, 200, 1, 0)
status.Position = UDim2.new(0, 500, 0, 0)
status.BackgroundTransparency = 1
status.Text = "| Đang Tải..."
status.TextColor3 = Color3.fromRGB(230, 230, 230)
status.TextScaled = true
status.Font = Enum.Font.Gotham
status.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
    wait(3)
    infoGui:Destroy()
end)

-- Anti AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    plr.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Auto Team
coroutine.wrap(function()
    repeat
        rs.Remotes.CommF_:InvokeServer("SetTeam", getgenv().ChestFarm.Team)
        task.wait(1)
    until plr.Team
end)()

-- UI Gọn (có logo)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 70)
frame.Position = UDim2.new(0, 10, 1, -100)  -- Chỉnh lại vị trí góc trái
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

-- Logo của bạn
local logo = Instance.new("ImageLabel", frame)
logo.Size = UDim2.new(0, 30, 0, 30)
logo.Position = UDim2.new(0, 5, 0, 0)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://119198835819797" -- Thay ID này nếu bạn có logo riêng
logo.ScaleType = Enum.ScaleType.Fit

-- Nút bật/tắt
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 170, 0, 30)
toggle.Position = UDim2.new(0, 35, 0, 0)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "Farm: OFF"
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBold

toggle.MouseButton1Click:Connect(function()
    getgenv().ChestFarm.Enabled = not getgenv().ChestFarm.Enabled
    toggle.Text = "Farm: " .. (getgenv().ChestFarm.Enabled and "ON" or "OFF")
    
    if getgenv().ChestFarm.Enabled then
        updateStatus("Đang farm chest...")
    else
        updateStatus("Đang chill...")
    end
end)

-- Ô chỉnh tốc độ
local speedBox = Instance.new("TextBox", frame)
speedBox.PlaceholderText = "Speed: " .. getgenv().ChestFarm.Speed
speedBox.Position = UDim2.new(0, 0, 0, 35)
speedBox.Size = UDim2.new(1, 0, 0, 30)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.Gotham
speedBox.ClearTextOnFocus = false

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val then getgenv().ChestFarm.Speed = val end
end)

--===[ Thông báo trạng thái ở giữa màn hình (trong suốt, chữ trắng) ]===--
local statusGui = Instance.new("ScreenGui", game.CoreGui)
statusGui.Name = "StatusDisplay"

local statusLabel = Instance.new("TextLabel", statusGui)
statusLabel.Size = UDim2.new(0, 400, 0, 50)
statusLabel.Position = UDim2.new(0.5, -200, 0.05, 0)
statusLabel.BackgroundTransparency = 1 -- hoàn toàn trong suốt
statusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- không còn dùng
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- trắng
statusLabel.Text = "Trạng thái: Đang chờ..."
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.AnchorPoint = Vector2.new(0.5, 0)

local function updateStatus(text)
    statusLabel.Text = "Trạng thái: " .. text
end

-- Fly Mượt mà theo đường thẳng
local TweenService = game:GetService("TweenService")

function MoveTo(position)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:WaitForChild("HumanoidRootPart")

    local distance = (hrp.Position - position).Magnitude
    local speed = tonumber(flySpeed.Text) or 250
    local time = distance / speed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Hop Server
local function Hop()
    if tick() - JoinedAt < getgenv().ChestFarm.AntiLoopHop then return end
    local req = (syn and syn.request or http_request or request)
    local res = req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"})
    local data = http:JSONDecode(res.Body)
    for _,v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            tp:TeleportToPlaceInstance(game.PlaceId, v.id, plr)
            break
        end
    end
end

-- Farm Loop
spawn(function()
    while task.wait(0.5) do
        if getgenv().ChestFarm.Enabled then
            local found = false
            updateStatus("Đang farm chest...")
            for _,v in pairs(ws:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChildWhichIsA("TouchTransmitter", true) and v.Name:lower():find("chest") then
                    found = true
                    MoveTo(v:GetModelCFrame().Position + Vector3.new(0,3,0))
                    task.wait(0.25)
                end
            end
            if not found then
                task.wait(getgenv().ChestFarm.DelayHop)
                local stillNone = true
                for _,v in pairs(ws:GetDescendants()) do
                    if v:IsA("Model") and v.Name:lower():find("chest") then
                        stillNone = false
                        break
                    end
                end
                if stillNone then
                    Hop()
                end
            end
        end
    end
end)
