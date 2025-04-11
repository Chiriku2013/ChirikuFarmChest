getgenv().Team = "Marines"  -- Đặt mặc định team là "Marines"
getgenv().ChestFarmEnabled = true

-- Giải quyết vấn đề bị AFK
pcall(function()
    local vu = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)

-- Tự động vào đội "Marines" khi chưa có team
spawn(function()
    repeat wait() until game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    repeat wait() until game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    wait(1)
    if game.Players.LocalPlayer.Team == nil and getgenv().Team then
        game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ChooseTeam"):FireServer(getgenv().Team)
    end
end)

-- UI Giao diện Script
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "ChestFarmUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0, 20, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "CHEST FARM SCRIPT"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 0)
title.TextSize = 14

local onBtn = Instance.new("TextButton", frame)
onBtn.Text = "BẬT"
onBtn.Size = UDim2.new(0.5, 0, 0, 40)
onBtn.Position = UDim2.new(0, 0, 0, 60)
onBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
onBtn.TextColor3 = Color3.fromRGB(255,255,255)
onBtn.MouseButton1Click:Connect(function()
    getgenv().ChestFarmEnabled = true
end)

local offBtn = Instance.new("TextButton", frame)
offBtn.Text = "TẮT"
offBtn.Size = UDim2.new(0.5, 0, 0, 40)
offBtn.Position = UDim2.new(0.5, 0, 0, 60)
offBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
offBtn.TextColor3 = Color3.fromRGB(255,255,255)
offBtn.MouseButton1Click:Connect(function()
    getgenv().ChestFarmEnabled = false
end)

-- Hàm tạo ESP cho Chest
function CreateESP(part)
    if part:FindFirstChild("ChestESP") then return end
    local bill = Instance.new("BillboardGui", part)
    bill.Name = "ChestESP"
    bill.Size = UDim2.new(0,100,0,40)
    bill.AlwaysOnTop = true
    bill.StudsOffset = Vector3.new(0,2,0)
    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.new(1,1,0)
    txt.TextScaled = true
    spawn(function()
        while bill and bill.Parent do
            local dist = math.floor((part.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
            txt.Text = "[RƯƠNG] - "..dist.."m"
            wait(0.1)
        end
    end)
end

-- Thông báo khi nhặt được Fist of Darkness hoặc God Chalice
function NotifyItem(item)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ĐÃ NHẶT!",
        Text = item,
        Duration = 4
    })
end

-- Hàm bay đến vị trí chest
function FlyTo(pos)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local ts = game:GetService("TweenService")
    local dist = (hrp.Position - pos).Magnitude
    local ti = TweenInfo.new(dist / 350, Enum.EasingStyle.Linear)
    local tween = ts:Create(hrp, ti, {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- Hàm nhảy server khi hết rương
local function Hop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local PlaceId = game.PlaceId
    local JobId = game.JobId
    local servers = {}
    local req = (http_request or request or syn.request)
    local res = req({Url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"})
    local data = HttpService:JSONDecode(res.Body)
    for i,v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= JobId then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1,#servers)], game.Players.LocalPlayer)
    end
end

-- Chính script farm chest và auto hop server
spawn(function()
    while wait(1) do
        if getgenv().ChestFarmEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local foundChest = false
            for _,v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and string.lower(v.Name):find("chest") then
                    foundChest = true
                    CreateESP(v.HumanoidRootPart)
                    FlyTo(v.HumanoidRootPart.Position + Vector3.new(0,3,0))
                    if v.Name == "Fist of Darkness" then
                        NotifyItem("Fist of Darkness (Sea 2)")
                    elseif v.Name == "God Chalice" then
                        NotifyItem("God Chalice (Sea 3)")
                    end
                    wait(1)
                end
            end
            if not foundChest then
                wait(3)
                Hop()
            end
        end
    end
end)
