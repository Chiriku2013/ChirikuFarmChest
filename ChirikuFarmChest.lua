-- LocalScript (ClientSide) trong StarterPlayerScripts hoặc nơi khác

local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local FarmRemote = rs:WaitForChild("FarmRemote")  -- Đảm bảo rằng bạn đã tạo một RemoteEvent tên "FarmRemote" trong ReplicatedStorage

getgenv().ChestFarm = {
    Enabled = false,
    Speed = 350,
    DelayHop = 3,
    AntiLoopHop = 10,
    Team = "Marines"
}

-- Cập nhật trạng thái farm
local function SaveState()
    local state = {
        Enabled = getgenv().ChestFarm.Enabled,
        Speed = getgenv().ChestFarm.Speed
    }
    
    -- Gửi yêu cầu lưu trạng thái tới Server
    FarmRemote:FireServer("Save", state)
end

local function LoadState()
    -- Gửi yêu cầu tải trạng thái từ Server
    FarmRemote:FireServer("Load", nil)
    FarmRemote.OnClientEvent:Connect(function(farmStatus, farmSpeed)
        if farmStatus ~= nil then
            getgenv().ChestFarm.Enabled = farmStatus
        end
        if farmSpeed ~= nil then
            getgenv().ChestFarm.Speed = farmSpeed
        end
    end)
end

-- Khi vào game, tải lại trạng thái
LoadState()

-- Lưu trạng thái khi thoát hoặc thay đổi
game:BindToClose(function()
    SaveState()
end)

-- UI Gọn gàng
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 210, 0, 70)
frame.Position = UDim2.new(0, 10, 1, -100)  -- Chỉnh lại vị trí góc trái
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.ClipsDescendants = true

-- Thêm giới thiệu về script
local intro = Instance.new("TextLabel", gui)
intro.Size = UDim2.new(0, 400, 0, 30)
intro.Position = UDim2.new(0.5, -200, 0.05, 0)
intro.BackgroundTransparency = 1
intro.TextColor3 = Color3.fromRGB(255, 255, 255)
intro.Text = "Script Farm Chest by [Chiriku Roblox]"
intro.TextScaled = true
intro.Font = Enum.Font.GothamBold
intro.TextXAlignment = Enum.TextXAlignment.Center

-- Nút bật/tắt
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0, 170, 0, 30)
toggle.Position = UDim2.new(0, 35, 0, 0)
toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Text = "Farm: " .. (getgenv().ChestFarm.Enabled and "ON" or "OFF")
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBold

toggle.MouseButton1Click:Connect(function()
    getgenv().ChestFarm.Enabled = not getgenv().ChestFarm.Enabled
    toggle.Text = "Farm: " .. (getgenv().ChestFarm.Enabled and "ON" or "OFF")
    
    -- Lưu trạng thái mỗi khi bật/tắt farm
    SaveState()
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
    if val then 
        getgenv().ChestFarm.Speed = val
        SaveState()  -- Lưu lại tốc độ khi thay đổi
    end
end)

-- Thông báo trạng thái
local statusGui = Instance.new("ScreenGui", game.CoreGui)
statusGui.Name = "StatusDisplay"

local statusLabel = Instance.new("TextLabel", statusGui)
statusLabel.Size = UDim2.new(0, 400, 0, 50)
statusLabel.Position = UDim2.new(0.5, -200, 0.15, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Text = "Trạng thái: Đang chờ..."
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.AnchorPoint = Vector2.new(0.5, 0)

local function updateStatus(text)
    statusLabel.Text = "Trạng thái: " .. text
end

-- Hàm bay mượt mà
local TweenService = game:GetService("TweenService")

function MoveTo(position)
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:WaitForChild("HumanoidRootPart")

    local distance = (hrp.Position - position).Magnitude
    local speed = tonumber(speedBox.Text) or 250
    local time = distance / speed

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        {CFrame = CFrame.new(position)}
    )
    tween:Play()
    tween.Completed:Wait()
end

-- Farm Loop
spawn(function()
    while task.wait(0.5) do
        if getgenv().ChestFarm.Enabled then
            local found = false
            updateStatus("Đang farm chest...")
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChildWhichIsA("TouchTransmitter", true) and v.Name:lower():find("chest") then
                    found = true
                    MoveTo(v:GetModelCFrame().Position + Vector3.new(0,3,0))
                    task.wait(0.25)
                end
            end
            if not found then
                task.wait(getgenv().ChestFarm.DelayHop)
                Hop()
            end
        else
            updateStatus("Đang chill...")
        end
    end
end)
