--// Auto vào team
getgenv().Team = "Marines"  -- Hoặc "Marines" để gia nhập đội Marines

local function autoJoinTeam()
    local teamCode = getgenv().Team
    local player = game.Players.LocalPlayer
    local success, errorMessage = pcall(function()
        -- Tìm đến code nhập để gia nhập team
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(teamCode)
    end)
    
    if not success then
        warn("Không thể gia nhập team: " .. errorMessage)
    else
        print("Đã gia nhập team thành công!")
    end
end

--// Anti ban + Anti AFK
local vu = game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

--// Biến
getgenv().ChestFarmEnabled = true
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Mouse = LocalPlayer:GetMouse()

--// UI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ChestFarmUI"
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 20, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Text = "CHEST FARM SCRIPT"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.TextSize = 14

local OnButton = Instance.new("TextButton", Frame)
OnButton.Text = "BẬT"
OnButton.Size = UDim2.new(0.5, 0, 0, 40)
OnButton.Position = UDim2.new(0, 0, 0, 60)
OnButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
OnButton.TextColor3 = Color3.fromRGB(255,255,255)
OnButton.MouseButton1Click:Connect(function()
    getgenv().ChestFarmEnabled = true
    autoJoinTeam()  -- Tự động vào team khi bật farm
end)

local OffButton = Instance.new("TextButton", Frame)
OffButton.Text = "TẮT"
OffButton.Size = UDim2.new(0.5, 0, 0, 40)
OffButton.Position = UDim2.new(0.5, 0, 0, 60)
OffButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OffButton.TextColor3 = Color3.fromRGB(255,255,255)
OffButton.MouseButton1Click:Connect(function()
    getgenv().ChestFarmEnabled = false
end)

--// Fast Attack (Tự động đánh/bắn khi cầm vũ khí)
local function enableFastAttack()
    local humanoid = Char:WaitForChild("Humanoid")
    local combatItems = {"Melee", "Combat", "Superhuman", "Dragon Talon", "Shisui", "Saber", "Trident", "Dark Blade", "Pistol", "Flintlock", "RPG"}

    for _, v in pairs(combatItems) do
        if Char:FindFirstChild(v) then
            local weapon = Char[v]
            if weapon:IsA("Tool") then
                weapon.Activated:Connect(function()
                    while true do
                        if weapon.Parent == Char then
                            if weapon.Name == "Pistol" or weapon.Name == "Flintlock" or weapon.Name == "RPG" then
                                -- Súng bắn tự động
                                weapon:Activate()
                            else
                                -- Các vũ khí khác tự động đánh
                                humanoid:MoveTo(Mouse.Hit.p)
                            end
                            wait(0.1) -- Điều chỉnh tốc độ fast attack
                        else
                            break
                        end
                    end
                end)
            end
        end
    end
end

--// ESP Rương
function CreateESP(part)
    if part:FindFirstChild("ChestESP") then return end
    local Billboard = Instance.new("BillboardGui", part)
    Billboard.Name = "ChestESP"
    Billboard.Size = UDim2.new(0, 100, 0, 40)
    Billboard.AlwaysOnTop = true
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    local TextLabel = Instance.new("TextLabel", Billboard)
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.TextColor3 = Color3.new(1, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextScaled = true

    coroutine.wrap(function()
        while Billboard and Billboard.Parent do
            local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude)
            TextLabel.Text = "[RƯƠNG] - " .. dist .. "m"
            wait(0.1)
        end
    end)()
end

--// Auto Hop Server (và giữ trạng thái bật farm)
function HopServer()
    local servers = {}
    local req = syn and syn.request or http_request or http.request
    local body = req({
        Url = "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    }).Body
    local data = HttpService:JSONDecode(body)
    for i,v in pairs(data.data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers, v.id)
        end
    end

    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    end
end

--// Thông báo khi nhặt Fist of Darkness hoặc God Chalice
function NotifyItemPickup(itemName)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Item Picked Up",
        Text = itemName .. " đã được nhặt!",
        Icon = "rbxassetid://4483345998", -- Icon default
        Duration = 3
    })
end

--// Farm Rương Mượt và Thông Báo
spawn(function()
    while true do
        wait(1)
        if getgenv().ChestFarmEnabled then
            local foundChest = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and string.find(v.Name:lower(), "chest") and v:FindFirstChild("HumanoidRootPart") then
                    foundChest = true
                    CreateESP(v.HumanoidRootPart)
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local goal = v.HumanoidRootPart.Position + Vector3.new(0, 5, 0)
                        local dist = (hrp.Position - goal).Magnitude
                        local tween = TweenService:Create(
                            hrp,
                            TweenInfo.new(dist / 350, Enum.EasingStyle.Linear),
                            {CFrame = CFrame.new(goal)}
                        )
                        tween:Play()
                        tween.Completed:Wait()

                        -- Thông báo khi nhặt được Fist of Darkness (Sea 2) hoặc God Chalice (Sea 3)
                        if v.Name == "Fist of Darkness" then
                            NotifyItemPickup("Fist of Darkness (Sea 2)")
                        elseif v.Name == "God Chalice" then
                            NotifyItemPickup("God Chalice (Sea 3)")
                        end
                    end
                end
            end
            if not foundChest then
                wait(2)
                HopServer()
            end
        end
    end
end)

--// Kích hoạt fast attack khi script chạy
enableFastAttack()
